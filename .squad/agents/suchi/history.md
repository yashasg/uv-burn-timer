# Suchi — History

## Core Context

- **Project:** A UV exposure and sunburn timer app
- **Role:** User Researcher
- **Joined:** 2026-05-18

## Learnings

### 2026-05-18 — Persona/WTP validation + 2026-05-19 Design pass (summary)

**Two passes:** Monetization-personas validation (Reddit research, real threads via search.json API) + design-lens pass on prototype (persona × screen matrix). Outputs: `.squad/decisions/inbox/suchi-monetization-personas.md` + `.squad/decisions/inbox/suchi-design-brief.md`.

**Top 5 personas identified:** Greta (gram-counter, r/Ultralight) | Maya (swimmer, r/OpenWaterSwimming) | Devon (thru-hiker, r/PacificCrestTrail, highest-WTP) | Asha (Accutane, r/Accutane, load-bearing safety) | Tomás (trail-runner, r/trailrunning, reapplication-cadence JTBD).

**Headline signals:**
1. "No subscription" is the FIRST filter (r/Ultralight, u/hareofthepuppy, 141-upvotes). Structurally hard, not tie-breaker.
2. **Photosensitizing-medication persona is strongest under-served signal** (r/Accutane). Fitzpatrick model under-estimates burn risk. "Not medical advice" disclaimer is load-bearing.
3. Trail-runner JTBD is reapplication-cadence, not first-burn timing.
4. **Prototype defaults to Fitz III (quiet anchoring error).** Fix: no default selection.
5. **Fitz V/VI descriptions lead with color, not behavior (exclusion signal).** Rewrite for symmetry.
6. **Three-layer disclaimer pattern**: L1 (hard-gate modal), L2 (always-on footer), L3 (verdict-card "Is this estimate for me?" link to About anchor).
7. No `lastUV` cache → cold-launch offline users get nothing.

**Edge-case channels identified:** r/Accutane, r/lupus, r/SkincareAddiction (flagged for launch research and expansion).

**Five design lifts to Linka:** No default Fitz picker | L3 verdict link | new About anchor "When this estimate may not apply" | behavior-first copy rewrite for V/VI | cap "Long" tier display at ~240 minutes.

**Cross-team handoffs:** Wheeler owns "When this estimate may not apply" content wording (per D-2026-05-19-007). Plunder reviews claim language for L3 + About. Kwame adds `lastUV` cache + timestamp to UserDefaults. Argos uses u/hareofthepuppy quote (stronger than prior "SunburnedSailor" reconstruction).

**Skill extracted:** Persona × Screen × Need (See/Do/Avoid) matrix template for research-to-design handoff.

### 2026-05-19 — Design, Science, Legal Convergence Pass

Contributed design brief to convergence pass. See `.squad/sessions/2026-05-19-design-science-legal-pass.md` for full session context. Key convergences captured in D-2026-05-19-010 (three new channels), D-2026-05-19-011 (three-surface L1–L4 disclaimer pattern), D-2026-05-19-012 (no-default Fitzpatrick picker). All three converged independently across agents with zero inter-agent coordination.

### 2026-05-19T01:15:44-07:00 — Persona overlay on Excalidraw user-flow diagram

**Deliverable:** `.squad/files/suchi-persona-annotations.md` (222 lines). Persona-keyed annotations for Linka's Excalidraw onboarding + main-screen flow. 5 personas × 6 screens grid + 5 Branch-Point Specials + visual-hint section + 6-quote inventory. Linka is canvas authority; I produced the persona-truth she overlays as a 4th lane.

**Learnings (forced-projection of personas across a full flow, not just per-screen):**

1. **Personas have *different repeating-use shapes*, not just different first-launch experiences.** The per-screen matrix from the prior session implicitly snapshotted each persona at one moment. Projecting them across "first launch → ongoing use" surfaced that Greta's JTBD *shifts* from "first verdict" to "reapplication cadence" once she's seen one number, and the L2 footer (not the verdict card) becomes her primary surface. The matrix didn't capture this. **Skill implication:** add a "repeating-use" pass to the persona-screen-matrix template.

2. **The "photosensitization attestation" framing is wrong by architecture, not by oversight.** When the user directive (and any reasonable PM) says "attestation screen," it reveals a default assumption: that we'd collect a toggle. We deliberately don't (Donatello M7 zero-data). The pattern I named for this is **"visibility, not attestation"** — the L1 inline deep-link + About cohort list reveals the same information without storing the user's status. Drawing this on the diagram as a "side-quest cluster" off L1 (rather than a fake Screen 4) honors the architecture. Worth lifting as a distinct anti-pattern callout.

