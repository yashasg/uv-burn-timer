"""
Normalize a minimal Excalidraw export (as produced by the Excalidraw MCP
server's `query_elements`) into a fully schema-compliant scene that
excalidraw.com can import.

Background
----------
The MCP `query_elements` tool returns each element with only a small subset of
the canonical ExcalidrawElement fields (id, type, x, y, text, fontSize,
strokeColor, createdAt, updatedAt, version — and width/height/strokeWidth on
rects).  Loading such an export into excalidraw.com fails with
"Error: invalid file".

Reproducing the failure shows that excalidraw's restore pipeline calls
`isInvisiblySmallElement(raw)` *before* it fills in defaults, and that
function reaches for `element.points.length` on arrow/line elements.  A
missing `points` array therefore throws inside `restoreElements`, which the
outer loader catches and converts into the generic "invalid file" error.

Several other fields cascade similarly (font lookup needs `fontFamily`,
line-height detection needs `height` or `lineHeight`, repair passes touch
`groupIds`, `boundElements`, `seed`, `versionNonce`, etc.).

This script walks every element and fills in every missing required field
with a sensible default that matches the source-of-truth schema in
`packages/element/src/types.ts` and the restore behaviour in
`packages/excalidraw/data/restore.ts` (Excalidraw 0.18+).

Visual layout is NOT changed: positions, sizes, colors, fonts, and text are
all preserved exactly as exported.

Usage:
    python3 normalize.py <input.excalidraw> [output.excalidraw]

If output is omitted the input is rewritten in place (with a `.bak` backup).
"""
from __future__ import annotations

import json
import random
import shutil
import sys
import time
from pathlib import Path
from typing import Any

# --------------------------------------------------------------------------
# Defaults matching @excalidraw/common DEFAULT_ELEMENT_PROPS + restore.ts
# --------------------------------------------------------------------------
DEFAULT_STROKE_COLOR = "#1e1e1e"
DEFAULT_BG_COLOR = "transparent"
DEFAULT_FILL_STYLE = "solid"
DEFAULT_STROKE_WIDTH = 2
DEFAULT_STROKE_STYLE = "solid"
DEFAULT_ROUGHNESS = 1
DEFAULT_OPACITY = 100

DEFAULT_FONT_FAMILY = 5  # Excalifont — Excalidraw's modern default
DEFAULT_TEXT_ALIGN = "left"
DEFAULT_VERTICAL_ALIGN = "top"
DEFAULT_LINE_HEIGHT = 1.25
DEFAULT_AUTO_RESIZE = True

DEFAULT_END_ARROWHEAD = "arrow"


def rand_int32() -> int:
    """Random positive 31-bit integer (matches Excalidraw's `random.randint(1, 2**31 - 1)` seed/versionNonce convention)."""
    return random.randint(1, 2**31 - 1)


def now_ms() -> int:
    return int(time.time() * 1000)


def parse_iso_to_ms(iso_str: Any, fallback: int) -> int:
    if not isinstance(iso_str, str):
        return fallback
    try:
        # Python <3.11 doesn't accept trailing 'Z' — normalise
        s = iso_str.replace("Z", "+00:00")
        from datetime import datetime

        return int(datetime.fromisoformat(s).timestamp() * 1000)
    except Exception:
        return fallback


def text_dimensions(text: str, font_size: float) -> tuple[float, float]:
    """Best-effort width/height for text elements that ship without dimensions.

    Excalidraw recomputes these on import via `refreshTextDimensions`, but a
    plausible bounding box keeps `detectLineHeight` happy when the loader
    chooses to use existing dimensions instead.
    """
    lines = text.split("\n") if text else [""]
    # Average glyph width on Excalifont/Helvetica is ~0.55 of font size.
    width = max(1, int(max(len(line) for line in lines) * font_size * 0.55))
    height = max(1, int(len(lines) * font_size * DEFAULT_LINE_HEIGHT))
    return width, height


