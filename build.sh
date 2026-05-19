#!/bin/zsh
# build.sh - Build script for iOS app
# Treat warnings as errors, run tests, and fail on any warning.

set -euo pipefail

# Example: xcodebuild with warnings as errors (customize as needed)
xcodebuild -workspace app/UVBurnTimer.xcworkspace -scheme UVBurnTimer -configuration Release \
  -derivedDataPath build \
  OTHER_SWIFT_FLAGS="-warnings-as-errors" \
  | tee build.log

# Run tests (fail on any warning)
xcodebuild test -workspace app/UVBurnTimer.xcworkspace -scheme UVBurnTimer -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  OTHER_SWIFT_FLAGS="-warnings-as-errors" \
  | tee test.log

echo "Build and tests completed."
