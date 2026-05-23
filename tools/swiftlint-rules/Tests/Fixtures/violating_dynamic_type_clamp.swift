// Fixture: violates `dynamic_type_clamp_below_ax5`.
// `.dynamicTypeSize(...)` clamps the type range below `.accessibility5`,
// excluding Dynamic Type users at AX4–AX5 from reading the content.
import SwiftUI

struct ViolatingDynamicTypeClamp: View {
    var body: some View {
        Text("Important detail")
            .dynamicTypeSize(.xSmall ... .accessibility3)
    }
}
