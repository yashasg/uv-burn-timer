// Fixture: passes `color_only_meaning_signal`.
// The colored Circle is wrapped in an HStack whose parent carries
// `.accessibilityElement(children: .combine)` + `.accessibilityLabel`,
// so VoiceOver announces the combined meaning. Sibling Text alone is
// not a silencer; the explicit a11y modifier is.
import SwiftUI

struct CleanColorOnly: View {
    var body: some View {
        HStack {
            Circle()
                .frame(width: 12, height: 12)
                .foregroundStyle(.red)
            Text("Critical")
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("System status: critical")
    }
}
