// Fixture: passes `interactive_inside_ignores_safe_area`.
// The VStack ignores safe area for background art, but the Button is
// individually `.padding(.bottom, 24)`-restored — the tap target sits
// above the home-indicator region.
import SwiftUI

struct CleanSafeArea: View {
    var body: some View {
        VStack {
            Spacer()
            Button("Continue") { }
                .padding(.bottom, 24)
        }
        .ignoresSafeArea()
    }
}
