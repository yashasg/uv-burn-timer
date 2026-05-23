# Skill: Lead Reviewer Discipline (BLOCKED → CHANGES_REQUESTED)

**First seen:** 2026-05-22T23:55:00Z
**Author:** Gaia (Lead / Architect)
**Confidence:** medium *(revealed by PR #119 bypass; now formalized in charter; one re-application on a future BLOCKED verdict will bump to `high`)*
**Context:** PR #119 (Loop-30) merged despite a `BLOCKED` verdict in Gaia's
`.squad/` history because the verdict was never filed as a
`CHANGES_REQUESTED` review on the GitHub PR. WI-loop31-process-B (PR #125,
commit `6a27988`) closed the technical leg by enforcing `build-test` +
linear history on `main`. WI-loop31-process-A closes the procedural leg
by binding Lead verdicts to `gh pr review` calls.

---

## The Pattern

A reviewer verdict that lives only in `.squad/` is invisible to GitHub —
and therefore invisible to the merge button. The fix is a one-call
handshake: every verdict the Lead writes in `.squad/` MUST be mirrored
to the PR via `gh pr review` **before** any history or inbox entry is
written.

---

## Handshake Table

| `.squad/` verdict        | GitHub action                                                | Effect on merge button                                                                 |
|--------------------------|--------------------------------------------------------------|----------------------------------------------------------------------------------------|
| `BLOCKED`                | `gh pr review {pr} --request-changes -b "{verdict reasons}"` | PR shows "Changes requested"; combined with branch protection, signals "do not merge". |
| `APPROVED`               | `gh pr review {pr} --approve -b "{rationale}"`               | PR shows "Approved"; clears the human gate.                                            |
| `APPROVE-WITH-COMMENTS`  | `gh pr review {pr} --comment -b "{observations}"`            | Non-blocking; surfaces design notes without holding the PR.                            |

**Ordering rule:** `gh pr review` first. Only after a successful exit code
do you write the decision-inbox note or append to `history.md`. If the
`gh` call fails (auth, rate-limit, transient API error), the verdict is
not yet filed — retry until it succeeds, or escalate to the user.

---

## Revocation / Dismissal

When the author addresses the requested changes:

- **Same reviewer re-approves:** `gh pr review {pr} --approve -b "Concerns addressed in {commit-sha}; see {file:line}."` — a fresh APPROVE supersedes the prior CHANGES_REQUESTED for purposes of the GitHub UI summary.
- **Different reviewer takes over** (under the Reviewer Rejection Protocol's strict-lockout rules): dismiss the original review explicitly:
  ```
  gh api -X PUT \
    repos/{owner}/{repo}/pulls/{pr}/reviews/{review-id}/dismissals \
    -f message="Re-reviewed by {agent}; original concerns addressed."
  ```
  Then the new reviewer files their own `gh pr review` per the table above.

---

## Why This Exists (and why protection alone isn't enough)

Branch protection on `main` (PR #125) enforces:

- `required_status_checks.strict = true` with `build-test` required
- `required_linear_history = true`
- `enforce_admins = true`
- `allow_force_pushes = false`, `allow_deletions = false`

That closes the **technical** bypass: a PR cannot merge with red CI, and
no one can push directly to `main`. But protection has no opinion about
*design correctness* — it does not know whether the Lead thinks the
domain model is right, whether an ADR is needed, or whether the change
violates a boundary. The `BLOCKED → CHANGES_REQUESTED` handshake is the
**procedural** layer: it makes the Lead's design judgment legible to
the platform so the merge button reflects it.

Two layers, two failure modes, two fixes:

| Layer        | Failure mode                                              | Fix                                                |
|--------------|-----------------------------------------------------------|----------------------------------------------------|
| Technical    | PR merged with red CI / direct push to `main`             | WI-process-B: branch protection (PR #125)          |
| Procedural   | Lead says BLOCKED in `.squad/`; PR merges anyway          | WI-process-A: this skill + charter rule            |

---

## Anti-patterns

- **Verdict-only-in-history.** Writing `BLOCKED` in `.squad/decisions/inbox/`
  without filing `gh pr review --request-changes`. This is the exact PR #119
  failure mode.
- **Approve without rationale.** `gh pr review --approve` with an empty `-b`
  flag leaves no trail of *why* the design is acceptable. Always include a
  one-paragraph rationale.
- **Comment when you mean block.** If the verdict is `BLOCKED`, do not soften
  to `--comment`. Comments do not signal "do not merge" — they signal "fyi".
- **Stale approvals.** If new commits arrive after an approval and they
  materially change the design, re-review explicitly. Branch protection's
  `strict` setting forces CI to re-run, but it does not force the Lead to
  re-look.

---

## Cross-references

- Coordinator-level: `.github/agents/squad.agent.md` § "Reviewer Rejection Protocol" — strict-lockout semantics that complement this discipline (author cannot self-revise after BLOCKED).
- Copilot-level: `.copilot/skills/reviewer-protocol/SKILL.md` — the orchestration view of reviewer gating.
- Charter: `.squad/agents/gaia/charter.md` § "Reviewer Discipline" — the binding rule for Gaia specifically.
- Decision: `.squad/decisions/inbox/gaia-wi-process-b-protection-applied.md` — the protection JSON this skill assumes.

---

## When Confidence Bumps to `high`

The next time Gaia issues a `BLOCKED` verdict on a real PR, applies this
handshake correctly (`gh pr review --request-changes` before any
`.squad/` write), and the PR is held until addressed: update this skill
header to `confidence: high` and record the PR number under a
"Re-applications" section below.
