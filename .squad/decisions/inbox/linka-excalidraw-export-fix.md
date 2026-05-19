# Linka — Excalidraw export schema-normalisation fix

**Date:** 2026-05-19T01:40:19-07:00
**Author:** Linka (UI/UX, Apple HIG & Accessibility)
**Status:** ✅ resolved — file now imports cleanly into excalidraw.com
**Artifact touched:** `user-flow-onboarding-main.excalidraw` (D-2026-05-19-013 deliverable)
**Companion script:** `.squad/files/excalidraw-normalize.py`

---

## Problem

The Excalidraw export `user-flow-onboarding-main.excalidraw` at the repo root **would not import into excalidraw.com** — the loader surfaced the generic error `Error: invalid file`. The file (61.7 KB, 146 elements) had been produced by serialising the Excalidraw MCP server's `query_elements` output inside the canonical `{type:"excalidraw", version:2, elements, appState, files}` wrapper. The wrapper was correct; the individual elements were not.

## Root cause

`excalidraw-query_elements` returns a **minimal element shape** — only the fields the MCP server tracks, not the full `ExcalidrawElement` schema that excalidraw.com's loader requires. Each text element shipped with only `id, type, x, y, text, fontSize, strokeColor, createdAt, updatedAt, version`; arrows shipped without `points` at all.

Tracing the failure through Excalidraw 0.18.1 source (`packages/excalidraw/data/blob.ts`, `data/restore.ts`, `element/types.ts`) and verifying with a Node + jsdom + esbuild harness around the real `loadFromBlob` reproduced the exact error path:

1. `loadSceneOrLibraryFromBlob` parses the JSON and calls `isValidExcalidrawData` — passes.
2. It then calls `restoreElements(data.elements, ...)`.
3. `restoreElements` first reduces over the raw element list calling `isInvisiblySmallElement(raw)` on each element **before** `restoreElement` fills in defaults.
4. For arrow/line elements, `isInvisiblySmallElement` is implemented as `e.points.length < 2`. The MCP arrows have no `points` field → `undefined.length` → `TypeError: Cannot read properties of undefined (reading 'length')`.
5. The outer `try { ... } catch { throw new Error("Error: invalid file") }` in `loadSceneOrLibraryFromBlob` swallows the real error and surfaces the unhelpful "invalid file" the user reported.

A second cascading failure waits behind `points` if you only fix that: text elements without `fontFamily`/`lineHeight`/`height` route through `getLineHeight(undefined)` → font-registration → `FontFace` API path → various downstream NaN propagation.

## Fix

Wrote `.squad/files/excalidraw-normalize.py` — a single-pass element walker that fills in every required field from the canonical schema (`packages/element/src/types.ts`) with the defaults from `packages/common` + `packages/excalidraw/data/restore.ts`. **Visual layout is preserved exactly** — only schema fields were added, no coordinates, sizes, colors, or text were touched.

### Defaults applied

| Scope | Field | Default |
|---|---|---|
| **All** | `seed`, `versionNonce` | random positive 31-bit int |
| | `version` | preserve, else `1` |
| | `index` | `null` (loader assigns) |
| | `isDeleted`, `locked` | `false` |
| | `groupIds`, `boundElements` | `[]`, `null` |
| | `frameId`, `link` | `null` |
| | `roundness` | `null` (sharp corners — flow diagram intent) |
| | `angle` | `0` |
| | `fillStyle`, `strokeStyle` | `"solid"`, `"solid"` |
| | `strokeWidth`, `roughness`, `opacity` | `2`, `1`, `100` |
| | `backgroundColor`, `strokeColor` | `"transparent"`, `"#1e1e1e"` |
| | `updated` | parsed from `updatedAt` if present, else `now()` |
| **text** | `fontFamily` | `5` (Excalifont) |
| | `textAlign`, `verticalAlign` | `"left"`, `"top"` |
| | `containerId` | `null` |
| | `originalText` | mirror of `text` |
| | `lineHeight`, `autoResize` | `1.25`, `true` |
| | `width`, `height` | computed from `text` + `fontSize` if missing |
| **arrow** | `points` | `[[0,0],[width,height]]` ← **the load-bearing fix** |
| | `lastCommittedPoint` | `null` |
| | `startBinding`, `endBinding` | `null`, `null` |
| | `startArrowhead`, `endArrowhead` | `null`, `"arrow"` |
| | `elbowed` | `false` |
| **`appState`** | `gridSize` | `20` (was `null`) |

### Verification

Validated the fixed file through Excalidraw 0.18.1's actual `loadFromBlob` function — the same code path excalidraw.com runs on import — wired up under Node 25 with jsdom + esbuild + FontFace polyfill. Result: `SUCCESS — loaded 146 elements. Type counts after restore: { text: 99, rectangle: 35, arrow: 12 }`. Type counts match the pre-fix file exactly (D-2026-05-19-013 inventory: 35 rect, 99 text, 12 arrows).

Backup of the broken file kept on disk as `user-flow-onboarding-main.excalidraw.bak` for one cycle.

## Lesson — captured as skill update

`.squad/skills/excalidraw-flow-diagrams-via-mcp/SKILL.md` gained a new **"⚠️ Export gotcha — MCP `query_elements` returns a MINIMAL element shape"** section in the schema-gotchas list. It includes:

- The canonical element-base + per-type fields table (reproduced above).
- The explicit `points: [[0,0],[width,height]]` requirement on arrows that the loader's pre-restore `isInvisiblySmallElement` check requires.
- The reference to `.squad/files/excalidraw-normalize.py` as the canonical fix.
- The verification recipe (Node + jsdom + esbuild + `loadFromBlob`).

This is a load-bearing learning — **any future Excalidraw export via MCP must run through `excalidraw-normalize.py` before being committed to the repo**. Adding it as a pre-commit step is a fast-follow if Excalidraw ever ships from this team again.

## Files modified

1. `user-flow-onboarding-main.excalidraw` — re-serialised in place (61.7 KB → 165.7 KB; size delta is purely the added schema fields). Backup: `user-flow-onboarding-main.excalidraw.bak`.
2. `.squad/files/excalidraw-normalize.py` — *new*, the canonical normaliser.
3. `.squad/files/user-flow-onboarding-main-spec.md` — added an "Export history" section documenting the fix and explicitly noting that the visual layout is unchanged.
4. `.squad/skills/excalidraw-flow-diagrams-via-mcp/SKILL.md` — added the "Export gotcha" section + defaults table + verification recipe.
5. `.squad/decisions/inbox/linka-excalidraw-export-fix.md` — *this file*.

## Decision implications

- **No design changes.** The diagram content is identical pre- and post-fix.
- **No downstream agent re-work.** Kwame, Suchi, Wheeler, and Plunder do not need to re-read the diagram — it is the same diagram, now portable.
- **Process change:** Future Excalidraw deliverables from MCP must pass through `excalidraw-normalize.py` before being committed. Captured in the skill; this decision file is the audit trail.

---

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
