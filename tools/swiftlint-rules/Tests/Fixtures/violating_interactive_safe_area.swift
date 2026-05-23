// Fixture: violates `interactive_inside_ignores_safe_area`.
// A Button sits inside a VStack that calls `.ignoresSafeArea()` with
// no `.safeAreaPadding(...)` / `.safeAreaInset(...)` / `.padding(...)`
// restoring the safe area for the tap target — the home-indicator
// region can swallow taps.
import SwiftUI

struct ViolatingSafeArea: View {
    var body: some View {
        VStack {
            Spacer()
            Button("Continue") { }
        }
        .ignoresSafeArea()
    }
}
