#!/bin/zsh
# build.sh - Canonical build and test entry point.
# Treat warnings as errors and fail on any warning.

set -euo pipefail

select_destination() {
  local preferred_device="iPhone 17 Pro"
  local available_devices
  available_devices="$(xcrun simctl list devices available)"
  local device_id

  if grep -Fq "$preferred_device (" <<< "$available_devices"; then
    device_id="$(grep -F "$preferred_device (" <<< "$available_devices" | head -n 1 | sed -E 's/.*\(([0-9A-F-]{36})\).*/\1/')"
    echo "platform=iOS Simulator,id=$device_id"
    return
  fi

  device_id="$(grep -m 1 'iPhone.*([0-9A-F-]\{36\})' <<< "$available_devices" | sed -E 's/.*\(([0-9A-F-]{36})\).*/\1/')"
  if [[ -n "$device_id" ]]; then
    echo "platform=iOS Simulator,id=$device_id"
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

run_xcodebuild release-build.log \
  xcodebuild -project app/UVBurnTimer.xcodeproj \
  -scheme UVBurnTimer \
  -configuration Release \
  -destination "$destination" \
  SWIFT_TREAT_WARNINGS_AS_ERRORS=YES \
  GCC_TREAT_WARNINGS_AS_ERRORS=YES \
  OTHER_SWIFT_FLAGS="-warnings-as-errors" \
  build

echo "Build and tests completed."
