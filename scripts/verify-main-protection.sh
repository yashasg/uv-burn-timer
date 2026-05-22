#!/usr/bin/env bash
# Verifies that GitHub branch protection on `main` matches the policy
# established by WI-loop31-process-B. Exits 0 on success, non-zero with a
# diagnostic message otherwise.
#
# Required tools: gh (authenticated), jq.

set -euo pipefail

REPO="${REPO:-yashasg/uv-burn-timer}"
BRANCH="${BRANCH:-main}"

if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: 'gh' CLI is required but not installed." >&2
  exit 2
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: 'jq' is required but not installed." >&2
  exit 2
fi

PROT_JSON="$(gh api "repos/${REPO}/branches/${BRANCH}/protection" 2>&1 || true)"

if echo "$PROT_JSON" | grep -q '"message": *"Branch not protected"'; then
  echo "FAIL: branch '${BRANCH}' has no protection configured." >&2
  exit 1
fi

check() {
  local label="$1" filter="$2" expected="$3"
  local actual
  actual="$(echo "$PROT_JSON" | jq -r "$filter")"
  if [[ "$actual" != "$expected" ]]; then
    echo "FAIL: ${label}: expected '${expected}', got '${actual}'" >&2
    return 1
  fi
  echo "OK:   ${label} = ${actual}"
}

fails=0
check "enforce_admins.enabled"                 '.enforce_admins.enabled'                 'true'  || fails=$((fails+1))
check "required_linear_history.enabled"        '.required_linear_history.enabled'        'true'  || fails=$((fails+1))
check "allow_force_pushes.enabled"             '.allow_force_pushes.enabled'             'false' || fails=$((fails+1))
check "allow_deletions.enabled"                '.allow_deletions.enabled'                'false' || fails=$((fails+1))
check "required_status_checks.strict"          '.required_status_checks.strict'          'true'  || fails=$((fails+1))
check "required_status_checks contains build-test" \
      '(.required_status_checks.contexts // []) | index("build-test") | tostring' \
      '0' || fails=$((fails+1))

if [[ $fails -ne 0 ]]; then
  echo "FAIL: ${fails} protection assertion(s) failed for ${REPO}@${BRANCH}." >&2
  exit 1
fi

echo "PASS: branch protection on ${REPO}@${BRANCH} matches policy."
