import SwiftUI
import UVBurnTimerCore

@main
struct UVBurnTimerApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var session = UVBurnTimerSession()
    @State private var showDisclaimer = true
    @State private var requiresForegroundReattestation = false

    var body: some Scene {
        WindowGroup {
            RootView(session: $session)
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
                .onChange(of: scenePhase) { _, newPhase in
                    handleScenePhaseChange(newPhase)
                }
        }
    }

    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            guard DisclaimerReattestationPolicy.shouldPresentOnForeground(
                returnedFromBackground: requiresForegroundReattestation,
                acknowledgedDisclaimer: session.acknowledgedDisclaimer
            ) else {
                requiresForegroundReattestation = false
                return
            }

            session.acknowledgedDisclaimer = false
            showDisclaimer = true
            requiresForegroundReattestation = false
        case .background:
            requiresForegroundReattestation = true
        case .inactive:
            break
        @unknown default:
            break
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
