import SwiftUI
import UVBurnTimerCore
import WeatherKit
#if canImport(UIKit)
import UIKit
#endif

struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Binding var session: UVBurnTimerSession
    @Binding var showDisclaimer: Bool
    @AppStorage("lastUVSnapshot") private var cachedUVSnapshotStorage = ""
    @StateObject private var locationProvider = DeviceLocationProvider()
    @State private var showSettings = false
    @State private var uvIndex: Double?
    @State private var fetchedAt: Date?
    @State private var roundedCoordinate: UVCoordinate?
    @State private var now = Date()
    @State private var statusMessage = "Pick a skin type to see your estimate."
    @State private var isFetching = false
    @State private var isLocationAccessDenied = false
    @State private var locationPromptGate = LocationPromptGate()
    @State private var reattestationTracker = ForegroundReattestationTracker()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    photosensitizationBanner
                    if !locationPromptGate.hasAcknowledgedRationale {
                        LocationRationaleCard()
                    }
                    HeroTimerCard(
                        estimate: estimate,
                        uvIndex: uvIndex,
                        contextLine: estimateContextLine,
                        statusMessage: statusMessage,
                        isLocationAccessDenied: isLocationAccessDenied,
                        isEstimateStale: isEstimateStale,
                        onRecalculate: {
                            Task {
                                await refreshUV()
                            }
                        }
                    )
                    if let uvIndex {
                        UVIndexCard(
                            uvIndex: uvIndex,
                            sourceLine: ProductCopy.uvSourceLine,
                            updatedText: updatedText
                        )
                    } else {
                        UVIndexPlaceholderCard(sourceLine: ProductCopy.uvSourceLine)
                    }
                    WeatherAttributionView()
                    contextChipRow
                    spfCard
                }
                .padding()
            }
            .refreshable {
                await refreshUV()
            }
            .navigationTitle("UV Burn Timer")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                    .accessibilityHint("Opens skin type, SPF, attribution, and app information.")
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 8) {
                    PersistentFooter()
                    primaryAction
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .background(.bar)
            }
            .onAppear(perform: restoreCachedUVSnapshot)
            .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { newValue in
                now = newValue
            }
            .onChange(of: scenePhase) { _, newPhase in
                switch newPhase {
                case .active:
                    now = Date()
                    if reattestationTracker.shouldPresentOnForeground(
                        acknowledgedDisclaimer: session.acknowledgedDisclaimer,
                        estimateWindowElapsed: isEstimateStale
                    ) {
                        session.requireDisclaimerReattestation()
                        showDisclaimer = true
                    }
                case .background:
                    reattestationTracker.recordBackgroundEntry()
                case .inactive:
                    break
                @unknown default:
                    break
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet(session: $session)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sensoryFeedback(.success, trigger: uvIndex)
            .sensoryFeedback(.warning, trigger: isEstimateStale)
        }
    }

    private var estimate: BurnTimeEstimate? {
        guard let skinType = session.selectedSkinType, let uvIndex else {
            return nil
        }

        return try? BurnTimeCalculator.estimate(
            skinType: skinType,
            spf: session.selectedSPF,
            uvIndex: uvIndex
        )
    }

    private var photosensitizationBanner: some View {
        NavigationLink {
            AboutView(highlightEstimateApplicability: true)
        } label: {
            Label(ProductCopy.photosensitizationBannerLabel, systemImage: "exclamationmark.triangle")
                .font(.callout.weight(.semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.bordered)
        .tint(.orange)
    }

    private var contextChipRow: some View {
        HStack(spacing: 12) {
            Button {
                showSettings = true
            } label: {
                Label(locationChipTitle, systemImage: "location")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Location")
            .accessibilityValue(locationChipTitle)
            .accessibilityHint("Opens settings and app information.")

            Button {
                showSettings = true
            } label: {
                Label(skinTypeLabel, systemImage: "person.crop.circle")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Skin type")
            .accessibilityValue(skinTypeLabel)
            .accessibilityHint("Opens skin type settings.")
        }
    }

    private var spfCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SPF")
                .font(.headline)

            SPFPicker(selection: $session.selectedSPF)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var locationChipTitle: String {
        roundedCoordinate?.privacyDisplayText ?? "Location"
    }

    private var skinTypeLabel: String {
        guard let selectedSkinType = session.selectedSkinType else {
            return "No skin type selected"
        }

        return "Type \(selectedSkinType.romanNumeral)"
    }

    private var isEstimateStale: Bool {
        guard let fetchedAt, let estimate else {
            return false
        }

        return estimate.isElapsed(fetchedAt: fetchedAt, now: now)
    }

    private var estimateContextLine: String? {
        guard let selectedSkinType = session.selectedSkinType, let uvIndex else {
            return nil
        }

        return EstimateContextLine.text(
            skinType: selectedSkinType,
            spf: session.selectedSPF,
            uvIndex: uvIndex
        )
    }

    private var primaryActionTitle: String {
        if uvIndex == nil, !locationPromptGate.hasAcknowledgedRationale {
            return "Continue to location request"
        }

        return uvIndex == nil ? "Use my location" : "Recalculate"
    }

    private var updatedText: String? {
        guard let fetchedAt else {
            return nil
        }

        return CachedUVSnapshot(uvIndex: uvIndex ?? 0, fetchedAt: fetchedAt).relativeAgeText(now: now)
    }

    private var primaryAction: some View {
        Button {
            Task {
                await refreshUV()
            }
        } label: {
            Label(primaryActionTitle, systemImage: "location")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(isFetching)
        .accessibilityHint("Requests current location and fetches the UV index from Apple Weather.")
    }

    private func refreshUV() async {
        do {
            guard session.selectedSkinType != nil else {
                throw UVBurnTimerWorkflowError.missingSkinType
            }

            guard locationPromptGate.allowSystemPromptOrAcknowledgeRationale() else {
                statusMessage = "Location rationale reviewed. Tap Use my location to continue."
                return
            }

            isFetching = true
            isLocationAccessDenied = false
            statusMessage = "Requesting location..."

            let coordinate = try await locationProvider.currentCoordinate()
            statusMessage = "Fetching UV from Apple Weather..."

            let workflow = UVBurnTimerWorkflow(uvProvider: WeatherKitUVDataProvider())
            let result = try await workflow.fetchEstimate(
                for: acknowledgedSession,
                at: coordinate
            )
            uvIndex = result.snapshot.uvIndex
            fetchedAt = result.snapshot.fetchedAt
            roundedCoordinate = result.snapshot.roundedCoordinate
            now = Date()
            persist(snapshot: result.snapshot)
            statusMessage = "UV index fetched from Apple Weather."
        } catch UVBurnTimerWorkflowError.missingSkinType {
            isLocationAccessDenied = false
            statusMessage = "Pick a skin type before requesting location."
        } catch UVBurnTimerWorkflowError.disclaimerNotAcknowledged {
            isLocationAccessDenied = false
            statusMessage = "Review the disclaimer before requesting UV."
        } catch DeviceLocationError.denied {
            isLocationAccessDenied = true
            statusMessage = ProductCopy.locationDeniedEmptyState
        } catch DeviceLocationError.unavailable {
            isLocationAccessDenied = false
            statusMessage = ProductCopy.locationUnavailableMessage
        } catch DeviceLocationError.requestAlreadyInProgress {
            isLocationAccessDenied = false
            statusMessage = ProductCopy.locationRequestInProgressMessage
        } catch {
            isLocationAccessDenied = false
            statusMessage = "Could not reach Apple Weather. Try again."
        }

        isFetching = false
    }

    private var acknowledgedSession: UVBurnTimerSession {
        UVBurnTimerSession(
            selectedSkinType: session.selectedSkinType,
            selectedSPF: session.selectedSPF,
            acknowledgedDisclaimer: session.acknowledgedDisclaimer
        )
    }

    private func restoreCachedUVSnapshot() {
        guard uvIndex == nil, let data = cachedUVSnapshotStorage.data(using: .utf8) else {
            return
        }

        do {
            let cached = try JSONDecoder().decode(CachedUVSnapshot.self, from: data)
            uvIndex = cached.uvIndex
            fetchedAt = cached.fetchedAt
            roundedCoordinate = cached.roundedCoordinate
            locationPromptGate = LocationPromptGate(hasAcknowledgedRationale: true)
            statusMessage = cached.relativeAgeText(now: now)
        } catch {
            cachedUVSnapshotStorage = ""
        }
    }

    private func persist(snapshot: UVSnapshot) {
        do {
            let data = try JSONEncoder().encode(CachedUVSnapshot(snapshot: snapshot))
            cachedUVSnapshotStorage = String(decoding: data, as: UTF8.self)
        } catch {
            cachedUVSnapshotStorage = ""
        }
    }
}

struct HeroTimerCard: View {
    let estimate: BurnTimeEstimate?
    let uvIndex: Double?
    let contextLine: String?
    let statusMessage: String
    let isLocationAccessDenied: Bool
    let isEstimateStale: Bool
    let onRecalculate: () -> Void
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Burn time")
                .font(.headline)
                .foregroundStyle(.secondary)

            heroContent

            if let estimate {
                if estimate.tier != .none {
                    TierBadge(tier: estimate.tier)
                }
                if let contextLine {
                    Text(contextLine)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Estimate inputs: \(contextLine)")
                }
                if isEstimateStale {
                    SafetyStatusCard(
                        title: "Estimate window elapsed",
                        message: ProductCopy.estimateElapsedWarning,
                        systemImage: "exclamationmark.shield.fill"
                    )
                }
            } else {
                Text(verdictText)
                    .font(.title3.weight(.semibold))
            }

            if let estimate, estimate.rawMinutes.isFinite {
                NavigationLink {
                    AboutView(highlightEstimateApplicability: true)
                } label: {
                    Label(ProductCopy.mainVerdictCaveatLinkLabel, systemImage: "info.circle")
                        .font(.footnote.weight(.medium))
                }
                .accessibilityHint("Opens applicability and photosensitizing medication caveats.")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    private var heroContent: some View {
        if let estimate, isEstimateStale {
            staleEstimateContent(estimate)
        } else if let estimate, estimate.tier == .none {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "moon.zzz")
                    .font(.system(size: 80))
                    .foregroundStyle(.secondary)
                Text("UV index is 0 — no erythemal irradiance detected.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        } else if let estimate {
            estimateText(estimate)
        } else if isLocationAccessDenied {
            VStack(alignment: .leading, spacing: 12) {
                Label("Location unavailable", systemImage: "location.slash")
                    .font(.title3.weight(.semibold))
                Text(ProductCopy.locationDeniedEmptyState)
                    .font(.body)
                    .foregroundStyle(.secondary)
                #if canImport(UIKit)
                HStack {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(.bordered)

                    Button("Try again", action: onRecalculate)
                        .buttonStyle(.borderedProminent)
                }
                #else
                Button("Try again", action: onRecalculate)
                    .buttonStyle(.borderedProminent)
                #endif
            }
        } else {
            Image(systemName: "sun.max")
                .font(.system(size: 80))
                .foregroundStyle(.tint)

            Text(statusMessage)
                .font(.body)
        }
    }

    @ViewBuilder
    private func staleEstimateContent(_ estimate: BurnTimeEstimate) -> some View {
        let content = VStack(alignment: .leading, spacing: 12) {
            estimateText(estimate)
                .opacity(colorSchemeContrast == .increased ? 1 : 0.6)

            Button(action: onRecalculate) {
                Label("Recalculate", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
            .accessibilityHint("Fetches a fresh UV index before relying on this estimate.")
        }

        if accessibilityReduceMotion {
            content
        } else {
            content.contentTransition(.numericText())
        }
    }

    @ViewBuilder
    private func estimateText(_ estimate: BurnTimeEstimate) -> some View {
        let text = Text(estimate.displayText)
            .font(.system(size: 80, weight: .heavy, design: .rounded))
            .minimumScaleFactor(0.5)
            .lineLimit(1)

        if accessibilityReduceMotion {
            text
                .accessibilityLabel(estimate.accessibilitySummary)
        } else {
            text.contentTransition(.numericText())
                .accessibilityLabel(estimate.accessibilitySummary)
        }
    }

    private var verdictText: String {
        guard let estimate else {
            return "Ready when you are"
        }

        switch estimate.tier {
        case .none:
            return "No UV detected"
        case .long:
            return "Long"
        case .moderate:
            return "Moderate"
        case .short:
            return "Short"
        }
    }

    private var accessibilityLabel: String {
        guard let estimate else {
            return statusMessage
        }

        return HeroAccessibilitySummary.text(
            estimate: estimate,
            uvIndex: uvIndex,
            verdict: verdictText
        )
    }
}

struct UVIndexCard: View {
    let uvIndex: Double
    let sourceLine: String
    let updatedText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("UV Index \(uvIndex.formatted(.number.precision(.fractionLength(1))))")
                .font(.title3.weight(.semibold))
            Text(sourceLine)
                .font(.subheadline.weight(.medium))
            if let updatedText {
                Text(updatedText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityHint("Current UV index and Apple Weather source.")
    }
}

struct UVIndexPlaceholderCard: View {
    let sourceLine: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("UV Index")
                .font(.title3.weight(.semibold))
            Text("Use your location to fetch the current UV index.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(sourceLine)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityHint("UV index is unavailable until location is used.")
    }
}

struct SafetyStatusCard: View {
    let title: String
    let message: String
    let systemImage: String
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(message)
                    .font(.footnote)
            }
        } icon: {
            Image(systemName: systemImage)
        }
        .foregroundStyle(Color.primary)
        .padding(12)
        .background(
            Color.orange.opacity(colorSchemeContrast == .increased ? 0.28 : 0.14),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
    }
}

struct TierBadge: View {
    let tier: BurnTimeTier
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    var body: some View {
        HStack(spacing: 6) {
            Label(title, systemImage: symbolName)
            if differentiateWithoutColor, let accessorySymbolName {
                Image(systemName: accessorySymbolName)
            }
        }
        .font(.subheadline.weight(.semibold))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .foregroundStyle(color)
        .background(color.opacity(0.14), in: Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) burn-time tier")
    }

    private var title: String {
        switch tier {
        case .none: "No UV detected"
        case .long: "Long"
        case .moderate: "Moderate"
        case .short: "Short"
        }
    }

    private var symbolName: String {
        switch tier {
        case .none: "moon.zzz"
        case .long: "tortoise"
        case .moderate: "sun.max"
        case .short: "hare"
        }
    }

    private var accessorySymbolName: String? {
        switch tier {
        case .none: nil
        case .long: "checkmark.circle.fill"
        case .moderate: "exclamationmark.circle"
        case .short: "exclamationmark.triangle.fill"
        }
    }

    private var color: Color {
        switch tier {
        case .none: .secondary
        case .long: Color("SeverityLong")
        case .moderate: Color("SeverityModerate")
        case .short: Color("SeverityShort")
        }
    }
}

struct LocationRationaleCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Location permission", systemImage: "location.circle")
                .font(.headline)
            Text(ProductCopy.locationRationale)
            Text(ProductCopy.locationPrivacyLine)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct DisclaimerCover: View {
    let onAcknowledge: () -> Void
    @State private var showAbout = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.orange)

                Text(ProductCopy.disclaimerTitle)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text(ProductCopy.disclaimerBody)
                    .font(.body)

                Label(ProductCopy.photosensitizerDisclaimerLine, systemImage: "exclamationmark.triangle")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.orange)

                Label(ProductCopy.childrenDisclaimerLine, systemImage: "figure.and.child.holdinghands")
                    .font(.callout.weight(.semibold))

                Button {
                    showAbout = true
                } label: {
                    Label("See About: when estimates may not apply", systemImage: "info.circle")
                }
                .buttonStyle(.bordered)
                .accessibilityHint("Opens About with photosensitizing medication and condition caveats.")
            }
            .padding(32)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
        .safeAreaInset(edge: .bottom) {
            Button("I understand", action: onAcknowledge)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.bar)
        }
        .sheet(isPresented: $showAbout) {
            NavigationStack {
                AboutView(highlightEstimateApplicability: true)
            }
        }
        .interactiveDismissDisabled(true)
    }
}

struct SkinTypeOnboardingView: View {
    @Binding var session: UVBurnTimerSession
    @State private var draft = SkinTypeOnboardingDraft()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(FitzpatrickSkinType.allCases) { skinType in
                        Button {
                            draft.select(skinType)
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                Text(skinType.romanNumeral)
                                    .font(.title3.weight(.bold))
                                    .frame(width: 36)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Type \(skinType.romanNumeral)")
                                        .font(.body)
                                    Text(skinType.pickerDescription)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if draft.pendingSkinType == skinType {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.tint)
                                        .accessibilityHidden(true)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .frame(minHeight: 56)
                        .accessibilityElement(children: .combine)
                        .accessibilityAddTraits(draft.pendingSkinType == skinType ? .isSelected : [])
                        .accessibilityHint(draft.pendingSkinType == skinType ? "Selected. Continue to confirm this skin type." : "Selects this skin type before confirmation.")
                    }
                } header: {
                    Text(ProductCopy.skinTypePickerPrompt)
                } footer: {
                    Text(ProductCopy.skinTypePickerFooter)
                }
            }
            .navigationTitle("Choose skin type")
            .safeAreaInset(edge: .bottom) {
                Button {
                    _ = draft.commit(to: &session)
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!draft.canContinue)
                .padding()
                .background(.bar)
                .accessibilityHint(draft.canContinue ? "Confirms the selected skin type." : "Select a skin type first.")
            }
        }
        .interactiveDismissDisabled(true)
    }
}

