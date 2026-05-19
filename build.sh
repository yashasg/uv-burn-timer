#!/bin/zsh
# build.sh - Canonical build and test entry point.
# Treat warnings as errors and fail on any warning.

set -euo pipefail

select_destination() {
  local preferred_device="iPhone 17 Pro"
  local available_devices
  available_devices="$(xcrun simctl list devices available)"

  if grep -Fq "$preferred_device (" <<< "$available_devices"; then
    echo "platform=iOS Simulator,name=$preferred_device"
    return
  fi

  local fallback_device
  fallback_device="$(awk -F '[()]' '/iPhone/ { gsub(/^[ \t]+|[ \t]+$/, "", $1); print $1; exit }' <<< "$available_devices")"
  if [[ -n "$fallback_device" ]]; then
    echo "platform=iOS Simulator,name=$fallback_device"
    return
  fi

  echo "platform=iOS Simulator,OS=latest"
}

run_xcodebuild() {
  local log_file="$1"
  shift

  rm -f "$log_file"
  "$@" 2>&1 | tee "$log_file"

  if grep -Eiq '(^|[^[:alpha:]])warning:' "$log_file"; then
    echo "Build failed because warnings were emitted in $log_file." >&2
    grep -Ein 'warning:' "$log_file" >&2
    exit 1
  fi
}

destination="${UV_BURN_TIMER_DESTINATION:-$(select_destination)}"
echo "Using destination: $destination"

run_xcodebuild build.log \
  xcodebuild -project app/UVBurnTimer.xcodeproj \
    -scheme UVBurnTimer \
    -configuration Debug \
    -destination "$destination" \
    SWIFT_TREAT_WARNINGS_AS_ERRORS=YES \
    GCC_TREAT_WARNINGS_AS_ERRORS=YES \
    OTHER_SWIFT_FLAGS="-warnings-as-errors" \
    build

run_xcodebuild test.log \
  xcodebuild -project app/UVBurnTimer.xcodeproj \
  -scheme UVBurnTimer \
  -configuration Debug \
  -destination "$destination" \
  SWIFT_TREAT_WARNINGS_AS_ERRORS=YES \
  GCC_TREAT_WARNINGS_AS_ERRORS=YES \
  OTHER_SWIFT_FLAGS="-warnings-as-errors" \
  test

echo "Build and tests completed."
