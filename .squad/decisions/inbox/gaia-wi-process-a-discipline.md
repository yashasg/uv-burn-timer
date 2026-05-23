# Decision: Lead BLOCKED-Discipline — Charter Rule + Reviewer-Discipline Skill

- **WI:** WI-loop31-process-A
- **Author:** Gaia (Lead / Architect)
- **Date:** 2026-05-22
- **Status:** Applied (doc-only PR)

## Context

PR #119 (Loop-30) merged to `main` despite a `BLOCKED` verdict in Gaia's
`.squad/` history. Two gaps allowed it:

1. **Technical gap:** `main` had no GitHub branch protection. Closed by
   WI-loop31-process-B (PR #125, commit `6a27988`) — `build-test` is now
   required, linear history enforced, admins included, force-push and
   deletion forbidden.
2. **Procedural gap:** Gaia's `BLOCKED` verdict was never filed as a
   GitHub `CHANGES_REQUESTED` review, so the platform had no record of
   the objection. The merge button looked clean.

Protection alone does not close the procedural gap, because protection
has no opinion about design correctness — it only knows whether the
build is green. A Lead who writes `BLOCKED` in `.squad/` but never
calls `gh pr review --request-changes` produces a verdict that is
invisible to the merge button.

## Decision

1. **Charter binding.** `.squad/agents/gaia/charter.md` now contains a
   "Reviewer Discipline" section that makes the `verdict → gh pr review`
   handshake mandatory and orders it **before** any `.squad/` write:

   | Verdict                  | Required call                                                |
   |--------------------------|--------------------------------------------------------------|
   | `BLOCKED`                | `gh pr review {pr} --request-changes -b "{reasons}"`         |
   | `APPROVED`               | `gh pr review {pr} --approve -b "{rationale}"`               |
   | `APPROVE-WITH-COMMENTS`  | `gh pr review {pr} --comment -b "{observations}"`            |

2. **Reusable skill.** `.squad/skills/lead-reviewer-discipline/SKILL.md`
   documents the pattern, anti-patterns, revocation procedure, and
   cross-links to the coordinator-level Reviewer Rejection Protocol.
   Confidence is `medium` until the next real BLOCKED verdict re-applies
   it correctly.

3. **No coordinator-runbook duplication.** `.github/agents/squad.agent.md`
   already documents the orchestration-side "Reviewer Rejection Protocol"
   (lockout / reassign / escalate). This WI is the *agent-side*
   companion: what the Lead must do *on the PR itself* when they reject.
   The new skill cross-references the coordinator section rather than
   duplicating it.

## Trade-offs

- **Cost:** Every Lead verdict now requires a `gh` call before history
  writes. One extra command per review.
- **Benefit:** Verdicts become visible to the GitHub merge button, so a
  human or agent cannot merge over a `BLOCKED` verdict without first
  dismissing the review — which leaves an audit trail.
- **Alternative considered:** Require Lead approvals via branch
  protection (`required_pull_request_reviews`). Rejected for this
  single-maintainer repo because it deadlocks Gaia self-reviewing
  Gaia-authored PRs. Discipline + protection together is the right
  balance for current team size; revisit if a second human maintainer
  joins.

## Protection-Gate Observation

This PR is the second to land under the new protection regime
(WI-DEBT-04 / PR #126 was first). The verification script
`scripts/verify-main-protection.sh` returns `PASS` against the live
policy as of this WI. No protection misbehaviour observed.

## Follow-ups

- Next BLOCKED verdict re-applies the skill → bump confidence to `high`.
- If a second maintainer joins, revisit `required_pull_request_reviews`
  in the protection JSON.