# --------------------------------------------------------------------------
# Per-element normalisers
# --------------------------------------------------------------------------
def normalize_base(el: dict, default_updated: int) -> dict:
    """Apply the union of fields required on every ExcalidrawElement."""
    out = dict(el)
    out.setdefault("id", f"el-{rand_int32()}")
    out.setdefault("type", "rectangle")
    out.setdefault("x", 0)
    out.setdefault("y", 0)
    out.setdefault("width", 0)
    out.setdefault("height", 0)
    out.setdefault("angle", 0)

    out.setdefault("strokeColor", DEFAULT_STROKE_COLOR)
    out.setdefault("backgroundColor", DEFAULT_BG_COLOR)
    out.setdefault("fillStyle", DEFAULT_FILL_STYLE)
    out.setdefault("strokeWidth", DEFAULT_STROKE_WIDTH)
    out.setdefault("strokeStyle", DEFAULT_STROKE_STYLE)
    out.setdefault("roughness", DEFAULT_ROUGHNESS)
    out.setdefault("opacity", DEFAULT_OPACITY)

    # Sharp corners by default — flow diagrams should not get auto-rounded.
    out.setdefault("roundness", None)

    out.setdefault("seed", rand_int32())
    out.setdefault("version", 1)
    out.setdefault("versionNonce", rand_int32())
    out.setdefault("index", None)
    out.setdefault("isDeleted", False)
    out.setdefault("groupIds", [])
    out.setdefault("frameId", None)
    out.setdefault("boundElements", None)
    updated_ms = parse_iso_to_ms(out.get("updatedAt"), default_updated)
    out.setdefault("updated", updated_ms)
    out.setdefault("link", None)
    out.setdefault("locked", False)
    return out


def normalize_text(el: dict, default_updated: int) -> dict:
    out = normalize_base(el, default_updated)
    text = out.get("text", "") or ""
    out["text"] = text
    out.setdefault("fontSize", 20)
    out.setdefault("fontFamily", DEFAULT_FONT_FAMILY)
    out.setdefault("textAlign", DEFAULT_TEXT_ALIGN)
    out.setdefault("verticalAlign", DEFAULT_VERTICAL_ALIGN)
    out.setdefault("containerId", None)
    out.setdefault("originalText", text)
    out.setdefault("lineHeight", DEFAULT_LINE_HEIGHT)
    out.setdefault("autoResize", DEFAULT_AUTO_RESIZE)

    if not out.get("width") or not out.get("height"):
        w, h = text_dimensions(text, out["fontSize"])
        out["width"] = out.get("width") or w
        out["height"] = out.get("height") or h
    return out


def normalize_arrow(el: dict, default_updated: int) -> dict:
    out = normalize_base(el, default_updated)
    # Points must exist and have at least 2 entries.  The MCP wrapper stores
    # arrow geometry as (x, y, width, height) where width/height are the
    # delta from tail to head, so the canonical points are [[0,0],[w,h]].
    if not isinstance(out.get("points"), list) or len(out.get("points") or []) < 2:
        w = out.get("width", 0) or 0
        h = out.get("height", 0) or 0
        out["points"] = [[0, 0], [w, h]]
    out.setdefault("lastCommittedPoint", None)
    out.setdefault("startBinding", None)
    out.setdefault("endBinding", None)
    out.setdefault("startArrowhead", None)
    out.setdefault("endArrowhead", DEFAULT_END_ARROWHEAD)
    out.setdefault("elbowed", False)
    return out


def normalize_line(el: dict, default_updated: int) -> dict:
    out = normalize_base(el, default_updated)
    if not isinstance(out.get("points"), list) or len(out.get("points") or []) < 2:
        w = out.get("width", 0) or 0
        h = out.get("height", 0) or 0
        out["points"] = [[0, 0], [w, h]]
    out.setdefault("lastCommittedPoint", None)
    out.setdefault("startBinding", None)
    out.setdefault("endBinding", None)
    out.setdefault("startArrowhead", None)
    out.setdefault("endArrowhead", None)
    out.setdefault("polygon", False)
    return out


