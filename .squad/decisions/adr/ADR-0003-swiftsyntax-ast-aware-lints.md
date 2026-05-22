# ADR-0003: Replace regex-based custom SwiftLint rules with SwiftSyntax/AST-aware lints

- **Status:** Proposed (2026-05-22) — accepted only after WI-loop30-2 spike lands
- **Author:** Gaia (Loop-30)
- **Work item:** WI-loop30-2
- **Supersedes:** _none_ (additive; regex rules remain in place until per-rule ports land)
- **Superseded by:** _none_
- **Related:**
  - [ADR-0001](./ADR-0001-hero-card-wrapper-preserves-toolbar-hit-test.md) — parent-identity contract for the toolbar
  - [ADR-0002](./ADR-0002-toolbar-topbartrailing-ios26.md) — iOS 26+ `.topBarTrailing` placement + iOS 26.4 Image-frame extension (PR #108 / WI-29-4 codifies the regex this ADR proposes to replace first)

## Context

`.swiftlint.yml` currently carries **8 custom rules**, all regex-based:

| # | Rule name                          | Trigger regex (abridged)                                                                                                                          | Severity |
|---|------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| 1 | `color_literal_rgb`                | `Color\(\s*red:|Color\(\s*\#|UIColor\(\s*red:|#colorLiteral`                                                                                      | error    |
| 2 | `navigation_stack_in_sheet`        | `\.sheet\([^)]*\)\s*\{[^}]*NavigationStack`                                                                                                       | error    |
| 3 | `missing_min_touch_target` (LW/LX) | `(?:\.onTapGesture\b|\bButton\s*\(|\bButton\s*\{|\bNavigationLink\s*\{|\bNavigationLink\s*\(|\bLink\s*\()(?![\s\S]{0,200}\.frame\(...min(Width|Height): id...)` | error    |
| 4 | `toolbar_image_needs_scaled_frame` (LY) | `\.toolbar\s*\{[\s\S]{0,2000}?\bImage\s*\((?![\s\S]{0,200}\.frame\(...min(Width|Height): id...)`                                              | error    |
| 5 | `no_uppercased_in_code`            | `\.uppercased\(\)`                                                                                                                                | error    |
| 6 | `hardcoded_frame_dimensions`       | `\.frame\(\s*(?:width|height|minWidth|minHeight|maxWidth|maxHeight):\s*\d`                                                                        | error    |
| 7 | `literal_system_font_size`         | `\.font\(\.system\(size:\s*\d`                                                                                                                    | error    |

Rules #3 and #4 are the load-bearing HIG tap-target gates and are also the
two that have shown the brittleness pattern this ADR is written against.

### Brittleness pattern (Loop-29 evidence)

Loop-29 shipped **three** regex rules / regex-widenings in **three separate
PRs**, each of which discovered a new false-negative in the previous
cycle's pattern:

| Group | PR    | WI         | What it added / widened                                                                                              | Blind spot it closed in the prior cycle's regex                                                                                            |
|-------|-------|------------|----------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| LW    | (Loop-28 baseline) | WI-loop-28-A | Original `missing_min_touch_target` — alternation watches `Button(` and `.onTapGesture`.                              | n/a (baseline).                                                                                                                            |
| LX    | #104  | WI-29-2    | Widened LW alternation to add `Button\s*\{` (trailing-closure form).                                                  | Toolbar gear regression in `AppViews.swift:122` shipped under LW because the trailing-closure `Button { ... } label: { ... }` form was not matched. |
| LX′   | #106  | WI-29-7    | Further widened LW/LX alternation to add `NavigationLink\s*\{`, `NavigationLink\s*\(`, and `Link\s*\(`.               | A future refactor that swapped a `Button` for a `NavigationLink`, or added a standalone `Link` outside paragraph copy, would bypass LW/LX. |
| LY    | #108  | WI-29-4    | New rule `toolbar_image_needs_scaled_frame` — guards bare `Image(` **inside** a `.toolbar { ... }` window.            | LW/LX never matched bare `Image(`; iOS 26.4 stopped auto-padding toolbar Image labels to ≥44pt, so the gear/ⓘ Images regressed under AX3+. |

Pattern: **every cycle's regex revealed a structural blind spot in the
previous cycle's regex.** LW alternated on `Button(`; LX had to learn
trailing-closures; LX′ had to learn other tap primitives; LY had to give
up on the alternation entirely and add a separate rule because `Image(`
inside a toolbar closure is a categorically different match shape.

The shared cause is that the rules are pattern-matching **syntactic
neighbourhoods** with a fixed-width lookahead (200–2000 chars) on flat
source text. Three structural facts of Swift make this fragile:

1. **Balanced-brace fragility.** A `.toolbar { ... }` body can contain
   nested closures (`ToolbarItem { ... }`, `Group { ... }`, `Menu { ... }`)
   whose total length exceeds the 2000-char window. Regex cannot count
   braces; we can only widen the window until it accidentally swallows
   *adjacent* toolbars or misses long ones.
2. **Trailing-closure vs paren form.** SwiftUI primitives have at least
   four call shapes (`Foo(...)`, `Foo { ... }`, `Foo { ... } label: { ... }`,
   `Foo(...) { ... }`). Each new shape requires a new alternation arm
   plus its own lookahead tuning, and shapes interact (e.g. `Button { ... }`
   inside a `.toolbar { ... }` matched by LX′ instead of LY when both
   could fire).
3. **Identifier-vs-literal proof.** The lookahead checks
   `min(Width|Height):\s*[A-Za-z_]+\b` — i.e. "the next argument is a bare
   identifier, not a digit." This catches `44` literals but cannot prove
   the identifier is `@ScaledMetric`-backed. The rules' own comments
   acknowledge this: "perfect @ScaledMetric validation would need an AST."

Each widening reduces but does not eliminate the false-negative surface,
and every widening makes the regex harder to read and to test by
inspection. **The next blind spot is structurally guaranteed**, not a
matter of effort.

### Why this needs an ADR (not just a refactor)

The cohort-convergence lesson from Loop-29 iter-2 closure
(`gaia/history.md` → 2026-05-22T18:15:00Z) says concrete WIs ship fast
with parallel agents. If we ship a *fourth* regex widening in Loop-30
WI-loop30-4 (the next HIG-rule cluster), we lock in the regex approach
for another N rules and pay the brittleness tax compounded. The right
moment to make the regex-vs-AST decision is **before** the next batch
ships, which is now.

## Decision

### Recommendation

Adopt **SwiftSyntax-based custom lints** (Option A below) as the default
implementation strategy for **net-new** load-bearing HIG rules — starting
with the Loop-30 spike (Section "Spike scope") — and port existing
regex rules opportunistically on a per-cycle basis only when they fail
again. Status remains **Proposed** until the spike (WI-loop30-2 follow-up)
demonstrates the SwiftSyntax port of `toolbar_image_needs_scaled_frame`
(Group LY) is verdict-identical on the Group LY contract corpus and
catches at least one synthetic case the regex misses; then this ADR
flips to **Accepted**.

### Rule (positive form — MUST, post-acceptance)

Any **new** custom HIG lint that depends on Swift syntactic structure
(closure containment, call-site shape, identifier provenance, attribute
walk such as `@ScaledMetric`) MUST be implemented as a SwiftSyntax
visitor and shipped via the SwiftLint custom-rule extension surface (or
as a parallel `swift-format`-style pre-commit step if SwiftLint's
plugin model proves too restrictive for the chosen rule).

### Anti-pattern (negative form — MUST NOT, post-acceptance)

Net-new HIG lints MUST NOT be shipped as regex `custom_rules:` entries
when the rule's intent requires any of: counting braces, distinguishing
trailing-closure from paren call form, proving identifier attributes,
or guarding inside a bounded syntactic scope (a `.toolbar { ... }`
body, a `NavigationStack { ... }` body, etc.). Regex remains acceptable
only for **single-token** lints (e.g. `no_uppercased_in_code`,
`literal_system_font_size`) where the trigger is one local token with
no structural context.

### Decision matrix — alternatives weighed

| Option                                                                                          | Implementation cost | CI cost                | False-positive rate | Maintenance burden               | Contributor learning curve              |
|-------------------------------------------------------------------------------------------------|---------------------|------------------------|---------------------|----------------------------------|-----------------------------------------|
| **A. SwiftSyntax visitor as a SwiftLint custom rule (chosen)**                                  | Medium (per rule)   | Low (parses once)      | Low                 | Low after first rule (shared parser, shared test harness) | Medium (`swift-syntax` is well-documented, but new) |
| B. `swift-format` / `sourcery` parallel pre-commit step                                          | Medium-high (parallel toolchain) | Medium (extra step) | Low | Medium (two lint stacks to keep aligned) | Medium-high (two tools)              |
| C. SwiftLint **analyzer** rules (compiled-module mode)                                          | High (per rule)     | High (full build for lint) | Lowest         | Medium                            | High (analyzer API + index store)       |
| D. Status quo: keep widening regex                                                              | Low (per cycle)     | Lowest                 | High over time      | High and growing                  | Low                                     |

Notes on the rejected options:

- **B (`swift-format` / `sourcery`):** introduces a second linting
  pipeline. The repo already gates on SwiftLint via `./build.sh` and
  CI; running a parallel toolchain doubles the configuration surface
  and the "which tool said what" cognitive load for contributors. Real
  win is only on rules SwiftLint cannot host at all — not our case.
- **C (analyzer rules):** strictly more powerful than SwiftSyntax-only
  rules (full type info via SourceKit), but they require a clean
  compile of the whole module on every lint pass. On this repo
  `./build.sh` is the long pole already; doubling that for lint is
  disproportionate for the rules in scope.
- **D (status quo):** the brittleness pattern documented above is the
  rejection rationale — every cycle adds a new blind spot.

### Tool of record

`swift-syntax` (Apple's first-party Swift parser; the same library
SwiftLint itself uses for many of its built-in rules). Authoring a
custom rule means writing a `SyntaxVisitor` subclass, packaging it
via SwiftLint's `swiftlint analyze` extension surface (or via a
self-contained executable that emits SwiftLint-compatible JSON if
the plugin path proves brittle), and committing a `.swiftlint.yml`
entry that points to it. Exact packaging is part of the spike.

