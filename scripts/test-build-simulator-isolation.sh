#!/bin/zsh
# scripts/test-build-simulator-isolation.sh — WI-L32-02 contract test.
#
# Asserts that ./build.sh's simulator-selection routine resolves to a
# dedicated per-repo simulator (name prefix "UVBurnTimer-") rather than the
# first booted shared device. Without this isolation, concurrent xcodebuild
# runs from a sibling Xcode project (e.g. knitting-gauge-reconciler) bound to
# the same booted iPhone UDID steal foreground from the host app mid-XCUI,
# producing the WI-L32-01 "Test crashed with signal kill" symptom set.
#
# Contracts:
#   1. select_destination prints a destination whose id= references a
#      simulator named with the "UVBurnTimer-" prefix.
#   2. The function is idempotent — two invocations return the same UDID
#      (no duplicate dedicated devices are created).
#   3. The UV_BURN_TIMER_DISABLE_DEDICATED_SIM=1 escape hatch falls back to
#      the legacy shared-simulator selection (no "UVBurnTimer-" prefix
#      required) so CI hosts that cannot create devices are not broken.
#
# TDD note (loop directive #2): this script was authored alongside the
# build.sh dedicated-simulator wire-up so the contract above is observable
# and re-runnable.

set -uo pipefail

cd "$(dirname "$0")/.."

if ! command -v xcrun >/dev/null 2>&1; then
  echo "skip: xcrun not available — simulator isolation not testable on this host" >&2
  exit 0
fi

if ! xcrun simctl help >/dev/null 2>&1; then
  echo "skip: simctl not available — simulator isolation not testable on this host" >&2
  exit 0
fi

# Extract the simulator-selection helpers from build.sh without executing the
# top-level build pipeline. We pull every line from the "Simulator
# destination" section header up to (and including) the closing brace of
# `select_destination`.
helpers="$(mktemp -t uvbt-simiso-helpers.XXXXXX)"
trap 'rm -f "$helpers"' EXIT INT TERM

awk '
  /^# Simulator destination/ { state = "in_block"; print; next }
  state == "in_block" {
    print
    if (/^select_destination\(\)/) { in_func = 1 }
    if (in_func && /^}$/) { exit }
  }
' build.sh > "$helpers"

if ! grep -q '^select_destination()' "$helpers"; then
  echo "FAIL: could not extract select_destination from build.sh" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$helpers"

echo "Contract 1: select_destination resolves to a UVBurnTimer-* dedicated simulator..."
dest1="$(select_destination 2>/dev/null)"
if [[ -z "$dest1" ]]; then
  echo "FAIL: select_destination produced empty output" >&2
  exit 1
fi
if [[ "$dest1" != *"platform=iOS Simulator,id="* ]]; then
  echo "FAIL: destination missing id= form: $dest1" >&2
  exit 1
fi
udid1="${dest1#*id=}"
udid1="${udid1%%,*}"
if [[ ${#udid1} -ne 36 ]]; then
  echo "FAIL: udid not 36 chars: $udid1" >&2
  exit 1
fi
sim_name="$(xcrun simctl list devices | awk -v id="$udid1" '
  index($0, "(" id ")") {
    if (match($0, /^[[:space:]]+/)) {
      line = substr($0, RLENGTH + 1)
      if (match(line, / \([0-9A-F-]{36}\)/)) {
        print substr(line, 1, RSTART - 1)
      }
    }
    exit
  }
')"
if [[ "$sim_name" != UVBurnTimer-* ]]; then
  echo "FAIL: dedicated sim contract — udid $udid1 maps to name '$sim_name' (expected UVBurnTimer-* prefix)" >&2
  exit 1
fi
echo "  OK: $sim_name ($udid1)"

echo "Contract 2: select_destination is idempotent..."
dest2="$(select_destination 2>/dev/null)"
udid2="${dest2#*id=}"
udid2="${udid2%%,*}"
if [[ "$udid1" != "$udid2" ]]; then
  echo "FAIL: not idempotent — udid drifted from $udid1 to $udid2" >&2
  exit 1
fi
echo "  OK: stable udid"

echo "Contract 3: UV_BURN_TIMER_DISABLE_DEDICATED_SIM=1 falls back to shared selection..."
dest3="$(UV_BURN_TIMER_DISABLE_DEDICATED_SIM=1 select_destination 2>/dev/null)"
if [[ -z "$dest3" ]]; then
  echo "FAIL: opt-out fallback produced empty destination" >&2
  exit 1
fi
echo "  OK: opt-out fallback returned: $dest3"

echo "All WI-L32-02 simulator isolation contracts pass."