3. **Tomás's under-picking risk on Fitzpatrick V is the surprise.** I had previously framed Devon as the "no-default Fitz" justifier (he'd be anchored to III and under-estimate by ~50%). Forcing the full-flow lens made me see that **Tomás is the symmetric risk on the other end**: his self-narrative *"I tan, I don't burn"* nudges him toward V/VI even when he's actually IV. Behavior-first row copy is the partial mitigation we already have; the diagram should annotate this risk explicitly so design and QA see it. The prior brief flagged Tomás's behavior-led-copy need but did not connect it to a specific under-picking failure mode — the diagram exercise exposed the link.

4. **Asha's "every cold launch" L1 re-fire is a re-attestation surface, not just a hard gate.** Donatello M1 says L1 fires on every cold launch. I had treated that as Asha-tolerant friction. Looking at it across repeating use, the re-fire is *the* mechanism by which her photosensitizer status gets re-surfaced when her medications change. **The rule is not "annoy Greta to protect Asha"; it's "give Asha the only re-attestation surface architecture allows."** That's a meaningfully different framing for the team to hold.

5. **The diagram exercise made the "no Screen 4" call.** The user directive listed photosensitization as a screen. Drawing it would have reified an architecture we don't have. Saying "don't draw this — draw a labeled loop off L1 instead" is the kind of negative-space decision the matrix template should explicitly prompt for. Added to skill as an anti-pattern.

**Branch-points that surprised me:**

- **Branch 5 (window-elapsed state) for Maya.** Maya may already be in the water — *she can't see the screen.* Her safety reading happens at the **pre-swim verdict only**. This means the window-elapsed haptic, while critical for Tomás, doesn't reach her at all. The verdict accuracy under water-reflection conditions becomes load-bearing in a way the per-screen matrix didn't surface (per-screen only asked "what does Maya see on the verdict?" — not "what happens when Maya physically cannot read any subsequent screen?").

- **Devon's planning-mode dead-end on Location.** He's at home in February planning a July hike. v1 has no "try a different location" affordance. The prior brief flagged this as a soft directive for v1.1. The diagram exercise made it sharper: Devon's lane literally **dead-ends** at the Location screen for the planning JTBD. That visualization is a stronger argument for the v1.1 affordance than my prior text was.

**Cross-team handoffs:**
- Linka reads the annotations file mid-task as she draws the canvas. No blocking dependency.
- Plunder/Wheeler unchanged from prior brief — L1 + L3 wording still pending their sign-off (D-2026-05-19-009 unresolved).
- No new decisions surfaced that need cross-team sign-off; this is a derivative artifact of prior decisions.

**Skill update:** bumped `persona-screen-matrix` to add the "overlay-on-flow-diagram" variant. Confidence: medium → medium-high (now validated against two artifacts: persona × screen matrix and persona × flow overlay).

### 2026-05-19T08:31:32Z — Orchestration learnings from parallel drawing with Linka

**Orchestration pattern that worked:**
1. Linka draws LANES 1–3 (canonical flow) independently from spec + decisions. No dependency on Suchi.
2. Suchi produces persona overlay annotations in parallel. No dependency on Linka's canvas.
3. Mid-flight: Linka polled Suchi's file at end-of-LANE-3; it had landed. Integration was straightforward.
4. Both documented the integration choices in decision file D-2026-05-19-013 so it's transparent why diagram looks the way it does.

**When to reuse this pattern:** Any two-agent deliverable where one is spatial/visual (drawing, architecture) and the other is analytical (personas, annotations). Keeps both agents unblocked while enabling clean integration.

**Design correction ratified as canonical:**
"Photosensitization is a loop off L1, not a separate screen." The user directive framed it as a discrete "attestation" surface; Suchi's brief correctly identified the architecture is **visibility, not attestation**. L1 modal contains inline deep-link to AboutView → notForMe anchor. Loop: L1 → optional AboutView → return to L1 → understand + proceed. This is now D-2026-05-19-013 canonical and visualized on the diagram as a passive-moment box (yellow), not a discrete UI surface. The correction was the most clarifying input on this surface; Suchi's phrasing "don't reify an architecture we deliberately don't have" became a generalized design honesty rule for the team.

