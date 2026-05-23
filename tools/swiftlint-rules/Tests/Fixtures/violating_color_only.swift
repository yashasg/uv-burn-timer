// Fixture: violates `color_only_meaning_signal`.
// A primitive Shape colored to convey state with no a11y label and
// no SF Symbol / Text identity. VoiceOver users get nothing.
import SwiftUI

struct ViolatingColorOnly: View {
    var body: some View {
        HStack {
            Circle()
                .frame(width: 12, height: 12)
                .foregroundStyle(.red)
            Text("System status")
        }
    }
}
