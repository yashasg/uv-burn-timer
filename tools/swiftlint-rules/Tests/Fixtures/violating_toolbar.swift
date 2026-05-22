// WI-loop30-AST-buildsh-wire fixture — INTENTIONALLY violating.
// A bare `Image(...)` inside a `.toolbar { ... }` closure with no
// `.frame(min*:)` and no `.imageScale(...)` floor. The AST rule
// `toolbar_image_needs_scaled_frame` MUST fire on this file so the
// build-gate smoke test can prove the gate surfaces non-zero exit.
//
// Do NOT add a @ScaledMetric-backed floor here — that would defeat
// the purpose of this fixture. This file lives under tools/ and is
// excluded from the xcodebuild app target's Sources/.

import SwiftUI

struct ViolatingFixtureView: View {
    var body: some View {
        NavigationStack {
            Text("hello")
                .toolbar {
                    Image(systemName: "gear")
                }
        }
    }
}
