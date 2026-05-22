# Decision: Enable Branch Protection on `main`

- **WI:** WI-loop31-process-B
- **Author:** Gaia (Lead/Architect)
- **Date:** 2026-05-22
- **Status:** Applied

## Context

Loop-30 PR #119 merged to `main` via a direct path that bypassed the
intended PR + CI gate. Root cause: `main` had **no** GitHub branch
protection (`gh api .../branches/main/protection` returned 404). Any
authenticated maintainer (human or agent) could push directly to `main`
or merge a PR without CI passing.

This is a structural failure, not a behavioural one — no amount of
process discipline fixes a missing guardrail. We close it by configuring
the guardrail in GitHub itself.

## Decision

Apply the following protection to `main` via the GitHub REST API
(`PUT /repos/yashasg/uv-burn-timer/branches/main/protection`):

| Setting                              | Value           | Why |
|--------------------------------------|-----------------|-----|
| `required_status_checks.strict`      | `true`          | Branch must be up to date with `main` before merge — prevents "merge-skew" green checks. |
| `required_status_checks.contexts`    | `["build-test"]`| The `build-test` job in `.github/workflows/ci.yml` is the canonical gate (SwiftLint strict + `./build.sh`). Verified from recent PR check names. |
| `enforce_admins`                     | `true`          | Admins (incl. repo owner) must also obey. The bypass incident shows admin exemption is a known footgun. |
| `required_pull_request_reviews`      | `null`          | Single-maintainer repo. Squad self-reviews via Lead; requiring a second human would block all work. CI is the gate. |
| `restrictions`                       | `null`          | No push allowlist needed — gating is via PR + CI, not identity. |
| `allow_force_pushes`                 | `false`         | History on `main` is append-only. |
| `allow_deletions`                    | `false`         | `main` cannot be deleted. |
| `required_linear_history`            | `true`          | Squash/rebase merges only; no merge commits. Keeps `git log main` a clean audit trail for incident review. |

## Trade-offs (named, as the charter requires)

- **No human review requirement** → faster squad cadence, but loses the
  "second pair of eyes" effect. Mitigation: the CI gate (SwiftLint
  strict + full build + tests) is non-trivial, and the Lead reviews
  decision docs out-of-band.
- **Linear history required** → cannot merge-commit; contributors must
  rebase. For a squad working in short-lived feature branches this is a
  net win (clean `git bisect`); for long-lived branches it would be
  painful. We don't have long-lived branches.
- **`enforce_admins: true`** → owner cannot hotfix-push to `main` in an
  emergency. Disable command documented below.

## Verification

Run from repo root:

```bash
bash scripts/verify-main-protection.sh
```

Exits `0` and prints `PASS:` line when policy holds. Exits non-zero
with a `FAIL:` line per missing/incorrect field otherwise. Suitable for
periodic compliance checks or a future drift-detection workflow.

Sample passing output:

```
OK:   enforce_admins.enabled = true
OK:   required_linear_history.enabled = true
OK:   allow_force_pushes.enabled = false
OK:   allow_deletions.enabled = false
OK:   required_status_checks.strict = true
OK:   required_status_checks contains build-test = 0
PASS: branch protection on yashasg/uv-burn-timer@main matches policy.
```

## Emergency disable (break-glass)

If protection blocks a legitimate emergency (e.g., CI infrastructure
outage and a hotfix must land), remove protection temporarily:

```bash
gh api -X DELETE repos/yashasg/uv-burn-timer/branches/main/protection
```

Then land the fix and **immediately** re-apply protection by re-running
the `PUT` body documented in this file (also reproduced in the WI-loop31
PR description). Every break-glass use **must** be followed by a new
decision doc explaining why.

## Rollback

This change has no code-level rollback. To revert the policy, run the
`DELETE` above. The `scripts/verify-main-protection.sh` script will
then exit `1` ("Branch not protected"), which is the intended signal.
