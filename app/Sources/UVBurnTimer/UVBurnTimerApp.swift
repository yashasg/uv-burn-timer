import SwiftUI
import UVBurnTimerCore

@main
struct UVBurnTimerApp: App {
    @State private var session: UVBurnTimerSession
    @State private var showDisclaimer: Bool
    @State private var showSkinTypeOnboarding = false

    init() {
        let defaults = UserDefaults.standard
        var initialShowDisclaimer = UserPreferenceStorage.shouldShowDisclaimerCover(
            defaults: defaults,
            currentVersion: UserPreferenceStorage.currentDisclaimerPolicyVersion
        )
        // K-H1: existing users (who don't see the disclaimer cover) need their
        // restored session pre-acknowledged so the first "Use my location" tap
        // doesn't throw .disclaimerNotAcknowledged with no disclaimer to review.
        var initialSession = UserPreferenceStorage.restoredSession(
            from: defaults,
            acknowledgedDisclaimer: !initialShowDisclaimer
        )

        #if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-uiTestResetDefaults") {
            UserPreferenceStorage.clearStoredPreferences(from: defaults)
            UserDefaults.standard.removeObject(forKey: "lastRoundedCoordinate")
            UserDefaults.standard.removeObject(forKey: "lastUVSnapshot")
            initialShowDisclaimer = UserPreferenceStorage.shouldShowDisclaimerCover(
                defaults: defaults,
                currentVersion: UserPreferenceStorage.currentDisclaimerPolicyVersion
            )
            initialSession = UserPreferenceStorage.restoredSession(
                from: defaults,
                acknowledgedDisclaimer: !initialShowDisclaimer
            )
        }
        if arguments.contains("-uiTestSavedPreferences") {
            defaults.set(FitzpatrickSkinType.typeIII.rawValue, forKey: UserPreferenceStorage.selectedSkinTypeKey)
            defaults.set(SPFLevel.spf50.rawValue, forKey: UserPreferenceStorage.selectedSPFKey)
            defaults.set(
                #"{"roundedCoordinate":{"latitude":37.77,"longitude":-122.42}}"#,
                forKey: "lastRoundedCoordinate"
            )
            initialSession = UserPreferenceStorage.restoredSession(
                from: defaults,
                acknowledgedDisclaimer: !initialShowDisclaimer
            )
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
            initialSession = UVBurnTimerSession(
                selectedSkinType: .typeI,
                selectedSPF: .spf15,
                acknowledgedDisclaimer: true
            )
            initialShowDisclaimer = false
        }
        if arguments.contains("-uiTestCappedEstimate") {
            initialSession = UVBurnTimerSession(
                selectedSkinType: .typeIII,
                selectedSPF: .spf30,
                acknowledgedDisclaimer: true
            )
            initialShowDisclaimer = false
        }
        if arguments.contains("-uiTestLongUncappedEstimate") {
            initialSession = UVBurnTimerSession(
                selectedSkinType: .typeIII,
                selectedSPF: .spf15,
                acknowledgedDisclaimer: true
            )
            initialShowDisclaimer = false
        }
        #endif

        _session = State(initialValue: initialSession)
        _showDisclaimer = State(initialValue: initialShowDisclaimer)
    }

    var body: some Scene {
        WindowGroup {
            RootView(session: $session, showDisclaimer: $showDisclaimer, showSkinTypeOnboarding: $showSkinTypeOnboarding)
                .disclaimerPresentation(
                    isPresented: $showDisclaimer,
                    onDismiss: presentSkinTypeOnboardingIfNeeded
                ) {
                    DisclaimerCover {
                        UserDefaults.standard.set(
                            UserPreferenceStorage.currentDisclaimerPolicyVersion,
                            forKey: UserPreferenceStorage.disclaimerPolicyVersionKey
                        )
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

        // Defer past the disclaimer fullScreenCover's dismissal animation so
        // the skin-type cover can reliably claim the presentation slot. iOS
        // can swallow a second .fullScreenCover that is set while the first
        // one is still tearing down its transition.
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
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