struct SettingsSheet: View {
    @Binding var session: UVBurnTimerSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(FitzpatrickSkinType.allCases) { skinType in
                        Button {
                            session.selectedSkinType = skinType
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                Text(skinType.romanNumeral)
                                    .font(.title3.weight(.bold))
                                    .frame(width: 36)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Type \(skinType.romanNumeral)")
                                        .font(.body)
                                    Text(skinType.pickerDescription)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if session.selectedSkinType == skinType {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.tint)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .frame(minHeight: 56)
                    }
                } header: {
                    Text(ProductCopy.skinTypePickerPrompt)
                } footer: {
                    Text(ProductCopy.skinTypeSettingsFooter)
                }

                Section("SPF") {
                    SPFPicker(selection: $session.selectedSPF)
                }

                Section {
                    NavigationLink("About & Citations") {
                        AboutView()
                    }

                    NavigationLink("Attribution & Legal") {
                        AttributionView()
                    }
                }

                Section("Pricing") {
                    Text(ProductCopy.pricingLine)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SPFPicker: View {
    @Binding var selection: SPFLevel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        if dynamicTypeSize.isAccessibilitySize {
            picker.pickerStyle(.menu)
        } else {
            picker.pickerStyle(.segmented)
        }
    }

    private var picker: some View {
        Picker("SPF", selection: $selection) {
            ForEach(SPFLevel.allCases) { level in
                Text(level.displayName).tag(level)
            }
        }
    }
}

struct AboutView: View {
    var highlightEstimateApplicability = false
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    private let notForMeAnchor = "notForMe"

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("About & Citations")
                        .font(.title.bold())
                        .accessibilityAddTraits(.isHeader)

