#!/bin/zsh
# build.sh - Canonical build and test entry point.
# Treat warnings as errors and fail on any warning.
#
# CI env vars (set by GitHub Actions / GitLab webhook bridge):
#   CONFIGURATION        Build configuration to use (default: derives from CI_MODE)
#   TEST_CONFIGURATION   Configuration used for the test run (default: Debug)
#   DERIVED_DATA_PATH    DerivedData path (default: UV_BURN_TIMER_DERIVED_DATA_PATH or mktemp)
#   RUN_TESTS            "true"/"false" — whether to run the test suite (default: true)
#   PLATFORM_MODE        "iphone" selects iPhone 17 Pro simulator (default)
#   RUN_ANALYZE          reserved, not yet used
#   RUN_SWIFT_FORMAT     reserved; swift-format is handled separately by CI
#
# Local dev env vars (legacy, still honoured):
#   UV_BURN_TIMER_DESTINATION      explicit xcodebuild destination string
#   UV_BURN_TIMER_DERIVED_DATA_PATH

set -euo pipefail

# ---------------------------------------------------------------------------
# Env var resolution
# ---------------------------------------------------------------------------

# Derived data: CI passes DERIVED_DATA_PATH; local dev uses UV_BURN_TIMER_DERIVED_DATA_PATH
derived_data_path="${DERIVED_DATA_PATH:-${UV_BURN_TIMER_DERIVED_DATA_PATH:-}}"
if [[ -z "$derived_data_path" ]]; then
  derived_data_path="$(mktemp -d "${TMPDIR:-/tmp}/uv-burn-timer-derived-data.XXXXXX")"
fi

# Build configuration(s) to run.
# When CONFIGURATION is set (CI mode), run only that one configuration.
# When not set (local dev), run Debug build + tests + Release build to match
# the full local validation cycle.
ci_configuration="${CONFIGURATION:-}"
test_configuration="${TEST_CONFIGURATION:-Debug}"
run_tests="${RUN_TESTS:-true}"

# ---------------------------------------------------------------------------
# Simulator destination
# ---------------------------------------------------------------------------

select_destination() {
  local preferred_device="iPhone 17 Pro"
  local available_devices
  available_devices="$(xcrun simctl list devices available)"
  local device_id

  if grep -Fq "$preferred_device (" <<< "$available_devices"; then
    device_id="$(grep -F "$preferred_device (" <<< "$available_devices" | head -n 1 | sed -E 's/.*\(([0-9A-F-]{36})\).*/\1/')"
    echo "platform=iOS Simulator,id=$device_id,arch=arm64"
    return
  fi

  echo "platform=iOS Simulator,name=$preferred_device,OS=latest"
}

destination="${UV_BURN_TIMER_DESTINATION:-$(select_destination)}"
echo "Using destination: $destination"
echo "Using derived data: $derived_data_path"
[[ -n "$ci_configuration" ]] && echo "CI mode: CONFIGURATION=$ci_configuration TEST_CONFIGURATION=$test_configuration RUN_TESTS=$run_tests"

# ---------------------------------------------------------------------------
# Build helper
# ---------------------------------------------------------------------------

run_xcodebuild() {
  local log_file="$1"
  shift

  rm -f "$log_file"
  set +e
  "$@" > "$log_file" 2>&1
  local command_status=$?
  set -e

  cat "$log_file"

  if [[ $command_status -ne 0 ]]; then
    exit "$command_status"
  fi

  if grep -Eiq '(^|[^[:alpha:]])warning:' "$log_file"; then
    echo "Build failed because warnings were emitted in $log_file." >&2
    grep -Ein 'warning:' "$log_file" >&2
    exit 1
  fi
}

# ---------------------------------------------------------------------------
# Build and test
# ---------------------------------------------------------------------------

if [[ -n "$ci_configuration" ]]; then
  # CI mode: run exactly the requested configuration.
  run_xcodebuild build.log \
    xcodebuild -project app/app.xcodeproj \
      -derivedDataPath "$derived_data_path" \
      -scheme UVBurnTimer \
      -configuration "$ci_configuration" \
      -destination "$destination" \
      SWIFT_TREAT_WARNINGS_AS_ERRORS=YES \
      GCC_TREAT_WARNINGS_AS_ERRORS=YES \
      OTHER_SWIFT_FLAGS="-warnings-as-errors" \
      build

  if [[ "$run_tests" == "true" ]]; then
    run_xcodebuild test.log \
      xcodebuild -project app/app.xcodeproj \
        -derivedDataPath "$derived_data_path" \
        -scheme UVBurnTimer \
        -configuration "$test_configuration" \
        -destination "$destination" \
        SWIFT_TREAT_WARNINGS_AS_ERRORS=YES \
        GCC_TREAT_WARNINGS_AS_ERRORS=YES \
        OTHER_SWIFT_FLAGS="-warnings-as-errors" \
        test
  fi
else
  # Local dev mode: full cycle — Debug build, tests, Release build.
  run_xcodebuild build.log \
    xcodebuild -project app/app.xcodeproj \
      -derivedDataPath "$derived_data_path" \
      -scheme UVBurnTimer \
      -configuration Debug \
      -destination "$destination" \
      SWIFT_TREAT_WARNINGS_AS_ERRORS=YES \
      GCC_TREAT_WARNINGS_AS_ERRORS=YES \
      OTHER_SWIFT_FLAGS="-warnings-as-errors" \
      build

  run_xcodebuild test.log \
    xcodebuild -project app/app.xcodeproj \
      -derivedDataPath "$derived_data_path" \
      -scheme UVBurnTimer \
      -configuration Debug \
      -destination "$destination" \
      SWIFT_TREAT_WARNINGS_AS_ERRORS=YES \
      GCC_TREAT_WARNINGS_AS_ERRORS=YES \
      OTHER_SWIFT_FLAGS="-warnings-as-errors" \
      test

  run_xcodebuild release-build.log \
    xcodebuild -project app/app.xcodeproj \
      -derivedDataPath "$derived_data_path" \
      -scheme UVBurnTimer \
      -configuration Release \
      -destination "$destination" \
      SWIFT_TREAT_WARNINGS_AS_ERRORS=YES \
      GCC_TREAT_WARNINGS_AS_ERRORS=YES \
      OTHER_SWIFT_FLAGS="-warnings-as-errors" \
      build
fi

echo "Build and tests completed."
