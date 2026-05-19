import SwiftUI
import UVBurnTimerCore

@main
struct UVBurnTimerApp: App {
    @State private var session = UVBurnTimerSession()
    @State private var showDisclaimer = true

    var body: some Scene {
        WindowGroup {
            RootView(session: $session, showDisclaimer: $showDisclaimer)
                .disclaimerPresentation(isPresented: $showDisclaimer) {
                    DisclaimerCover {
                        session.acknowledgedDisclaimer = true
                        showDisclaimer = false
                    }
                }
                .skinTypePresentation(
                    isPresented: Binding(
                        get: { !showDisclaimer && session.selectedSkinType == nil },
                        set: { _ in }
                    )
                ) {
                    SkinTypeOnboardingView(session: $session)
                }
        }
    }
}

private extension View {
    @ViewBuilder
    func disclaimerPresentation<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        #if os(macOS)
        sheet(isPresented: isPresented, content: content)
        #else
        fullScreenCover(isPresented: isPresented, content: content)
        #endif
    }

    @ViewBuilder
    func skinTypePresentation<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        #if os(macOS)
        sheet(isPresented: isPresented, content: content)
        #else
        fullScreenCover(isPresented: isPresented, content: content)
        #endif
    }
}
