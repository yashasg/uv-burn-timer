# SwiftSyntax AST Lint Rules

ADR-0003 spike (Loop-30 WI-loop30-2-spike). SwiftSyntax-based custom
HIG lint rules. First (and currently only) rule:

- `toolbar_image_needs_scaled_frame` — Group LY AST port.

## Build & test

```
cd tools/swiftlint-rules
swift test
```

## CLI

```
swift run swiftlint-ast ../../app/Sources/UVBurnTimer/AppViews.swift
```

Exit code `1` iff any violations were emitted (SwiftLint-compatible
xcode reporter format).

## Status

This is the **spike**. ADR-0003 remains `Proposed` until the spike
verdict (`.squad/decisions/inbox/ma-ti-adr-0003-spike-verdict.md`) is
accepted by the team. Regex rule in `.swiftlint.yml` remains the
shipping gate; this tree is build-and-tested but not yet wired into
`./build.sh`.
