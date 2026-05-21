#!/usr/bin/env bash
# check-test-membership.sh — WI-j (CI test membership guard).
#
# Enforce: every `*Tests.swift` file under app/Tests/<TestTarget>/ MUST be
# declared in app/app.xcodeproj/project.pbxproj. Otherwise the file is
# silently dead — `swift test` (SPM) will run it but `xcodebuild test`
# (canonical build.sh path) will not, and CI will report "all tests passed"
# while never having seen the file.
#
# Also enforces the reverse: every Swift source under app/Sources/UVBurnTimerCore/
# MUST appear in the pbxproj. (App-target sources in app/Sources/UVBurnTimer/
# are similarly enforced.) The same dead-file trap that swallowed the test
# files would otherwise also swallow shipped source files such as
# ForecastProvider.swift.
#
# Origin: hero-card-wrapper-restore cycle (2026-05-21) discovered 53 dead
# `@Test` functions across 5 test files plus ForecastProvider.swift in the
# core source target.

set -euo pipefail

cd "$(dirname "$0")/.."

PBX="app/app.xcodeproj/project.pbxproj"
EXIT_CODE=0

check_dir() {
  local dir
  local label
  dir="$1"
  label="$2"

  if [[ ! -d "$dir" ]]; then
    return 0
  fi

  while IFS= read -r -d '' file; do
    local base
    base="$(basename "$file")"
    # Accept either `path = Foo.swift;` (relative path) or `path = "Foo.swift"`.
    if ! grep -qE "path = \"?${base}\"?;" "$PBX"; then
      echo "::error file=${file}::${label} '${base}' is on disk but not declared in ${PBX}. Add it to the project or delete the file."
      EXIT_CODE=1
    fi
  done < <(find "$dir" -maxdepth 1 -name '*.swift' -print0)
}

check_dir "app/Tests/UVBurnTimerCoreTests"  "Core test"
check_dir "app/Tests/UVBurnTimerUITests"    "UI test"
check_dir "app/Sources/UVBurnTimerCore"     "Core source"
check_dir "app/Sources/UVBurnTimer"         "App source"

if [[ $EXIT_CODE -eq 0 ]]; then
  echo "check-test-membership: all *.swift files under app/Tests and app/Sources are declared in $PBX"
else
  echo "" >&2
  echo "check-test-membership: FAILED — one or more Swift files are on disk but not in $PBX." >&2
  echo "These files would be silently invisible to xcodebuild and to ./build.sh." >&2
fi

exit $EXIT_CODE
