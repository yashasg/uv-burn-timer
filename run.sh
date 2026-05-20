#!/usr/bin/env bash
# Build and run UVBurnTimer on the iPhone 17 Pro simulator.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"

scheme="UVBurnTimer"
project="app/app.xcodeproj"
configuration="${CONFIGURATION:-Debug}"
preferred_device="iPhone 17 Pro"
derived_data_path="${DERIVED_DATA_PATH:-${UV_BURN_TIMER_DERIVED_DATA_PATH:-$script_dir/.build/DerivedData}}"

device_id=""
destination=""

select_device() {
    device_id="$(xcrun simctl list devices available | awk -v name="$preferred_device" '
        index($0, name " (") {
            if (match($0, /\([0-9A-Fa-f-]{36}\)/)) {
                print substr($0, RSTART + 1, RLENGTH - 2)
                exit
            }
        }
    ')"

    if [[ -z "$device_id" ]]; then
        echo "error: $preferred_device simulator is not available." >&2
        echo "Install an iOS Simulator runtime that includes $preferred_device, then retry." >&2
        exit 1
    fi

    destination="platform=iOS Simulator,id=$device_id,arch=arm64"
}

build_settings_value() {
    local key="$1"
    xcodebuild -project "$project" \
        -scheme "$scheme" \
        -configuration "$configuration" \
        -destination "$destination" \
        -derivedDataPath "$derived_data_path" \
        -showBuildSettings 2>/dev/null \
        | awk -F'= ' -v key="$key" '$1 ~ "^[[:space:]]*" key "[[:space:]]*$" { print $2; exit }'
}

resolve_app_path() {
    local target_build_dir
    local full_product_name

    target_build_dir="$(build_settings_value TARGET_BUILD_DIR)"
    full_product_name="$(build_settings_value FULL_PRODUCT_NAME)"

    if [[ -z "$target_build_dir" || -z "$full_product_name" ]]; then
        echo "error: could not resolve built .app path from xcodebuild settings." >&2
        exit 1
    fi

    printf '%s/%s\n' "$target_build_dir" "$full_product_name"
}

bundle_identifier_for_app() {
    local app_path="$1"
    local bundle_id

    bundle_id="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app_path/Info.plist" 2>/dev/null || true)"
    if [[ -z "$bundle_id" ]]; then
        bundle_id="$(build_settings_value PRODUCT_BUNDLE_IDENTIFIER)"
    fi

    if [[ -z "$bundle_id" ]]; then
        echo "error: could not resolve bundle identifier." >&2
        exit 1
    fi

    printf '%s\n' "$bundle_id"
}

boot_simulator() {
    echo "Booting $preferred_device if needed..."
    if ! xcrun simctl boot "$device_id" 2>/dev/null; then
        if ! xcrun simctl list devices "$device_id" | grep -q '(Booted)'; then
            echo "error: failed to boot $preferred_device ($device_id)." >&2
            exit 1
        fi
    fi
    xcrun simctl bootstatus "$device_id" -b >/dev/null
}

select_device
app_path="$(resolve_app_path)"

if [[ "${1:-}" == "--print-app-path" ]]; then
    printf '%s\n' "$app_path"
    exit 0
fi

echo "Building $scheme ($configuration)..."
DERIVED_DATA_PATH="$derived_data_path" \
UV_BURN_TIMER_DERIVED_DATA_PATH="$derived_data_path" \
CONFIGURATION="$configuration" \
RUN_TESTS="${RUN_TESTS:-false}" \
UV_BURN_TIMER_DESTINATION="$destination" \
    ./build.sh

if [[ ! -d "$app_path" ]]; then
    echo "error: built app was not found at $app_path" >&2
    exit 1
fi

boot_simulator

bundle_id="$(bundle_identifier_for_app "$app_path")"

echo "Installing $app_path..."
xcrun simctl install "$device_id" "$app_path"

echo "Launching $bundle_id..."
xcrun simctl launch "$device_id" "$bundle_id"

echo "Launched on $preferred_device."