                    Text("UV Burn Timer estimates minutes to one minimal erythemal dose using Fitzpatrick skin type, SPF, and the current UV index.")

                    Text("How this works")
                        .font(.title3.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(ProductCopy.aboutHowThisWorks)

                    Text("Sunscreen assumptions")
                        .font(.title3.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(ProductCopy.aboutSunscreenAssumptions)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("When this estimate may not apply")
                            .font(.title3.weight(.semibold))
                            .accessibilityAddTraits(.isHeader)

                        Text(ProductCopy.aboutEstimateApplicability)
                    }
                    .id(notForMeAnchor)
                    .padding(highlightEstimateApplicability ? 12 : 0)
                    .background(highlightEstimateApplicability ? Color.orange.opacity(0.15) : Color.clear, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Text("Citations")
                        .font(.title3.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(ProductCopy.fitzpatrickCitations)
                        .font(.footnote)
                        .textSelection(.enabled)

                    Text("Why this number changes with weather")
                        .font(.title3.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(ProductCopy.aboutWeatherVariability)

                    Text("Outdoor tip")
                        .font(.title3.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(ProductCopy.outdoorReadabilityTip)

                    Text("Privacy")
                        .font(.title3.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(ProductCopy.aboutPrivacy)

                    Text("Pricing")
                        .font(.title3.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(ProductCopy.pricingLine)

                    WeatherAttributionView()
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .onAppear {
                guard highlightEstimateApplicability else {
                    return
                }

                Task { @MainActor in
                    if accessibilityReduceMotion {
                        proxy.scrollTo(notForMeAnchor, anchor: .top)
                    } else {
                        withAnimation {
                            proxy.scrollTo(notForMeAnchor, anchor: .top)
                        }
                    }
                }
            }
        }
        .navigationTitle("About")
    }
}

struct AttributionView: View {
    private let legalURL = ProductCopy.weatherAttributionLegalURL

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Attribution & Legal")
                .font(.title.bold())

            Text("UV Burn Timer uses Apple Weather for UV index data. Apple Weather data is sourced from a range of providers.")

            Link("Other data sources", destination: legalURL)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .navigationTitle("Attribution")
    }
}

struct WeatherAttributionView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var attribution: WeatherAttribution?
    @State private var attributionError: String?
    private let fallbackLegalURL = ProductCopy.weatherAttributionLegalURL

    var body: some View {
        HStack {
            officialMark
            Spacer()
            Link("Data sources", destination: attribution?.legalPageURL ?? fallbackLegalURL)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.vertical, 4)
        .task {
            await loadAttribution()
        }
    }

    @ViewBuilder
    private var officialMark: some View {
        if let markURL {
            AsyncImage(url: markURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .controlSize(.small)
                        .accessibilityLabel("Loading Apple Weather attribution")
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
                        .accessibilityLabel(attribution?.serviceName ?? ProductCopy.weatherAttributionServiceName)
                case .failure:
                    Text(attributionError ?? "Apple Weather attribution unavailable")
                @unknown default:
                    Text(attributionError ?? "Apple Weather attribution unavailable")
                }
            }
        } else {
            Label(ProductCopy.weatherAttributionServiceName, systemImage: "cloud.sun")
        }
    }

    private var markURL: URL? {
        guard let attribution else {
            return nil
        }

        return colorScheme == .dark ? attribution.combinedMarkDarkURL : attribution.combinedMarkLightURL
    }

    @MainActor
    private func loadAttribution() async {
        do {
            attribution = try await WeatherService.shared.attribution
            attributionError = nil
        } catch {
            attributionError = "Apple Weather attribution unavailable"
        }
    }
}

struct PersistentFooter: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(ProductCopy.reapplicationFooter)
                .font(.caption)
                .foregroundStyle(.secondary)

            NavigationLink {
                AboutView(highlightEstimateApplicability: true)
            } label: {
                Label(ProductCopy.disclaimerLinkLabel, systemImage: "info.circle")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(.tint)
            .accessibilityHint("Opens About and applicability details.")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