## Spike scope

**Rule to port:** `toolbar_image_needs_scaled_frame` (Group LY) — the
most recently added rule, with the longest and most fragile regex
(2000-char outer window + 200-char inner lookahead, balanced-brace
sensitive).

**Acceptance criteria (this ADR flips to `Accepted` when all three hold):**

1. **Verdict parity on the existing corpus.** The SwiftSyntax rule
   produces the **same** verdict (pass/fail) as the current regex on
   every input that drives the Group LY contract tests in
   `MainScreenCleanupContractTests.swift` (LY1, LY2, LY3) **and** on
   the current `app/Sources/UVBurnTimer/AppViews.swift` toolbar block.
2. **Catches at least one synthetic case the regex misses.** A new
   contract test inputs a toolbar body that exceeds the 2000-char
   regex window — e.g. a `Menu { ... }` with three nested `Button`
   labels declared above the offending `Image(...)` — and asserts the
   SwiftSyntax rule fires while the regex does not. (This is the
   "structural guarantee" claim in the Context section, made falsifiable.)
3. **CI cost is bounded.** The new rule adds ≤ +15 s to the SwiftLint
   leg of `./build.sh` on the CI runner used by Loop-29 iter-2's
   reference run (`6m55s` total). If the lint leg crosses +30 s, the
   spike is rejected and Option B is reconsidered.

