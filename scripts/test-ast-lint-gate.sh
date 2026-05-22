#!/bin/zsh
# scripts/test-ast-lint-gate.sh — smoke test for the WI-loop30-AST-buildsh-wire
# integration of the SwiftSyntax AST rule into `./build.sh lint`.
#
# Verifies three contracts:
#   1. Running `swiftlint-ast` directly against the *violating* fixture
#      exits non-zero (the rule fires).
#   2. Running `swiftlint-ast` directly against the *clean* fixture
#      exits zero (the rule does not over-fire).
#   3. Running `./build.sh lint` with the AST_LINT_PATHS_OVERRIDE env var
#      pointed at the violating fixture exits non-zero — proving the
#      `build.sh` lint gate actually surfaces the AST diagnostic and
#      treats it as a build failure (warnings-as-errors discipline).
#
# TDD note (loop directive #2): this script was written *before* the
# build.sh wiring so that contract #3 fails first, then passes once
# the wire-up lands.

set -uo pipefail

cd "$(dirname "$0")/.."
repo_root="$PWD"
fixtures_dir="$repo_root/tools/swiftlint-rules/Tests/Fixtures"
violating="$fixtures_dir/violating_toolbar.swift"
clean="$fixtures_dir/clean_toolbar.swift"

if ! command -v swift >/dev/null 2>&1; then
  echo "skip: swift toolchain not available — AST gate not testable on this host" >&2
  exit 0
fi

# SPM bare-repo allowlist (CI runners + local devs share this stance).
export GIT_CONFIG_COUNT="${GIT_CONFIG_COUNT:-1}"
export GIT_CONFIG_KEY_0="${GIT_CONFIG_KEY_0:-safe.bareRepository}"
export GIT_CONFIG_VALUE_0="${GIT_CONFIG_VALUE_0:-all}"

failures=0

echo "[1/3] AST CLI vs violating fixture (expect exit != 0)"
set +e
swift run --package-path tools/swiftlint-rules --quiet swiftlint-ast "$violating" >/tmp/ast-gate-violating.out 2>&1
rc=$?
set -e
if [[ $rc -eq 0 ]]; then
  echo "FAIL [1/3]: AST CLI accepted a known-violating toolbar fixture" >&2
  cat /tmp/ast-gate-violating.out >&2
  failures=$((failures + 1))
else
  echo "  ok (exit=$rc)"
fi

echo "[2/3] AST CLI vs clean fixture (expect exit == 0)"
set +e
swift run --package-path tools/swiftlint-rules --quiet swiftlint-ast "$clean" >/tmp/ast-gate-clean.out 2>&1
rc=$?
set -e
if [[ $rc -ne 0 ]]; then
  echo "FAIL [2/3]: AST CLI rejected a known-clean toolbar fixture (false positive)" >&2
  cat /tmp/ast-gate-clean.out >&2
  failures=$((failures + 1))
else
  echo "  ok (exit=0)"
fi

echo "[3/3] ./build.sh lint with AST_LINT_PATHS_OVERRIDE=violating (expect exit != 0)"
set +e
AST_LINT_PATHS_OVERRIDE="$violating" ./build.sh lint >/tmp/ast-gate-buildsh.out 2>&1
rc=$?
set -e
if [[ $rc -eq 0 ]]; then
  echo "FAIL [3/3]: ./build.sh lint did NOT surface AST violation as a non-zero exit" >&2
  cat /tmp/ast-gate-buildsh.out >&2
  failures=$((failures + 1))
else
  echo "  ok (exit=$rc)"
fi

if [[ $failures -gt 0 ]]; then
  echo "AST lint gate smoke test FAILED ($failures of 3 contracts violated)" >&2
  exit 1
fi
echo "AST lint gate smoke test PASSED (3/3 contracts)"
