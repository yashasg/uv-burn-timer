import SwiftUI
import UVBurnTimerCore

@main
struct UVBurnTimerApp: App {
    @State private var session = UVBurnTimerSession()
    @State private var showDisclaimer = true
    @State private var showSkinTypeOnboarding = false

    init() {
        #if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-uiTestResetDefaults") {
            UserDefaults.standard.removeObject(forKey: "lastRoundedCoordinate")
            UserDefaults.standard.removeObject(forKey: "lastUVSnapshot")
        }
        if arguments.contains("-uiTestCorruptRoundedCoordinate") {
            UserDefaults.standard.set("not-json", forKey: "lastRoundedCoordinate")
        }
        if arguments.contains("-uiTestSavedRoundedCoordinate") {
            UserDefaults.standard.set(
                #"{"roundedCoordinate":{"latitude":37.77,"longitude":-122.42}}"#,
                forKey: "lastRoundedCoordinate"
            )
        }
        if arguments.contains("-uiTestStaleEstimate") {
            _session = State(
                initialValue: UVBurnTimerSession(
                    selectedSkinType: .typeI,
                    selectedSPF: .none,
                    acknowledgedDisclaimer: true
                ))
            _showDisclaimer = State(initialValue: false)
        }
        if arguments.contains("-uiTestCappedEstimate") {
            _session = State(
                initialValue: UVBurnTimerSession(
                    selectedSkinType: .typeIII,
                    selectedSPF: .spf30,
                    acknowledgedDisclaimer: true
                ))
            _showDisclaimer = State(initialValue: false)
        }
        if arguments.contains("-uiTestLongUncappedEstimate") {
            _session = State(
                initialValue: UVBurnTimerSession(
                    selectedSkinType: .typeIII,
                    selectedSPF: .none,
                    acknowledgedDisclaimer: true
                ))
            _showDisclaimer = State(initialValue: false)
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView(session: $session, showDisclaimer: $showDisclaimer)
                .disclaimerPresentation(
                    isPresented: $showDisclaimer,
                    onDismiss: presentSkinTypeOnboardingIfNeeded
                ) {
                    DisclaimerCover {
                        session.acknowledgedDisclaimer = true
                        showDisclaimer = false
                    }
                }
                .skinTypePresentation(isPresented: $showSkinTypeOnboarding) {
                    SkinTypeOnboardingView(session: $session)
                }
                .onAppear(perform: presentSkinTypeOnboardingIfNeeded)
                .onChange(of: session.selectedSkinType) { _, selectedSkinType in
                    if selectedSkinType == nil {
                        presentSkinTypeOnboardingIfNeeded()
                    } else {
                        showSkinTypeOnboarding = false
                    }
                }
        }
    }

    private func presentSkinTypeOnboardingIfNeeded() {
        guard !showDisclaimer, session.selectedSkinType == nil else {
            return
        }

        Task { @MainActor in
            guard !showDisclaimer, session.selectedSkinType == nil else {
                return
            }

            showSkinTypeOnboarding = true
        }
    }
}

extension View {
    @ViewBuilder
    fileprivate func disclaimerPresentation<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        #if os(macOS)
        sheet(isPresented: isPresented, onDismiss: onDismiss, content: content)
        #else
        fullScreenCover(isPresented: isPresented, onDismiss: onDismiss, content: content)
        #endif
    }

    @ViewBuilder
    fileprivate func skinTypePresentation<Content: View>(
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