**Spike deliverables (single follow-up WI, not this ADR):**

- A small Swift package under `tools/swiftlint-rules/` (suggested
  path; final path is the spike's decision) holding the visitor.
- The new contract test in `MainScreenCleanupContractTests.swift` for
  the synthetic-corpus case.
- A spike report (3–5 paragraphs) appended to this ADR under a new
  `## Spike result` section, with the CI-timing measurement and the
  parity table.

**Rollout plan (post-acceptance, ≤ 3 WIs):**

1. **WI-30-A:** spike merges (LY rule ported + parity + new synthetic
   test). Regex LY remains in `.swiftlint.yml` for one cycle as
   belt-and-braces.
2. **WI-30-B:** port `missing_min_touch_target` (LW/LX/LX′) to
   SwiftSyntax; retire regex LW/LX/LX′ from `.swiftlint.yml` once the
   AST rule reaches verdict-parity on the existing contract corpus.
3. **WI-30-C:** retire regex LY now that LW/LX/LY are both AST and the
   shared visitor harness has bedded in; future net-new HIG rules
   default to the harness.

Single-token rules (`no_uppercased_in_code`, `literal_system_font_size`,
`color_literal_rgb`, `navigation_stack_in_sheet`, `hardcoded_frame_dimensions`)
are explicitly **out of scope** for the rollout — regex is the right
tool for those and they have not shown the brittleness pattern.

## Consequences

### Pro

- **Structural correctness.** A SwiftSyntax visitor can ask "is this
  `Image` lexically inside a `.toolbar` closure?" by walking the parent
  chain — no 2000-char window, no balanced-brace fragility.
- **Identifier provenance.** A visitor can resolve `minTap` to its
  declaration site and confirm the `@ScaledMetric` attribute, finally
  closing the "perfect @ScaledMetric validation would need an AST"
  caveat that every regex rule's comment carries.
- **One shared harness.** After the first rule, subsequent rules pay
  marginal cost only — share the parser, the test pattern, and the
  SwiftLint plugin glue.
- **Forward-compatible with SwiftLint's own direction.** SwiftLint is
  moving its built-in rules onto SwiftSyntax; we are not betting on a
  niche tool.

### Con

- **New dependency.** Pulls `swift-syntax` (or a SwiftLint plugin
  surface) into the lint stack. CI runners must resolve it; first
  cold build pays the package-resolve cost (mitigated by SPM cache).
- **Contributor learning curve.** A future contributor adding a rule
  must learn `SyntaxVisitor` instead of writing a one-line regex. This
  ADR accepts that cost in exchange for the brittleness elimination,
  but the trade-off is real and should be re-evaluated if rule-author
  velocity drops noticeably.
- **Two-rule stacking during port.** WI-30-A leaves both regex LY and
  AST LY active for one cycle. That doubles the lint surface briefly
  and could produce duplicate diagnostics on the same line. Mitigation:
  the AST rule shares a message prefix with the regex rule so duplicate
  diagnostics are visually obvious and dedupable.

### Operational

- The ADR remains **Proposed** until the spike acceptance criteria
  (above) pass on CI. Status flip is a follow-up commit on this file.
- No `app/Sources/` changes ship with this ADR — docs-only PR.
- Existing regex rules (LW / LX / LX′ / LY plus the five single-token
  rules) keep their current severity and behaviour unchanged through
  Loop-30. No rule is retired by this ADR alone.
- WI-loop30-4 (next HIG-rule cluster) is **dependency-gated** on this
  ADR per the Loop-30 backlog: if the spike accepts, WI-loop30-4 ships
  AST rules; if the spike fails, WI-loop30-4 ships regex rules as
  planned. Either way the decision is no longer drifting.

## Alternatives considered

1. **Keep widening regex (status quo).** Rejected — see Decision matrix
   row D. The brittleness pattern is structurally guaranteed to
   recur, and Loop-29 spent three PRs (#104, #106, #108) on it.
2. **Adopt `swift-format` / `sourcery` as a parallel lint stack
   (Option B).** Rejected for now — doubles the lint pipeline for a
   problem SwiftLint can host via SwiftSyntax. Revisit only if Option
   A's spike fails on the CI-cost criterion.
3. **Go straight to SwiftLint analyzer rules (Option C).** Rejected —
   requires a clean compile per lint pass, doubling `./build.sh`
   wall-clock. The rules in scope do not need type info that only
   SourceKit can provide; SwiftSyntax suffices.
4. **Port all 7 custom rules at once.** Rejected — single-token rules
   (`no_uppercased_in_code`, `literal_system_font_size`, etc.) are
   well-served by regex and have not shown the brittleness pattern.
   Porting them is busywork. The rollout above scopes the port to
   exactly the rules whose intent depends on syntactic structure.

## References

- `.swiftlint.yml`
  - `missing_min_touch_target` (Groups LW / LX / LX′) — regex history
    chronicled in the rule's own comment.
  - `toolbar_image_needs_scaled_frame` (Group LY) — proposed spike
    port target.
- `app/Tests/UVBurnTimerCoreTests/MainScreenCleanupContractTests.swift`
  - Group LY (LY1–LY3) — contract corpus for parity check.
- PR / branch history (Loop-29 brittleness evidence):
  - **PR #104** — WI-29-2: `Button { ... }` trailing-closure form added to LW regex.
  - **PR #106** — WI-29-7: `NavigationLink` / `Link` alternation added to LX regex.
  - **PR #108** — WI-29-4: new rule `toolbar_image_needs_scaled_frame` (LY) — the regex this ADR proposes to port first.
- Orchestration log:
  - `.squad/orchestration-log/2026-05-22T17-35-00Z-coordinator-loop29-iter2-spawn.md`
  - `.squad/orchestration-log/2026-05-22T18-30-00Z-coordinator-loop29-iter2-closure.md`
- Related ADRs:
  - [ADR-0001](./ADR-0001-hero-card-wrapper-preserves-toolbar-hit-test.md) — parent-identity contract.
  - [ADR-0002](./ADR-0002-toolbar-topbartrailing-ios26.md) — iOS 26+ `.topBarTrailing` placement + iOS 26.4 toolbar Image-frame floor; the iOS 26.4 extension subsection is the design-rationale document this ADR's first spike-port target enforces.
- Loop-30 backlog entry:
  - `.squad/decisions/inbox/gaia-loop30-open-backlog-seed.md` → WI-loop30-2.

*Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>*
