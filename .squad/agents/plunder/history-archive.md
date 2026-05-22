# Plunder — Legal & Compliance History Archive

## Summary of 2026-05-21 Work (23.8 KB archived)

**Agent:** Plunder (Legal & Compliance Reviewer)

**Major deliverables:**
1. **Skin-type persistence & re-attestation cadence** (2026-05-21T06:35:00Z)
   - Provenance audit: C7 (`@State`-only) was self-imposed product posture, not regulatory floor
   - Finding: `UserDefaults`-local persistence is compliant under FDA, EU MDR, UK MHRA, GDPR, FTC
   - Recommended Pattern B: UserDefaults + one-tap confirm chip on cold launch
   - Deliverable: `.squad/designs/plunder-skin-type-persistence-floor.md`
   - Impact: 5 open attorney escalations (E13–E17) for confirm-before-submit

2. **Disclaimer-relocation regulatory floor** (2026-05-21T04:18:05Z)
   - Apple Weather analogue is invalid (we output personalized health, not atmospheric data)
   - Photosensitized cohort is foreseeable per D-2026-05-19-007
   - Minimum compliant surface: L3 chevron ("Is this estimate for me?") at forecast card foot
   - Reuses existing locked copy; zero new surface area
   - Satisfies MDCG 2019-11 §3.3, FDA foreseeable-misuse, FTC §5, MDR Annex VIII Rule 11
   - Deliverable: `.squad/designs/plunder-disclaimer-relocation-floor.md`

3. **Location privacy & rationale persistence** (2026-05-20)
   - Clearing saved location does NOT clear rationale ack
   - Rationale ack persists (informed-consent state, not data point)
   - Uninstall is universal escape hatch

**Skills created:**
- `big-player-analogue-compliance-test/SKILL.md` — diagnostic for rejecting invalid big-player-X precedent claims
- `samd-minimum-surface-checklist-wellness-apps/SKILL.md` — planned update (constraint-provenance audit step)

**Key pattern:** Health-adjacent personalization (user data + formula output) crosses regulatory threshold. Foreseeable-misuse doctrine applies; silence on at-risk surfaces is deceptive omission.

**No code blockers. Process lesson:** Distinguish inherited constraints (cite regulation) from operational effects (happen to require constraint). Trace each floor to its actual regulatory provenance.
