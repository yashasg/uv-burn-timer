#!/bin/zsh
# build.sh - Canonical build, lint, and test entry point.
# Treat warnings as errors and fail on any warning.
#
# Usage:
#   ./build.sh        # HIG lint gate + build/test cycle
#   ./build.sh lint   # local SwiftLint pass with emoji reporter
#
# CI env vars (set by GitHub Actions / GitLab webhook bridge):
#   CONFIGURATION        Build configuration to use (default: derives from CI_MODE)
#   TEST_CONFIGURATION   Configuration used for the test run (default: Debug)
#   DERIVED_DATA_PATH    DerivedData path (default: UV_BURN_TIMER_DERIVED_DATA_PATH or .build/derived-data)
#   RUN_TESTS            "true"/"false" — whether to run the test suite (default: true)
#   PLATFORM_MODE        "iphone" selects the default stable iPhone simulator
#   RUN_ANALYZE          reserved, not yet used
#   RUN_SWIFT_FORMAT     reserved; swift-format is handled separately by CI
#
# Local dev env vars (legacy, still honoured):
#   UV_BURN_TIMER_DESTINATION      explicit xcodebuild destination string
#   UV_BURN_TIMER_DERIVED_DATA_PATH

set -euo pipefail

command_mode="${1:-build}"

case "$command_mode" in
  build|lint)
    ;;
  *)
    echo "Usage: ./build.sh [lint]" >&2
    exit 64
    ;;
esac

run_swiftlint() {
  local reporter="$1"
  shift

  if ! command -v swiftlint >/dev/null 2>&1; then
    echo "warning: SwiftLint not installed; skipping lint gate. Install with 'brew install swiftlint' for local HIG linting." >&2
    return 0
  fi

  swiftlint "$@" --config .swiftlint.yml --reporter "$reporter"
}

# WI-loop30-AST-buildsh-wire: SwiftSyntax AST gate.
# Belt-and-braces with the regex SwiftLint rules — both gates run for
# this PR. ADR-0003 §Rollout WI-30-A: the regex rule for
# `toolbar_image_needs_scaled_frame` stays in `.swiftlint.yml` while
# the AST rule beds in for one CI cycle.
#
# Skips gracefully when `swift` is not on PATH (parity with the
# SwiftLint-not-installed skip in `run_swiftlint`). CI runners that
# do not provision a Swift toolchain (rare for this iOS repo) will
# log a warning rather than fail.
#
# Test hook: AST_LINT_PATHS_OVERRIDE lets `scripts/test-ast-lint-gate.sh`
# point the gate at a known-violating fixture to assert non-zero exit.
run_swiftlint_ast() {
  if ! command -v swift >/dev/null 2>&1; then
    echo "warning: swift toolchain not on PATH; skipping AST lint gate. AST rules require Swift 6.0+ for SPM resolution." >&2
    return 0
  fi

  local ast_paths
  if [[ -n "${AST_LINT_PATHS_OVERRIDE:-}" ]]; then
    ast_paths="$AST_LINT_PATHS_OVERRIDE"
  else
    ast_paths="app/Sources"
  fi

  # SPM bare-repo allowlist — DerivedData SPM checkouts trip git's
  # `safe.bareRepository=explicit` default on some CI images. Scoped
  # to this subshell only.
  echo "Running SwiftSyntax AST lint gate against: $ast_paths"
  set +e
  GIT_CONFIG_COUNT="${GIT_CONFIG_COUNT:-1}" \
  GIT_CONFIG_KEY_0="${GIT_CONFIG_KEY_0:-safe.bareRepository}" \
  GIT_CONFIG_VALUE_0="${GIT_CONFIG_VALUE_0:-all}" \
  swift run --package-path tools/swiftlint-rules --quiet swiftlint-ast $(find $ast_paths -name "*.swift" -type f 2>/dev/null)
  local ast_rc=$?
  set -e

  if [[ $ast_rc -ne 0 ]]; then
    echo "error: SwiftSyntax AST lint gate failed (exit=$ast_rc). See diagnostics above. ADR-0003 / WI-loop30-AST-buildsh-wire." >&2
    exit "$ast_rc"
  fi
  echo "AST lint gate: 0 violations."
}

if [[ "$command_mode" == "lint" ]]; then
  run_swiftlint emoji
  run_swiftlint_ast
  exit 0
fi

# ---------------------------------------------------------------------------
# Env var resolution
# ---------------------------------------------------------------------------

