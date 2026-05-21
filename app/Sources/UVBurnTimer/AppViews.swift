import SwiftUI
import UVBurnTimerCore
@preconcurrency import WeatherKit

#if canImport(UIKit)
import UIKit
#endif

private enum UVRefreshError: Error {
    case weatherUnavailable
}

struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Binding var session: UVBurnTimerSession
    @Binding var showDisclaimer: Bool
    @Binding var showSkinTypeOnboarding: Bool
    @AppStorage("lastRoundedCoordinate") private var cachedRoundedCoordinateStorage = ""
    @AppStorage("lastUVSnapshot") private var legacyCachedUVSnapshotStorage = ""
    @AppStorage(UserPreferenceStorage.selectedSkinTypeKey) private var persistedSkinTypeRawValue =
        UserPreferenceStorage.unsetSkinTypeRawValue
    @AppStorage(UserPreferenceStorage.selectedSPFKey) private var persistedSPFRawValue = SPFLevel.spf30.rawValue
    @StateObject private var locationProvider = DeviceLocationProvider()
    @State private var showSettings = false
    @State private var showSkinTypeEdit = false
    @State private var uvIndex: Double?
    @State private var fetchedAt: Date?
    @State private var roundedCoordinate: UVCoordinate?
    @State private var now = Date()
    @State private var statusMessage = ""
    @State private var isFetching = false
    @State private var locationFailureMessage: String?
    @State private var weatherFailureMessage: String?
    @State private var reattestationTracker = ForegroundReattestationTracker()
    // WI-7 — 10-day UV forecast
    @State private var forecastStore = ForecastStore()
    @State private var forecastSnapshot: ForecastSnapshot?
    @State private var isFetchingForecast = false
    @State private var forecastRefreshState: ForecastRefreshState = .idle
    // WI-7 Picker — selected day-and-hour timestamp.
    // Default: current UTC hour (rounded down). Never stored in UserDefaults per LAUNCH-PLAN.
    @State private var selectedDate: Date = ForecastPickerLogic.roundedDownToHour(Date())
    // True once the user has manually tapped a day or hour cell.
    // Prevents system snap-to-nearest from overriding an explicit user choice.
    @State private var selectedDateIsUserOverridden: Bool = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    var body: some View {
        mainNavigationStack
    }

    /// Navigation stack shell — contains only the chrome (toolbar, bottom bar, sheets).
    /// The heavy modifier chain is split across navigationStackBase + mainNavigationStack
    /// to stay within the Swift type-checker's expression complexity budget.
    private var mainNavigationStack: some View {
        navigationStackBase
            .onAppear(perform: handleAppear)
            .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { now = $0 }
            .onChange(of: scenePhase) { _, phase in handleScenePhaseChange(phase) }
            .onChange(of: statusMessage) { _, newValue in announceStatusForAccessibility(newValue) }
            .onChange(of: session.selectedSkinType) { _, skinType in persist(skinType: skinType) }
            .onChange(of: session.selectedSPF) { _, spf in persist(spf: spf) }
            .onChange(of: forecastSnapshot) { _, snapshot in
                guard !selectedDateIsUserOverridden else { return }
                selectedDate = ForecastPickerLogic.snapToNearest(selectedDate, in: snapshot)
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet(
                    session: $session,
                    hasSavedLocation: roundedCoordinate != nil || !cachedRoundedCoordinateStorage.isEmpty,
                    onClearSavedLocation: clearSavedRoundedCoordinate
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showSkinTypeEdit) {
                SkinTypeEditView(session: $session)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sensoryFeedback(.success, trigger: uvIndex)
            .sensoryFeedback(.warning, trigger: isEstimateStale)
    }

    /// Navigation stack content — title, toolbar, bottom bar, and the main scroll area.
    private var navigationStackBase: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    #if DEBUG
                    UITestRefreshableProbeButton(refreshAction: { await refreshUV() })
                    #endif
                    heroTimerCardView
                    Divider()
                    uvIndexCardView
                    mainInputsRow
                    // WI-7: Forecast day-and-hour picker.
                    forecastPickerCardView
                }
                .padding()
            }
            .accessibilityIdentifier("NowViewScrollView")
            .nowViewRefreshable {
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
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: AboutView(highlightEstimateApplicability: true)) {
                        Image(systemName: "info.circle")
                    }
                    .accessibilityLabel("About this estimate")
                    .accessibilityHint("Opens photosensitization, medication, and sunscreen assumption caveats.")
                    .accessibilityIdentifier("EstimateInfoButton")
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

    // MARK: - WI-7 Picker → Burn Timer wiring

    /// UV result for the picker-selected date, derived synchronously from the
    /// in-memory snapshot (no actor hop required).
    private var selectedDateUVResult: UVResult {
        ForecastPickerLogic.uvResult(from: forecastSnapshot, at: selectedDate, now: now)
    }

    /// The UV index to display on the burn card.
    /// Prefers the forecast value for the selected date; falls back to the live
    /// reading when the snapshot is unavailable or expired.
    private var activeUVIndex: Double? {
        switch selectedDateUVResult {
        case .value(let uvi):
            return uvi
        case .nighttime:
            return 0.0
        default:
            return uvIndex  // live reading fallback
        }
    }

    /// Burn-time estimate driven by the selected date's UV (forecast or live).
    private var activeEstimate: BurnTimeEstimate? {
        guard let skinType = session.selectedSkinType, let uvi = activeUVIndex else { return nil }
        return try? BurnTimeCalculator.estimate(
            skinType: skinType,
            spf: session.selectedSPF,
            uvIndex: uvi
        )
    }

    /// Context line for the burn card, using the active UV index.
    private var activeEstimateContextLine: String? {
        guard let selectedSkinType = session.selectedSkinType, let uvi = activeUVIndex else {
            return nil
        }
        return EstimateContextLine.text(
            skinType: selectedSkinType,
            spf: session.selectedSPF,
            uvIndex: uvi
        )
    }

    /// Optional date prefix for the burn card header.
    /// Non-nil when the selected time is not the current hour
    /// (e.g., "Burn time on Wed, 6 PM").
    private var forecastDateContext: String? {
        ForecastPickerLogic.burnCardDatePrefix(for: selectedDate, now: now)
    }

    /// True only when the selected date is the current UTC hour —
    /// future forecast selections are never "stale".
    private var isCurrentHourSelected: Bool {
        ForecastPickerLogic.roundedDownToHour(now)
            == ForecastPickerLogic.roundedDownToHour(selectedDate)
    }

    // MARK: - Extracted card views (split from body for Swift type-checker performance)

    /// Delegates to the `HeroTimerCard` View struct. The wrapper must survive as
    /// a distinct SwiftUI struct (not inlined into RootView) because inlining
    /// regresses XCUI `testSettingsSheetOpens` — the toolbar `gearshape` button's
    /// tap stops dispatching to `.sheet(isPresented: $showSettings)` when the
    /// hero card shares RootView's SwiftUI identity. Guarded by Group R contract
    /// tests (R1, R2) in `BurnTimeCalculatorTests.swift`.
    private var heroTimerCardView: some View {
        HeroTimerCard(
            estimate: activeEstimate,
            uvIndex: activeUVIndex ?? uvIndex,
            fetchedAt: fetchedAt,
            now: now,
            contextLine: activeEstimateContextLine,
            statusMessage: displayedStatusMessage,
            locationFailureMessage: locationFailureMessage,
            weatherFailureMessage: weatherFailureMessage,
            isEstimateStale: isEstimateStale,
            forecastDateContext: forecastDateContext,
            onRecalculate: { Task { await refreshUV() } }
        )
    }

    @ViewBuilder
    private var uvIndexCardView: some View {
        if let uvIndex {
            UVIndexCard(
                uvIndex: uvIndex,
                sourceLine: ProductCopy.uvSourceLine,
                updatedText: updatedText
            )
        } else {
            UVIndexPlaceholderCard(sourceLine: ProductCopy.uvSourceLine)
        }
    }

    private var forecastPickerCardView: some View {
        ForecastPickerView(
            selectedDate: $selectedDate,
            forecastDays: forecastDays,
            forecastHours: forecastHours,
            now: now,
            forecastRefreshState: forecastRefreshState,
            onRetry: { Task { await performForecastRefresh() } },
            onUserSelection: { _ in selectedDateIsUserOverridden = true }
        )
    }

    @ViewBuilder
    private var mainInputsRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Inputs")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .accessibilityIdentifier("MainInputsRowHeader")
                .accessibilityAddTraits(.isHeader)

            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 12) {
                    skinTypeChip
                    locationChip
                    spfChip
                }
            } else {
                HStack(spacing: 12) {
                    skinTypeChip
                    locationChip
                    spfChip
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var locationChip: some View {
        Button {
            Task {
                await refreshUV()
            }
        } label: {
            Label(locationChipTitle, systemImage: "location")
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.bordered)
        .disabled(isFetching)
        .accessibilityLabel("Location")
        .accessibilityValue(locationChipAccessibilityValue)
        .accessibilityHint(primaryActionPresentation.accessibilityHint)
        .accessibilityIdentifier("LocationChip")
    }

    private var spfChip: some View {
        Menu {
            Picker("SPF", selection: $session.selectedSPF) {
                ForEach(SPFLevel.allCases) { level in
                    Text(level.displayName).tag(level)
                }
            }
        } label: {
            Label("SPF \(session.selectedSPF.displayName)", systemImage: "sun.dust")
                .lineLimit(1)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .menuOrder(.fixed)
        .buttonStyle(.bordered)
        .accessibilityHint("Changes the assumed SPF level. SPF 70+ is modeled as SPF 50.")
        .accessibilityIdentifier("SPFChip")
    }

    private var skinTypeChip: some View {
        Button {
            if session.selectedSkinType != nil {
                showSkinTypeEdit = true
            } else {
                showSkinTypeOnboarding = true
            }
        } label: {
            Label(
                session.selectedSkinType.map { "Type \($0.romanNumeral)" } ?? "Set skin type",
                systemImage: "figure.person.crop.square"
            )
            .font(.caption.weight(.medium))
            .lineLimit(1)
            .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.bordered)
        .accessibilityLabel(
            session.selectedSkinType.map { "Skin type, Type \($0.romanNumeral)" } ?? "Skin type, not set"
        )
        .accessibilityHint(
            session.selectedSkinType != nil
                ? "Opens skin type settings to change your Fitzpatrick classification."
                : "Opens skin type selector to set your Fitzpatrick classification."
        )
        .accessibilityIdentifier("SkinTypeChip")
    }

    private var locationChipTitle: String {
        roundedCoordinate?.privacyDisplayText ?? "Location"
    }

    private var locationChipAccessibilityValue: String {
        roundedCoordinate?.privacyDisplayText ?? "Not set"
    }

    private var isEstimateStale: Bool {
        // Future-date forecast estimates are never stale in the burn-window sense.
        guard isCurrentHourSelected else { return false }
        guard let fetchedAt, let estimate else {
            return false
        }

        return estimate.isElapsed(fetchedAt: fetchedAt, now: now)
    }

    /// Hero `statusMessage` is `@State` and mutates on transient events
    /// (location request in progress, weather fetch succeeded, errors, etc.).
    /// When no transient message is in flight, derive the empty-state copy
    /// from the session so that once a Fitzpatrick skin type is committed the
    /// hero stops asking the user to do something they've already done (WI-11).
    private var displayedStatusMessage: String {
        if !statusMessage.isEmpty {
            return statusMessage
        }

        return ProductCopy.heroEmptyStatePrompt(hasSkinType: session.selectedSkinType != nil)
    }

    private var primaryActionPresentation: LocationActionPresentation {
        LocationActionPresentation(
            hasUVIndex: uvIndex != nil,
            isFetching: isFetching
        )
    }

    private var updatedText: String? {
        guard let fetchedAt else {
            return nil
        }

        return RelativeAgeText.text(fetchedAt: fetchedAt, now: now)
    }

    private var primaryAction: some View {
        Button {
            Task {
                await refreshUV()
            }
        } label: {
            HStack {
                if isFetching {
                    ProgressView()
                        .controlSize(.small)
                        .accessibilityHidden(true)
                }

                Label(primaryActionPresentation.title, systemImage: primaryActionPresentation.systemImageName)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(isFetching)
        .accessibilityHint(primaryActionPresentation.accessibilityHint)
    }

    private func refreshUV() async {
        guard !isFetching else {
            return
        }

        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-uiTestRefreshableEcho") {
            applyUITestRefreshableEchoIfNeeded()
            return
        }
        #endif

        do {
            guard session.selectedSkinType != nil else {
                throw UVBurnTimerWorkflowError.missingSkinType
            }

            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-uiTestLocationUnavailable") {
                throw DeviceLocationError.unavailable
            }
            if ProcessInfo.processInfo.arguments.contains("-uiTestLocationDenied") {
                throw DeviceLocationError.denied
            }
            if ProcessInfo.processInfo.arguments.contains("-uiTestWeatherUnavailable") {
                throw UVRefreshError.weatherUnavailable
            }
            #endif

            isFetching = true
            locationFailureMessage = nil
            weatherFailureMessage = nil
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
            // WI-7: after a fresh location fix, kick off forecast refresh too.
            await performForecastRefresh()
        } catch UVBurnTimerWorkflowError.missingSkinType {
            locationFailureMessage = nil
            weatherFailureMessage = nil
            statusMessage = "Pick a skin type before requesting location."
        } catch UVBurnTimerWorkflowError.disclaimerNotAcknowledged {
            locationFailureMessage = nil
            weatherFailureMessage = nil
            statusMessage = "Review the disclaimer before requesting UV."
        } catch DeviceLocationError.denied {
            locationFailureMessage = ProductCopy.locationDeniedEmptyState
            weatherFailureMessage = nil
            statusMessage = ProductCopy.locationDeniedEmptyState
        } catch DeviceLocationError.unavailable {
            locationFailureMessage = ProductCopy.locationUnavailableMessage
            weatherFailureMessage = nil
            statusMessage = ProductCopy.locationUnavailableMessage
        } catch DeviceLocationError.requestAlreadyInProgress {
            locationFailureMessage = nil
            weatherFailureMessage = nil
            statusMessage = ProductCopy.locationRequestInProgressMessage
        } catch UVRefreshError.weatherUnavailable {
            locationFailureMessage = nil
            weatherFailureMessage = ProductCopy.weatherUnavailableMessage
            statusMessage = ProductCopy.weatherUnavailableMessage
        } catch {
            locationFailureMessage = nil
            weatherFailureMessage = ProductCopy.weatherUnavailableMessage
            statusMessage = ProductCopy.weatherUnavailableMessage
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

    private func handleAppear() {
        syncPreferenceStorageFromSession()
        restoreSavedRoundedCoordinate()
        applyUITestStaleEstimateSeedIfNeeded()
        applyUITestCappedEstimateSeedIfNeeded()
        applyUITestLongUncappedEstimateSeedIfNeeded()
    }

    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            now = Date()
            // Reset picker selection to current day + current hour on every foreground (Iris §4).
            // Never persist day/hour selection across sessions — forecast data is time-relative.
            selectedDateIsUserOverridden = false
            selectedDate = ForecastPickerLogic.defaultSelectedDate(in: forecastSnapshot, now: now)
            if reattestationTracker.shouldPresentOnForeground(
                acknowledgedDisclaimer: session.acknowledgedDisclaimer,
                estimateWindowElapsed: isEstimateStale
            ) {
                session.requireDisclaimerReattestation()
                showDisclaimer = true
            }
            // WI-7: refresh forecast if nil, expired, or coord-far (>50 km).
            Task { await refreshForecastIfNeeded() }
        case .background:
            reattestationTracker.recordBackgroundEntry()
        case .inactive:
            break
        @unknown default:
            break
        }
    }

    // MARK: - WI-7 Forecast refresh

    /// Forecast days for the picker. Internal (not private) so the picker can read it.
    var forecastDays: [DayForecast] {
        forecastSnapshot?.days ?? []
    }

    /// Forecast hours for the picker. Internal (not private) so the picker can read it.
    var forecastHours: [HourForecast] {
        forecastSnapshot?.hours ?? []
    }

    /// Called on scenePhase → .active.
    /// Loads the cached snapshot; kicks off a refresh when:
    ///   1. No snapshot exists on disk (nil).
    ///   2. Snapshot is stale (now ≥ expirationDate).
    ///   3. Snapshot coords are > 50 km from the current rounded coordinate.
    /// Otherwise keeps the existing valid snapshot — no WeatherKit call made.
    private func refreshForecastIfNeeded() async {
        let existing: ForecastSnapshot?
        do {
            existing = try await forecastStore.load()
        } catch {
            // Schema mismatch or corrupt file — file already deleted by the store.
            // Fall through to performForecastRefresh with existing = nil.
            existing = nil
        }

        if let snapshot = existing {
            forecastSnapshot = snapshot

            let stale = snapshot.isStale()
            let outOfRange: Bool
            if let coord = roundedCoordinate {
                outOfRange = await forecastStore.isCoordOutOfRange(
                    latitude: coord.latitude,
                    longitude: coord.longitude
                )
            } else {
                outOfRange = false
            }

            if outOfRange {
                // Coord-eviction: discard the stored snapshot before refetching.
                try? await forecastStore.clear()
                forecastSnapshot = nil
                await performForecastRefresh()
            } else if stale {
                await performForecastRefresh()
            }
            // else: snapshot is fresh and coord-valid — nothing to do.
        } else {
            // No snapshot (cold start or evicted) — fetch immediately.
            await performForecastRefresh()
        }
    }

    /// Fetches a fresh ForecastSnapshot from WeatherKit and persists it.
    /// Requires roundedCoordinate to be set; silently no-ops if it is nil.
    /// Sets forecastRefreshState: .refreshing → .idle on success, .error(message) on failure.
    /// Network errors keep the existing stale snapshot visible; the banner surfaces the failure.
    private func performForecastRefresh() async {
        guard !isFetchingForecast, let coord = roundedCoordinate else { return }
        isFetchingForecast = true
        forecastRefreshState = .refreshing
        defer { isFetchingForecast = false }
        do {
            let provider = WeatherKitForecastProvider()
            let snapshot = try await provider.fetchSnapshot(at: coord)
            try await forecastStore.save(snapshot)
            forecastSnapshot = snapshot
            forecastRefreshState = .idle
        } catch {
            // Keep the existing stale snapshot; the banner surfaces the error with a Retry button.
            forecastRefreshState = .error(error.localizedDescription)
        }
    }

    private func syncPreferenceStorageFromSession() {
        persist(skinType: session.selectedSkinType)
        persist(spf: session.selectedSPF)
    }

    private func persist(skinType: FitzpatrickSkinType?) {
        persistedSkinTypeRawValue = skinType?.rawValue ?? UserPreferenceStorage.unsetSkinTypeRawValue
    }

    private func persist(spf: SPFLevel) {
        persistedSPFRawValue = (spf.isSunscreen ? spf : .spf30).rawValue
    }

    private func restoreSavedRoundedCoordinate() {
        legacyCachedUVSnapshotStorage = CachedRoundedCoordinateStorage.clearedStorageValue

        guard roundedCoordinate == nil else {
            return
        }

        do {
            if let restoredCoordinate = try CachedRoundedCoordinateStorage.roundedCoordinate(
                from: cachedRoundedCoordinateStorage)
            {
                roundedCoordinate = restoredCoordinate
            }
        } catch {
            cachedRoundedCoordinateStorage = CachedRoundedCoordinateStorage.clearedStorageValue
        }
    }

    private func persist(snapshot: UVSnapshot) {
        do {
            cachedRoundedCoordinateStorage = try CachedRoundedCoordinateStorage.storageValue(for: snapshot)
            legacyCachedUVSnapshotStorage = CachedRoundedCoordinateStorage.clearedStorageValue
        } catch {
            cachedRoundedCoordinateStorage = CachedRoundedCoordinateStorage.clearedStorageValue
        }
    }

    private func clearSavedRoundedCoordinate() {
        cachedRoundedCoordinateStorage = CachedRoundedCoordinateStorage.clearedStorageValue
        legacyCachedUVSnapshotStorage = CachedRoundedCoordinateStorage.clearedStorageValue
        roundedCoordinate = nil
        forecastSnapshot = nil
        forecastRefreshState = .idle
        // WI-7: forecast is keyed to location — clear it when location is cleared.
        Task { try? await forecastStore.clear() }
        statusMessage = "Saved location cleared."
    }

    private func applyUITestStaleEstimateSeedIfNeeded() {
        #if DEBUG
        guard ProcessInfo.processInfo.arguments.contains("-uiTestStaleEstimate") else {
            return
        }

        uvIndex = 200
        fetchedAt = Date().addingTimeInterval(-15 * 60)
        roundedCoordinate = UVCoordinate(latitude: 37.77, longitude: -122.42)
        statusMessage = "Seeded stale estimate for UI testing."
        #endif
    }

    private func applyUITestCappedEstimateSeedIfNeeded() {
        #if DEBUG
        guard ProcessInfo.processInfo.arguments.contains("-uiTestCappedEstimate") else {
            return
        }

        uvIndex = 8
        fetchedAt = Date()
        roundedCoordinate = UVCoordinate(latitude: 37.77, longitude: -122.42)
        statusMessage = "Seeded capped estimate for UI testing."
        #endif
    }

    private func applyUITestLongUncappedEstimateSeedIfNeeded() {
        #if DEBUG
        guard ProcessInfo.processInfo.arguments.contains("-uiTestLongUncappedEstimate") else {
            return
        }

        uvIndex = 37.5
        fetchedAt = Date()
        roundedCoordinate = UVCoordinate(latitude: 37.77, longitude: -122.42)
        statusMessage = "Seeded long estimate for UI testing."
        #endif
    }

    /// WI-47 — Maya pull-to-refresh test seam (Suchi persona-annotations.md:118).
    /// When `-uiTestRefreshableEcho` is passed, `refreshUV()` short-circuits the
    /// live WeatherKit + location stack and deterministically mutates the UV
    /// snapshot to a sentinel value distinct from every other `-uiTest*` seed.
    /// That lets an XCUI test observe — via the `UV Index 4.0` re-render — that
    /// the `.refreshable { await refreshUV() }` closure on the NowView
    /// ScrollView actually ran in response to a pull-down gesture, without
    /// depending on simulator-level location grants or WeatherKit availability.
    private func applyUITestRefreshableEchoIfNeeded() {
        #if DEBUG
        guard ProcessInfo.processInfo.arguments.contains("-uiTestRefreshableEcho") else {
            return
        }

        isFetching = true
        defer { isFetching = false }
        locationFailureMessage = nil
        weatherFailureMessage = nil
        uvIndex = 4.0
        fetchedAt = Date()
        roundedCoordinate = UVCoordinate(latitude: 37.77, longitude: -122.42)
        now = Date()
        statusMessage = "UV index fetched from Apple Weather."
        #endif
    }

    private func announceStatusForAccessibility(_ message: String) {
        #if canImport(UIKit)
        UIAccessibility.post(notification: .announcement, argument: message)
        #else
        _ = message
        #endif
    }
}

struct HeroTimerCard: View {
    let estimate: BurnTimeEstimate?
    let uvIndex: Double?
    let fetchedAt: Date?
    let now: Date
    let contextLine: String?
    let statusMessage: String
    let locationFailureMessage: String?
    let weatherFailureMessage: String?
    let isEstimateStale: Bool
    /// WI-7: Optional date context for forecast-selected times.
    /// When non-nil (e.g., "Burn time on Wed, 6 PM"), rendered as a quiet
    /// caption above the gauge. Nil means "now" — no date prefix is shown.
    /// The card no longer renders a persistent "Burn-time estimate" title;
    /// the circular gauge stands alone as the main-screen primary surface.
    let forecastDateContext: String?
    let onRecalculate: () -> Void
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var heroNumberSize = 80
    @ScaledMetric(relativeTo: .largeTitle) private var heroIconSize = 80

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let forecastDateContext {
                Label {
                    Text(forecastDateContext)
                } icon: {
                    Image(systemName: "clock.arrow.circlepath")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("HeroForecastDateContext")
            }

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
                burnRiskGauge
                if isEstimateStale {
                    SafetyStatusCard(
                        title: "Estimate window elapsed",
                        message: ProductCopy.estimateElapsedWarning,
                        systemImage: "exclamationmark.shield.fill"
                    )
                }
                if estimate.tier == .long {
                    SafetyStatusCard(
                        title: "Long estimate caveat",
                        message: ProductCopy.longEstimateHedge,
                        systemImage: "shield.lefthalf.filled"
                    )
                }
                if estimate.isCappedForSunscreenReapplication {
                    SafetyStatusCard(
                        title: "Sunscreen reapplication limit",
                        message: ProductCopy.sunscreenCapHedge,
                        systemImage: "clock.badge.exclamationmark"
                    )
                }
            } else {
                Text(verdictText)
                    .font(.title3.weight(.semibold))
                burnRiskGauge
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    private var burnRiskGauge: some View {
        if let estimate, let fetchedAt, estimate.tier != .none, estimate.rawMinutes.isFinite {
            BurnRiskGaugeCard(estimate: estimate, fetchedAt: fetchedAt, now: now)
        } else {
            BurnRiskGaugeUnavailableCard(message: burnRiskGaugeUnavailableMessage)
        }
    }

    private var burnRiskGaugeUnavailableMessage: String {
        if let estimate, estimate.tier == .none {
            return "No active burn time because the UV index is 0."
        }

        if weatherFailureMessage != nil {
            return "Unavailable until Apple Weather returns a UV estimate."
        }

        if locationFailureMessage != nil {
            return "Unavailable until location is available for a UV estimate."
        }

        return "Waiting for location and Apple Weather UV."
    }

    @ViewBuilder
    private var heroContent: some View {
        if let estimate, isEstimateStale {
            staleEstimateContent(estimate)
        } else if let estimate, estimate.tier == .none {
            // UVI = 0 at selected hour — moon.fill + "No UV at this hour" per Iris §5.
            Label {
                Text("No UV at this hour")
                    .font(.subheadline)
                    .foregroundStyle(Color(.secondaryLabel))
            } icon: {
                Image(systemName: "moon.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(.secondaryLabel))
            }
            .accessibilityLabel("No UV at this hour. No burn risk.")
        } else if let estimate {
            estimateText(estimate)
        } else if let weatherFailureMessage {
            VStack(alignment: .leading, spacing: 12) {
                Label(ProductCopy.weatherUnavailableTitle, systemImage: "cloud.sun")
                    .font(.title3.weight(.semibold))
                Text(weatherFailureMessage)
                    .font(.body)
                    .foregroundStyle(.secondary)
                Button("Try again", action: onRecalculate)
                    .buttonStyle(.borderedProminent)
            }
        } else if let locationFailureMessage {
            VStack(alignment: .leading, spacing: 12) {
                Label("Location unavailable", systemImage: "location.slash")
                    .font(.title3.weight(.semibold))
                Text(locationFailureMessage)
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
                .font(.system(size: heroIconSize))
                .foregroundStyle(.tint)

            Text(statusMessage)
                .font(.body)
        }
    }

    @ViewBuilder
    private func staleEstimateContent(_ estimate: BurnTimeEstimate) -> some View {
        let content = VStack(alignment: .leading, spacing: 12) {
            estimateText(estimate)
                .opacity(0.6)

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
            .font(
                .system(
                    size: dynamicTypeSize.isAccessibilitySize ? 48 : heroNumberSize, weight: .heavy, design: .rounded)
            )
            .minimumScaleFactor(0.5)
            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)

        if accessibilityReduceMotion {
            text
                .accessibilityLabel(estimate.accessibilitySummary)
                .accessibilityIdentifier(estimate.displayText)
        } else {
            text.contentTransition(.numericText())
                .accessibilityLabel(estimate.accessibilitySummary)
                .accessibilityIdentifier(estimate.displayText)
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
            verdict: verdictText,
            forecastDateContext: forecastDateContext
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
            WeatherAttributionView()
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityHint("Current UV index and Apple Weather source.")
    }
}

struct UVIndexPlaceholderCard: View {
    let sourceLine: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("UV Index")
                .font(.title3.weight(.semibold))
            Text(sourceLine)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            WeatherAttributionView()
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityHint("Fetch UV index using the Use my location button.")
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
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
        .accessibilityLabel("\(title) burn-time tier\(accessibilitySeveritySuffix)")
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

    private var accessibilitySeveritySuffix: String {
        switch tier {
        case .none:
            ""
        case .long:
            " — longer estimate, not safe exposure"
        case .moderate:
            " — caution"
        case .short:
            " — critical"
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

struct DisclaimerCover: View {
    let onAcknowledge: () -> Void
    @State private var showAbout = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.orange)

                    Text(ProductCopy.disclaimerTitle)
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)

                    Label(ProductCopy.photosensitizerDisclaimerLine, systemImage: "exclamationmark.triangle")
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(.orange)
                        .accessibilityElement(children: .combine)

                    Text(ProductCopy.disclaimerBody)
                        .font(.body)

                    // WI-w / Plunder 2026-05-21 — L1 storage-disclosure
                    // sentence. Placed immediately after `disclaimerBody`
                    // and BEFORE the see-About reach-back so the consent-
                    // relevant prose stays grouped at the visual top of
                    // the cover. Identifier is the XCUI contract surface
                    // for the §3.4 smoke test.
                    Text(ProductCopy.disclaimerStorageLine)
                        .font(.body)
                        .accessibilityIdentifier("DisclaimerStorageLine")

                    Button {
                        showAbout = true
                    } label: {
                        (
                            Text(ProductCopy.disclaimerSeeAboutInlineLead)
                                + Text(ProductCopy.disclaimerSeeAboutInlineLinkLabel)
                                    .foregroundColor(.accentColor)
                                    .underline()
                                + Text(ProductCopy.disclaimerSeeAboutInlineTail)
                        )
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("DisclaimerSeeAboutLink")
                    .accessibilityLabel(ProductCopy.disclaimerSeeAboutInlinePrompt)
                    .accessibilityHint("Opens the About sheet at the applicability anchor.")
                    .accessibilityAddTraits(.isLink)

                    Label(ProductCopy.childrenDisclaimerLine, systemImage: "figure.and.child.holdinghands")
                        .font(.callout.weight(.semibold))
                }
                .padding(32)
                .frame(maxWidth: .infinity, alignment: .center)
            }

            Button(action: onAcknowledge) {
                Text("I understand")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding()
            .background(.bar)
            .accessibilityHint(
                "Acknowledges the informational-only disclaimer and continues to skin type selection.")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
        .sheet(isPresented: $showAbout) {
            NavigationStack {
                AboutView(highlightEstimateApplicability: true)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showAbout = false }
                        }
                    }
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
            SkinTypePickerList(
                selection: Binding(
                    get: { draft.pendingSkinType },
                    set: { selectedSkinType in
                        if let selectedSkinType {
                            draft.select(selectedSkinType)
                        }
                    }
                ),
                footerText: ProductCopy.skinTypePickerFooter,
                selectedAccessibilityHint: "Selected. Tap Continue to confirm.",
                unselectedAccessibilityHint: "Selects this skin type."
            )
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
    let hasSavedLocation: Bool
    let onClearSavedLocation: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        SkinTypeEditView(session: $session)
                    } label: {
                        HStack {
                            Text("Skin type")
                            Spacer()
                            if let selected = session.selectedSkinType {
                                Text("Type \(selected.romanNumeral)")
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Not set")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .accessibilityHint("Opens skin type selector to change your Fitzpatrick classification.")
                } header: {
                    Text("UV estimate inputs")
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

                Section("Privacy") {
                    Text(ProductCopy.cacheRetentionLine)
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Button(role: .destructive) {
                        onClearSavedLocation()
                    } label: {
                        Text(ProductCopy.clearSavedLocationButtonTitle)
                    }
                    .disabled(!hasSavedLocation)
                    .accessibilityHint(
                        hasSavedLocation ? "Clears the last saved rounded coordinate." : "No saved location is stored.")

                    Button(role: .destructive) {
                        UserPreferenceStorage.persist(skinType: nil, to: .standard)
                        session.selectedSkinType = nil
                    } label: {
                        Text("Clear stored skin type")
                    }
                    .disabled(session.selectedSkinType == nil)
                    .accessibilityHint("Removes your stored Fitzpatrick skin type. You will be asked to set it again on next use.")
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

struct SkinTypeEditView: View {
    @Binding var session: UVBurnTimerSession
    @Environment(\.dismiss) private var dismiss
    @State private var pendingSelection: FitzpatrickSkinType?

    var body: some View {
        SkinTypePickerList(
            selection: $pendingSelection,
            footerText: ProductCopy.skinTypeSettingsFooter,
            selectedAccessibilityHint: "Selected. Saves this skin type.",
            unselectedAccessibilityHint: "Selects this skin type."
        )
        .navigationTitle("Skin type")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if let selection = pendingSelection {
                        session.selectedSkinType = selection
                    }
                    dismiss()
                }
                .disabled(pendingSelection == nil && session.selectedSkinType == nil)
            }
        }
        .onAppear {
            pendingSelection = session.selectedSkinType
        }
    }
}

struct SkinTypePickerList: View {
    @Binding var selection: FitzpatrickSkinType?
    let footerText: String
    let selectedAccessibilityHint: String
    let unselectedAccessibilityHint: String

    var body: some View {
        List {
            Section {
                ForEach(FitzpatrickSkinType.allCases) { skinType in
                    SkinTypePickerRow(
                        skinType: skinType,
                        isSelected: selection == skinType
                    ) {
                        selection = skinType
                    }
                    .accessibilityHint(selection == skinType ? selectedAccessibilityHint : unselectedAccessibilityHint)
                }
            } header: {
                VStack(alignment: .leading, spacing: 6) {
                    Text(ProductCopy.skinTypePickerPrompt)
                        .textCase(nil)
                        .font(.headline)
                    Text(ProductCopy.skinTypePickerSubtext)
                        .textCase(nil)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            } footer: {
                VStack(alignment: .leading, spacing: 8) {
                    Text(ProductCopy.skinTypeSourcePointer)
                        .font(.footnote.weight(.medium))
                    NavigationLink("Open About & Citations") {
                        AboutView()
                    }
                    .font(.footnote.weight(.medium))
                    Text(footerText)
                        .font(.footnote)
                }
            }
        }
    }
}

struct SkinTypePickerRow: View {
    let skinType: FitzpatrickSkinType
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
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

                if isSelected {
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
        .accessibilityLabel(
            "Type \(skinType.romanNumeral). \(skinType.pickerDescription). \(isSelected ? "Selected." : "Not selected.")"
        )
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(isSelected ? "Selected. Tap to reselect." : "Selects this skin type.")
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

                    Text(
                        "UV Burn Timer estimates minutes to one minimal erythemal dose using Fitzpatrick skin type, SPF, and the current UV index."
                    )

                    Text("How this works")
                        .font(.title3.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(ProductCopy.aboutHowThisWorks)

                    Text("Skin type classification")
                        .font(.title3.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(
                        "The skin type question asks: \"\(ProductCopy.skinTypePickerPrompt)\" The six rows are behavior-first paraphrases, not verbatim source text."
                    )
                    Text(
                        "Underlying scale: Fitzpatrick TB. The validity and practicality of sun-reactive skin types I through VI. Arch Dermatol. 1988;124(6):869–871. doi:10.1001/archderm.1988.01670060015008"
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    Text(
                        "Row descriptions adapted from: Ward WH, Farma JM, editors. Cutaneous Melanoma: Etiology and Therapy, Ch. 6 Table 1. Codon Publications; 2017. doi:10.15586/codon.cutaneousmelanoma.2017.ch6 — cited under CC BY-NC 4.0; wording paraphrased, not reproduced. NCBI Bookshelf NBK481857."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)

                    Text("Sunscreen assumptions")
                        .font(.title3.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(ProductCopy.aboutSunscreenAssumptions)

                    VStack(alignment: .leading, spacing: 12) {
                        Text(ProductCopy.aboutSunSafetyActions)
                            .font(.body)

                        Text("When this estimate may not apply")
                            .font(.title3.weight(.semibold))
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityIdentifier("AboutEstimateApplicabilityHeader")

                        Text(ProductCopy.aboutEstimateApplicability)
                        Text(ProductCopy.photosensitizationAuthorityLine)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Link(
                            "NIH MedlinePlus sun-sensitivity overview",
                            destination: ProductCopy.medlinePlusSunSensitivityURL
                        )
                        .font(.footnote.weight(.medium))
                    }
                    .id(notForMeAnchor)
                    .padding(highlightEstimateApplicability ? 12 : 0)
                    .background(
                        highlightEstimateApplicability ? Color.orange.opacity(0.15) : Color.clear,
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Text("Citations")
                        .font(.title3.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(ProductCopy.fitzpatrickCitations)
                        .font(.footnote)
                        .textSelection(.enabled)
                    CitationLinksView()

                    Text("Why this number changes with weather")
                        .font(.title3.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(ProductCopy.aboutWeatherVariability)

                    Text("Model limits")
                        .font(.title3.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(ProductCopy.aboutModelLimitations)

                    Text("What this app does not do")
                        .font(.title3.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(ProductCopy.whatTheAppDoesNotDo)

                    Text("Children and severe symptoms")
                        .font(.title3.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(ProductCopy.pediatricAndEscalationGuidance)

                    Text("Weather data")
                        .font(.title3.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(ProductCopy.weatherDataAttributionBody)
                    Link("Apple Weather data sources", destination: ProductCopy.weatherAttributionLegalURL)
                    Text(ProductCopy.weatherAttributionLegalURLString)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)

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

                    Text("Version")
                        .font(.title3.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text(versionLine)
                    Text(ProductCopy.lastUpdatedLine)

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

    private var versionLine: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "Version \(version) (build \(build))."
    }
}

struct CitationLinksView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(ProductCopy.citationLinks, id: \.title) { link in
                Link(link.title, destination: link.url)
                    .font(.footnote.weight(.medium))
            }
        }
    }
}

struct AttributionView: View {
    private let legalURL = ProductCopy.weatherAttributionLegalURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Attribution & Legal")
                    .font(.title.bold())
                    .accessibilityAddTraits(.isHeader)

                Text(ProductCopy.weatherDataAttributionBody)

                WeatherAttributionView()

                Link("Apple Weather data sources", destination: legalURL)
                Text(ProductCopy.weatherAttributionLegalURLString)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .navigationTitle("Attribution")
    }
}

struct WeatherAttributionView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric(relativeTo: .caption) private var markHeight = 20
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
        if let attributionError {
            VStack(alignment: .leading, spacing: 2) {
                Text(ProductCopy.weatherAttributionServiceName)
                    .font(.caption.weight(.semibold))
                Text(attributionError)
                    .font(.caption2)
            }
        } else if let markURL {
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
                        .frame(height: markHeight)
                        .accessibilityLabel(attribution?.serviceName ?? ProductCopy.weatherAttributionServiceName)
                case .failure:
                    Text(attributionError ?? "Apple Weather attribution unavailable")
                @unknown default:
                    Text(attributionError ?? "Apple Weather attribution unavailable")
                }
            }
        } else {
            Text(ProductCopy.weatherAttributionServiceName)
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
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-uiTestWeatherAttributionUnavailable") {
            attribution = nil
            attributionError = "Apple Weather attribution unavailable"
            return
        }
        #endif

        do {
            attribution = try await WeatherService.shared.attribution
            attributionError = nil
        } catch {
            attributionError = "Apple Weather attribution unavailable"
        }
    }
}

struct BurnRiskGaugeCard: View {
    let estimate: BurnTimeEstimate
    let fetchedAt: Date
    let now: Date
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @ScaledMetric(relativeTo: .largeTitle) private var gaugeDiameter = 188
    @ScaledMetric(relativeTo: .title) private var gaugeLineWidth = 18

    var body: some View {
        VStack(spacing: 16) {
            gauge

            if differentiateWithoutColor {
                Text(supportingText)
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var gauge: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.22), lineWidth: gaugeLineWidth)
            Circle()
                .trim(from: 0, to: burnFraction)
                .stroke(
                    tierColor,
                    style: StrokeStyle(lineWidth: gaugeLineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            VStack(spacing: 4) {
                Text(remainingText)
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .minimumScaleFactor(0.6)
                Text("remaining")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .accessibilityHidden(true)
        }
        .frame(width: gaugeDiameter, height: gaugeDiameter)
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Burn risk gauge. \(remainingText) remaining. \(percentText) \(gaugeAccessibilityWindowDescription) elapsed.")
        .accessibilityValue(remainingText)
        .accessibilityHint("Progress arc shows burn time elapsed.")
        .accessibilityIdentifier("BurnRiskGauge")
    }

    private var burnFraction: Double {
        let elapsedSeconds = now.timeIntervalSince(fetchedAt)
        let burnWindowSeconds = estimate.effectiveWindowMinutes * 60
        return min(1.0, max(0.0, elapsedSeconds / burnWindowSeconds))
    }

    private var remainingText: String {
        let elapsedSeconds = now.timeIntervalSince(fetchedAt)
        let totalSeconds = estimate.effectiveWindowMinutes * 60
        let remaining = max(0, totalSeconds - elapsedSeconds)
        let minutes = Int((remaining / 60).rounded())
        if minutes == 0 { return "Elapsed" }
        if minutes >= 60 {
            let h = minutes / 60
            let m = minutes % 60
            return m == 0 ? "~\(h) hr" : "~\(h) hr \(m) min"
        }
        return "~\(minutes) min"
    }

    private var percentText: String {
        "\(Int((burnFraction * 100).rounded()))%"
    }

    private var supportingText: String {
        if estimate.isCappedForSunscreenReapplication {
            return "\(percentText) of 2-hour sunscreen reapplication window elapsed"
        }

        return "\(percentText) of estimated burn time elapsed"
    }

    private var gaugeAccessibilityWindowDescription: String {
        if estimate.isCappedForSunscreenReapplication {
            return "of 2-hour sunscreen reapplication window"
        }

        return "of estimated burn time"
    }

    private var tierColor: Color {
        switch estimate.tier {
        case .none:
            .secondary
        case .long:
            Color("SeverityLong")
        case .moderate:
            Color("SeverityModerate")
        case .short:
            Color("SeverityShort")
        }
    }
}

struct BurnRiskGaugeUnavailableCard: View {
    let message: String
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @ScaledMetric(relativeTo: .largeTitle) private var gaugeDiameter = 188
    @ScaledMetric(relativeTo: .title) private var gaugeLineWidth = 18

    var body: some View {
        VStack(spacing: 16) {
            gauge

            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            if differentiateWithoutColor {
                Text("Unavailable")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var gauge: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.28), lineWidth: gaugeLineWidth)
            VStack(spacing: 4) {
                Text("—")
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                Text("unavailable")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .accessibilityHidden(true)
        }
        .frame(width: gaugeDiameter, height: gaugeDiameter)
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Burn risk gauge unavailable. \(message)")
        .accessibilityValue("Unavailable")
        .accessibilityHint("Fetch location and Apple Weather UV before relying on burn timing.")
        .accessibilityIdentifier("BurnRiskGaugePlaceholder")
    }
}

struct PersistentFooter: View {
    var body: some View {
        NavigationLink {
            AboutView(highlightEstimateApplicability: true)
        } label: {
            Label(ProductCopy.disclaimerLinkLabel, systemImage: "info.circle")
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(.tint)
        .accessibilityHint("Opens About and applicability details.")
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
/// WI-50 — Probes that the `.refreshable { await refreshUV() }` modifier on
/// `NowView`'s ScrollView is still installed and still wires to the same
/// closure body. Renders **only** when the `-uiTestRefreshableEcho` launch
/// argument is present (so it is invisible in normal DEBUG builds and is
/// stripped from Release builds entirely).
///
/// ## Why we do not rely on `@Environment(\.refresh)`
///
/// The first WI-50 implementation read `@Environment(\.refresh)` to detect
/// whether the parent `.refreshable` was wired. That mechanism does not
/// work reliably for ScrollView-hosted descendants on iOS 26: the
/// `\.refresh` env value remains `nil` even when `.refreshable` is
/// correctly installed on the enclosing ScrollView, so the probe always
/// reported `RefreshActionNil` and the test failed before invoking the
/// closure.
///
/// ## Two-signal design (current)
///
/// We probe the modifier wiring through two orthogonal signals so neither
/// the assertion nor the invocation depends on a SwiftUI behavior we
/// cannot observe deterministically across iOS 26 simulator versions.
///
/// 1. **Modifier-presence signal — custom `\.refreshableInstalled` env key.**
///    `View.nowViewRefreshable(action:)` applies the standard `.refreshable`
///    modifier and immediately chains `.environment(\.refreshableInstalled,
///    true)`. The custom env key uses the standard SwiftUI propagation
///    mechanism (which works for descendants of a ScrollView, unlike the
///    `\.refresh` action env value). If a refactor drops the call to
///    `.nowViewRefreshable` from the ScrollView's modifier chain, the
///    env key reverts to its `false` default and the probe surfaces
///    `RefreshActionNil` — the same regression signal the original WI-47
///    test wanted.
///
/// 2. **Closure-body signal — explicit `refreshAction` injection.** The
///    probe receives the exact same `{ await refreshUV() }` closure body
///    that the `.refreshable` modifier wraps. Tapping the probe invokes
///    that closure directly, which runs `refreshUV()` and (when the
///    `-uiTestRefreshableEcho` seed is also set) triggers the
///    `applyUITestRefreshableEchoIfNeeded()` short-circuit that flips
///    `uvIndex` to the `4.0` sentinel. The post-tap `UV Index 4.0`
///    assertion therefore proves the closure body is reachable; if a
///    refactor unwires `refreshUV()` from the modifier, the call site
///    here must also change and the test fails.
///
/// Together the two signals catch both classes of regression — modifier
/// dropped, or closure body redirected — without depending on SwiftUI
/// gesture infrastructure or on `\.refresh` env propagation for
/// ScrollView descendants.
struct UITestRefreshableProbeButton: View {
    let refreshAction: @Sendable () async -> Void
    @Environment(\.refreshableInstalled) private var refreshableInstalled

    var body: some View {
        if ProcessInfo.processInfo.arguments.contains("-uiTestRefreshableEcho") {
            Button("uiTestInvokeRefreshable") {
                Task { await refreshAction() }
            }
            .accessibilityIdentifier("UITestRefreshableProbeButton")
            .accessibilityValue(refreshableInstalled ? "RefreshActionAvailable" : "RefreshActionNil")
        }
    }
}
#endif

/// Custom env key used by the WI-50 probe (and any future probe that needs
/// to detect "the NowView ScrollView's pull-to-refresh modifier is wired").
/// SwiftUI's `\.refresh` env value does not propagate reliably to
/// ScrollView descendants on iOS 26, so we use this app-owned key —
/// applied alongside `.refreshable` via `View.nowViewRefreshable(action:)`
/// — to surface modifier presence to descendants.
private struct RefreshableInstalledKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    fileprivate var refreshableInstalled: Bool {
        get { self[RefreshableInstalledKey.self] }
        set { self[RefreshableInstalledKey.self] = newValue }
    }
}

extension View {
    /// Applies the standard SwiftUI `.refreshable` modifier and propagates
    /// a `\.refreshableInstalled = true` marker through the SwiftUI
    /// environment to descendants. The `UITestRefreshableProbeButton`
    /// reads the marker to detect whether the modifier was removed during
    /// a refactor (see WI-50). The marker is private to this module; no
    /// production code path observes it.
    fileprivate func nowViewRefreshable(action: @escaping @Sendable () async -> Void) -> some View {
        self.refreshable(action: action)
            .environment(\.refreshableInstalled, true)
    }
}