NORMALISERS = {
    "text": normalize_text,
    "arrow": normalize_arrow,
    "line": normalize_line,
    "rectangle": normalize_base,
    "ellipse": normalize_base,
    "diamond": normalize_base,
}


# --------------------------------------------------------------------------
# Scene-level normalisation
# --------------------------------------------------------------------------
def normalize_scene(scene: dict, *, seed: int | None = None) -> dict:
    if seed is not None:
        random.seed(seed)

    default_updated = now_ms()
    elements = scene.get("elements") or []

    normalised_elements = []
    for el in elements:
        kind = el.get("type", "rectangle")
        fn = NORMALISERS.get(kind, normalize_base)
        normalised_elements.append(fn(el, default_updated))

    app_state = dict(scene.get("appState") or {})
    if app_state.get("gridSize") is None:
        app_state["gridSize"] = 20
    app_state.setdefault("gridStep", 5)
    app_state.setdefault("gridModeEnabled", False)
    app_state.setdefault("viewBackgroundColor", "#ffffff")
    app_state.setdefault("currentItemFontFamily", DEFAULT_FONT_FAMILY)
    app_state.setdefault("currentItemFontSize", 20)
    app_state.setdefault("currentItemStrokeColor", DEFAULT_STROKE_COLOR)
    app_state.setdefault("currentItemBackgroundColor", DEFAULT_BG_COLOR)
    app_state.setdefault("currentItemFillStyle", DEFAULT_FILL_STYLE)
    app_state.setdefault("currentItemStrokeWidth", DEFAULT_STROKE_WIDTH)
    app_state.setdefault("currentItemStrokeStyle", DEFAULT_STROKE_STYLE)
    app_state.setdefault("currentItemRoughness", DEFAULT_ROUGHNESS)
    app_state.setdefault("currentItemOpacity", DEFAULT_OPACITY)
    app_state.setdefault("currentItemTextAlign", DEFAULT_TEXT_ALIGN)
    app_state.setdefault("currentItemStartArrowhead", None)
    app_state.setdefault("currentItemEndArrowhead", DEFAULT_END_ARROWHEAD)

    out = {
        "type": "excalidraw",
        "version": 2,
        "source": scene.get(
            "source", "https://excalidraw.com"
        ),
        "elements": normalised_elements,
        "appState": app_state,
        "files": scene.get("files") or {},
    }
    return out


# --------------------------------------------------------------------------
# CLI
# --------------------------------------------------------------------------
def main(argv: list[str]) -> int:
    if len(argv) < 2:
        print(__doc__)
        return 2
    src = Path(argv[1])
    dst = Path(argv[2]) if len(argv) > 2 else src

    scene = json.loads(src.read_text())
    normalised = normalize_scene(scene)

    if dst == src:
        bak = src.with_suffix(src.suffix + ".bak")
        shutil.copy2(src, bak)
        print(f"Backup: {bak}")
    dst.write_text(json.dumps(normalised, indent=2))
    print(f"Wrote: {dst} ({len(normalised['elements'])} elements)")

    # Quick post-write sanity check.
    n_arrows = sum(1 for e in normalised["elements"] if e["type"] == "arrow")
    n_text = sum(1 for e in normalised["elements"] if e["type"] == "text")
    n_rect = sum(1 for e in normalised["elements"] if e["type"] == "rectangle")
    missing_points = [
        e["id"] for e in normalised["elements"]
        if e["type"] in ("arrow", "line") and len(e.get("points", [])) < 2
    ]
    missing_seed = [e["id"] for e in normalised["elements"] if "seed" not in e]
    print(
        f"Sanity: {n_rect} rectangles · {n_text} text · {n_arrows} arrows · "
        f"missing-points={len(missing_points)} · missing-seed={len(missing_seed)}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
