### 2026-05-19T07:25:58Z: User directive — Canonical Fitzpatrick classification & citation source

**By:** yashasgujjar (via Copilot)

**What:** Adopt the Fitzpatrick Skin Type classification from NCBI Bookshelf Chapter 6, Table 1 as the canonical reference for this app. Use these exact descriptions (verbatim, both as the picker copy seed AND as the citation anchor):

| Type | Description |
|------|-------------|
| Type I   | White skin. Always burns, never tans. |
| Type II  | Fair skin. Always burns, tans with difficulty. |
| Type III | Average skin color. Sometimes mild burn, tan about average. |
| Type IV  | Light-brown skin. Rarely burns. Tans easily. |
| Type V   | Brown skin. Never burns. Tans very easily. |
| Type VI  | Black skin. Heavily pigmented. Never burns, tans very easily. |

**Citation:** https://www.ncbi.nlm.nih.gov/books/NBK481857/table/chapter6.t1/

**Why:** User selected this as the authoritative source. Aligns with Plunder's "cite the sources" mandate and Wheeler's expert-anchored math. Resolves Suchi's flag about V/VI-vs-I/II copy asymmetry (the NCBI source leads with skin-color descriptor for all six types — symmetry preserved).

**Implications for the team:**
- **Wheeler** (Skin Science): formally adopts as the canonical classification; locks the MED anchor table per type to this scale; validates that the wording is scientifically sound to use verbatim in UI copy or recommends minimal edits with rationale.
- **Linka** (UI/UX): the skin-type picker screen MUST present these six types with these descriptions; the citation lives in the About / Citations surface; the picker default must NOT silently anchor (per Suchi's prior flag — propose "Choose" / no-default state).
- **Plunder** (Legal & Compliance): vet the citation surface — full URL, attribution form, "informational only" framing — to match the "no medical claims" guardrail.
- **Suchi** (User Researcher): her copy-asymmetry flag is now resolved by adopting the symmetric NCBI wording. Persona × picker-screen guidance still applies.
- **Kwame** (iOS Developer): picker is implemented as in-memory `@State` only (per D-2026-05-19-001 — skin type is NEVER persisted to AppStorage/UserDefaults/HealthKit).

This directive supersedes any prototype copy that differs from the NCBI wording.
