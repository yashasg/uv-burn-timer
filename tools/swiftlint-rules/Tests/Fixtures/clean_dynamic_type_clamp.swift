// Fixture: passes `dynamic_type_clamp_below_ax5`.
// `.dynamicTypeSize(...)` extends to `.accessibility5` — every Dynamic
// Type user is supported. Partial-from / no-modifier forms are also OK.
import SwiftUI

struct CleanDynamicTypeClamp: View {
    var body: some View {
        Text("Important detail")
            .dynamicTypeSize(.xSmall ... .accessibility5)
    }
}
