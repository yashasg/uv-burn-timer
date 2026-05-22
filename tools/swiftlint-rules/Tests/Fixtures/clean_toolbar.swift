// WI-loop30-AST-buildsh-wire fixture — INTENTIONALLY CLEAN.
// A toolbar Image with a `@ScaledMetric`-backed `.frame(minWidth:,
// minHeight:)` floor. The AST rule `toolbar_image_needs_scaled_frame`
// MUST NOT fire here. Used by the build-gate smoke test to prove
// the gate is not over-broad (false-positive on a compliant input
// would block legitimate work).

import SwiftUI

struct CleanFixtureView: View {
    @ScaledMetric private var minTap: CGFloat = 44

    var body: some View {
        NavigationStack {
            Text("hello")
                .toolbar {
                    Image(systemName: "gear")
                        .frame(minWidth: minTap, minHeight: minTap)
                }
        }
    }
}