# Derived data: CI passes DERIVED_DATA_PATH; local dev uses UV_BURN_TIMER_DERIVED_DATA_PATH
derived_data_path="${DERIVED_DATA_PATH:-${UV_BURN_TIMER_DERIVED_DATA_PATH:-.build/derived-data}}"
mkdir -p "$(dirname "$derived_data_path")"

# ---------------------------------------------------------------------------
# WI-j: project membership guard.
# Fail fast (before any compilation) when a *.swift source or test file is on
# disk but missing from app/app.xcodeproj/project.pbxproj. Such files would
# be silently ignored by xcodebuild and produce a misleading "all tests
# passed" CI result.
# ---------------------------------------------------------------------------
"$(dirname "$0")/scripts/check-test-membership.sh"

# Build configuration(s) to run.
# When CONFIGURATION is set (CI mode), run only that one configuration.
# When not set (local dev), run Debug build + tests + Release build to match
# the full local validation cycle.
ci_configuration="${CONFIGURATION:-}"
test_configuration="${TEST_CONFIGURATION:-Debug}"
run_tests="${RUN_TESTS:-true}"

# ---------------------------------------------------------------------------
# SwiftLint gate
# ---------------------------------------------------------------------------

echo "Running SwiftLint HIG gate..."
run_swiftlint xcode --strict
run_swiftlint_ast

# ---------------------------------------------------------------------------
# Simulator destination
# ---------------------------------------------------------------------------

select_destination() {
  local device_id
  local booted_devices
  booted_devices="$(xcrun simctl list devices booted)"

  if [[ "$booted_devices" =~ "^[[:space:]]+.+ \([0-9A-F-]{36}\) \(Booted\)" ]]; then
    device_id="$(
      awk '
        /^[[:space:]]+.+ \([0-9A-F-]{36}\) \(Booted\)/ && !found {
          if (match($0, /\([0-9A-F-]{36}\)/)) {
            print substr($0, RSTART + 1, 36)
            found = 1
          }
        }
      ' <<< "$booted_devices"
    )"
    echo "platform=iOS Simulator,id=$device_id,arch=arm64"
    return
  fi

  local available_devices
  available_devices="$(xcrun simctl list devices available)"

  local xcode_major
  local xcode_version_output
  xcode_version_output="$(xcodebuild -version)"
  xcode_major="$(awk '/^Xcode / && !found { split($2, parts, "."); print parts[1]; found = 1 }' <<< "$xcode_version_output")"

  local -a preferred_devices
  if [[ -n "$xcode_major" && "$xcode_major" -lt 26 ]]; then
    # Xcode 16.4 on GitHub's macOS 15 image can list iPhone 17 Pro
    # (iPhone18,1/iOS 26) but actool cannot resolve that device's trait set.
    preferred_devices=("iPhone 16 Pro" "iPhone 16" "iPhone 15")
  else
    preferred_devices=("iPhone 17 Pro" "iPhone 16 Pro" "iPhone 16" "iPhone 15")
  fi

  local preferred_device
  for preferred_device in "${preferred_devices[@]}"; do
    if [[ "$available_devices" == *"$preferred_device ("* ]]; then
      device_id="$(
        awk -v device="$preferred_device" '
          index($0, device " (") && !found {
            if (match($0, /\([0-9A-F-]{36}\)/)) {
              print substr($0, RSTART + 1, 36)
              found = 1
            }
          }
        ' <<< "$available_devices"
      )"
      echo "platform=iOS Simulator,id=$device_id,arch=arm64"
      return
    fi
  done

  echo "platform=iOS Simulator,name=${preferred_devices[-1]},OS=latest"
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
        -parallel-testing-enabled NO \
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

  # WI-bundleQ / Gaia L13d (Loop-13) — honor RUN_TESTS in the local-dev
  # branch too. Previously this block ran tests unconditionally even when
  # the documented `RUN_TESTS=false` env var was set, contradicting the
  # header contract on line 9 and producing a misleading dev experience.
  if [[ "$run_tests" == "true" ]]; then
    run_xcodebuild test.log \
      xcodebuild -project app/app.xcodeproj \
        -derivedDataPath "$derived_data_path" \
        -scheme UVBurnTimer \
        -configuration Debug \
        -destination "$destination" \
        -parallel-testing-enabled NO \
        SWIFT_TREAT_WARNINGS_AS_ERRORS=YES \
        GCC_TREAT_WARNINGS_AS_ERRORS=YES \
        OTHER_SWIFT_FLAGS="-warnings-as-errors" \
        test
  fi

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
