// ForecastPickerView.swift — WI-7: forecast day-and-hour picker.
//
// Design: .squad/designs/wi-7/iris-picker-spec.md
// Iris §8 checklist items 1–10 implemented (2026-05-21).

import SwiftUI
import UVBurnTimerCore

// MARK: - Refresh state machine (Iris §8 item 9)

/// Tracks whether a background forecast refresh is in flight or has failed.
/// Drives the stale-data banner in `ForecastPickerView`.
public enum ForecastRefreshState: Equatable {
    /// No refresh in flight; banner hidden.
    case idle
    /// WeatherKit call in flight; stale data visible below.
    case refreshing
    /// Last attempt failed; stale data still visible; Retry shown.
    case error(String)
}

/// Forecast day-and-hour picker for WI-7.
///
/// Renders a scrollable list of forecast days (always D through D+6;
/// D+7 through D+9 are revealed via an inline toggle row) and a horizontal
/// hourly strip for the currently-selected day.
///
/// - Parameters:
///   - selectedDate: Bidirectional binding for the picked day-and-hour timestamp.
///   - forecastDays: Day-level forecast data from ``ForecastSnapshot/days``.
///   - forecastHours: Hour-level forecast data from ``ForecastSnapshot/hours``.
///   - now: Current clock time — drives current-hour dot and default-selection init.
///   - forecastRefreshState: Current background-refresh state; drives the stale-data banner.
///   - onRetry: Called when the user taps the Retry button in the error banner.
///   - onUserSelection: Called on every user-initiated selection (day or hour tap).
public struct ForecastPickerView: View {
    @Binding public var selectedDate: Date
    public let forecastDays: [DayForecast]
    public let forecastHours: [HourForecast]
    /// Current clock time passed from the owner (updates every 60 s via RootView timer).
    public let now: Date
    /// Background-refresh state — drives the stale-data banner (Iris §8 item 9).
    public let forecastRefreshState: ForecastRefreshState
    /// Called when the user taps "Retry" in the error banner.
    public let onRetry: () -> Void
    /// Called whenever the user explicitly selects a date.
    public let onUserSelection: (Date) -> Void

    @State private var showExtendedDays: Bool = false
    @State private var isRotatingRefreshIcon: Bool = false
    @AccessibilityFocusState private var day8Focused: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorSchemeContrast) private var contrast

    public init(
        selectedDate: Binding<Date>,
        forecastDays: [DayForecast],
        forecastHours: [HourForecast],
        now: Date = Date(),
        forecastRefreshState: ForecastRefreshState = .idle,
        onRetry: @escaping () -> Void = {},
        onUserSelection: @escaping (Date) -> Void = { _ in }
    ) {
        self._selectedDate = selectedDate
        self.forecastDays = forecastDays
        self.forecastHours = forecastHours
        self.now = now
        self.forecastRefreshState = forecastRefreshState
        self.onRetry = onRetry
        self.onUserSelection = onUserSelection
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerLabel
            if forecastDays.isEmpty {
                skeletonContent
            } else {
                // Stale-data banner: only visible when we already have data to show (Iris §8 item 9).
                // Never shown over the skeleton — that's the cold-start state, not a stale-data state.
                staleBannerView
                dayListSection
                Divider()
                    .padding(.horizontal, 16)
                hourlyStripSection
                pickerFooter
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        // Card chrome matching existing Material Card pattern in AppViews.swift.
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        // Banner appears/disappears with .easeInOut(0.2); instant under Reduce Motion (Iris §8 item 9).
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: forecastRefreshState)
    }

    // MARK: - Footer (WI-bundleG Group GG)
    //
    // GG1 — Apple Weather attribution (WeatherKit §5.1.1). The forecast picker
    //       is a WeatherKit-derived data surface and the attribution must be
    //       visible whenever the surface is rendered. The legal URL is the
    //       canonical WeatherKit attribution target per ProductCopy.
    //
    // GG2 — L3 photosensitizer reach-back (Plunder C3 floor). The picker is
    //       its own result surface (selecting a future hour drives the
    //       burn-time gauge) and needs its own reach-back path to
    //       AboutView(highlightEstimateApplicability: true), parity with
    //       the main-screen toolbar ⓘ EstimateInfoButton.

    private var pickerFooter: some View {
        VStack(alignment: .leading, spacing: 6) {
            Divider()
                .padding(.horizontal, 16)
                .padding(.top, 4)
            NavigationLink {
                AboutView(highlightEstimateApplicability: true)
            } label: {
                Label("Is this estimate for me?", systemImage: "info.circle")
                    .font(.footnote.weight(.medium))
            }
            .foregroundStyle(.tint)
            .accessibilityLabel("Is this estimate for me?")
            .accessibilityHint("Opens photosensitization, medication, and sunscreen assumption caveats.")
            .accessibilityIdentifier("ForecastPickerEstimateInfoButton")
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .padding(.horizontal, 16)

            Link(destination: ProductCopy.weatherAttributionLegalURL) {
                Text("Source: \(ProductCopy.weatherAttributionServiceName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Source: \(ProductCopy.weatherAttributionServiceName)")
            .accessibilityHint("Opens the Apple Weather legal attribution page.")
            .accessibilityIdentifier("ForecastPickerAttribution")
            // WI-bundleQ / Iris L03 (Loop-13) — raise to 44pt HIG tap-target
            // floor. Mirrors the sibling ForecastPickerEstimateInfoButton
            // (line 129) and the L1 / L3 / footer reach-back rows.
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
            .padding(.horizontal, 16)
            .padding(.bottom, 4)
        }
    }

    // MARK: - Header

    private var headerLabel: some View {
        Text("UV Forecast")
            .font(.headline)
            .accessibilityAddTraits(.isHeader)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
    }

    // MARK: - Stale-data banner (Iris §8 item 9)

    /// Slim row below the card header during a background refresh or after a failed refresh.
    /// Hidden when state is `.idle` or when there is no snapshot yet (skeleton handles cold start).
    @ViewBuilder
    private var staleBannerView: some View {
        switch forecastRefreshState {
        case .idle:
            EmptyView()
        case .refreshing:
            HStack(spacing: 6) {
                Image(systemName: "arrow.clockwise")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    // Slow rotation under normal motion; static under Reduce Motion (Iris §8 item 9).
                    .rotationEffect(.degrees(isRotatingRefreshIcon ? 360 : 0))
                    .animation(
                        reduceMotion ? nil : .linear(duration: 1.5).repeatForever(autoreverses: false),
                        value: isRotatingRefreshIcon
                    )
                    .onAppear { isRotatingRefreshIcon = true }
                    .onDisappear { isRotatingRefreshIcon = false }
                Text("Updating forecast…")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 28, alignment: .leading)
            .padding(.horizontal, 16)
            .background(Color(.systemYellow).opacity(0.12))
        case .error:
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.icloud")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text("Could not update")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Could not update forecast")
                Spacer()
                // 44pt Retry button (Iris §8 item 9).
                Button("Retry") {
                    onRetry()
                }
                .font(.footnote)
                .foregroundStyle(.tint)
                .frame(minHeight: 44)
            }
            .frame(maxWidth: .infinity, minHeight: 28, alignment: .leading)
            .padding(.horizontal, 16)
            .background(Color(.systemRed).opacity(0.08))
        }
    }

    // MARK: - Increase Contrast helpers (Iris §8 item 10)

    /// Border width for badge pills and band chips — 1pt when Increase Contrast is on, 0 otherwise.
    private var pillBorderWidth: CGFloat {
        contrast == .increased ? 1 : 0
    }

    /// Band bar height for hourly cells — 6pt when Increase Contrast is on, 4pt otherwise.
    private var bandBarHeight: CGFloat {
        contrast == .increased ? 6 : 4
    }

    /// Selected row background opacity — 0.25 when Increase Contrast is on, 0.12 otherwise.
    private var selectedRowOpacity: Double {
        contrast == .increased ? 0.25 : 0.12
    }

    // MARK: - WHO Band Helpers (Iris §1 band-color table)

    /// WHO band fill color for a given UVI value (Iris §1).
    private func whoBandColor(for uvi: Double) -> Color {
        switch uvi {
        case ..<3:  return Color(.systemGreen)
        case ..<6:  return Color(.systemYellow)
        case ..<8:  return Color(.systemOrange)
        case ..<11: return Color(.systemRed)
        default:    return Color(.systemPurple)
        }
    }

    /// WHO band name for a given UVI value.
    private func whoBandName(for uvi: Double) -> String {
        switch uvi {
        case ..<3:  return "Low"
        case ..<6:  return "Moderate"
        case ..<8:  return "High"
        case ..<11: return "Very High"
        default:    return "Extreme"
        }
    }

    /// WI-bundleR / Iris L01 (Loop-13) — WCAG 2.2 AA contrast for WHO-band
    /// pills. Apple system colors against white at `.headline` size:
    /// - `.systemGreen` / `.systemYellow` / `.systemOrange` / `.systemRed`
    ///   all measure < 4.5:1 against white in Light Mode (~2.0–3.9:1).
    /// - `.systemPurple` against white sits at ~4.7:1 (passes AA at the
    ///   `.headline` weight we render).
    /// Switching the load-bearing pill / chip / band-bar text to `.black`
    /// for everything below the Extreme band restores AA across every
    /// surface that reads this color. Black-on-Purple measures only
    /// ~4.4:1 (fails AA), so the Extreme band is the one row where
    /// `.white` is the better choice. Pinned by `test_R1_*`.
    private func whoBandTextColor(for uvi: Double) -> Color {
        uvi < 11 ? .black : .white
    }

    // MARK: - Day list

    private var dayListSection: some View {
        VStack(spacing: 0) {
            // Days 0–6 — always visible (D through D+6 per v3 spec §2.1).
            ForEach(Array(forecastDays.prefix(7).enumerated()), id: \.offset) { index, day in
                dayRow(day, index: index)
            }
            // Days 7–9 — revealed on toggle.
            if showExtendedDays && forecastDays.count > 7 {
                extendedDayRows
            }
            // Reveal affordance — hidden when ≤ 7 days available (§3.6).
            if forecastDays.count > 7 {
                revealAffordanceRow
            }
        }
    }

    @ViewBuilder
    private var extendedDayRows: some View {
        ForEach(Array(forecastDays.dropFirst(7).enumerated()), id: \.offset) { offset, day in
            if offset == 0 {
                // VoiceOver focus jumps to day 8 on expand (§2.4).
                dayRow(day, index: 7 + offset)
                    .accessibilityFocused($day8Focused, equals: true)
                    .transition(expandTransition)
            } else {
                dayRow(day, index: 7 + offset)
                    .transition(expandTransition)
            }
        }
    }

    /// Slide+fade under normal motion; instant under Reduce Motion (§2.3).
    private var expandTransition: AnyTransition {
        reduceMotion ? .identity : .move(edge: .top).combined(with: .opacity)
    }

    // MARK: - Day row (Iris §8 items 1 + 2)

    @ViewBuilder
    private func dayRow(_ day: DayForecast, index: Int) -> some View {
        let isSelected = selectedDay(matches: day)
        let isToday = Calendar.current.isDateInToday(day.date)
        Button {
            selectDay(day)
        } label: {
            HStack(alignment: .center, spacing: 12) {
                // Two-line date block: primary day name + secondary short date (Iris §1).
                VStack(alignment: .leading, spacing: 1) {
                    // "Today" or abbreviated weekday; .headline when selected or today, .body otherwise.
                    Text(isToday ? "Today" : day.date.formatted(.dateTime.weekday(.abbreviated)))
                        .font(isSelected || isToday ? .headline : .body)
                        .foregroundStyle(.primary)
                    Text(day.date.formatted(.dateTime.month(.defaultDigits).day()))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .fixedSize(horizontal: false, vertical: true)

                Spacer()

                // Numeric badge pill for D–D+6; band-name chip for D+7–D+9 (Iris §1).
                if index < 7 {
                    uviBadgePill(uvi: day.dailyMaxUVI)
                } else {
                    bandChip(uvi: day.dailyMaxUVI)
                }
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 52)
            // Increase Contrast: selected opacity 0.25 (up from 0.12) (Iris §8 item 10).
            .background(isSelected ? Color.accentColor.opacity(selectedRowOpacity) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(dayRowA11yLabel(day: day, isToday: isToday))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    /// Numeric UVI pill badge — 40×22pt, cornerRadius 11pt, WHO band fill (Iris §1).
    /// Increase Contrast: 1pt Color(.label) border overlay (Iris §8 item 10).
    private func uviBadgePill(uvi: Double) -> some View {
        Text("\(Int(uvi))")
            .font(.headline.bold())
            .foregroundStyle(whoBandTextColor(for: uvi))
            .frame(width: 40, height: 22)
            .background(whoBandColor(for: uvi), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .stroke(Color(.label), lineWidth: pillBorderWidth)
            )
    }

    /// Band-name chip — 56×22pt, cornerRadius 11pt, WHO band fill, no numeric (Iris §1).
    /// Increase Contrast: 1pt Color(.label) border overlay (Iris §8 item 10).
    private func bandChip(uvi: Double) -> some View {
        Text(whoBandName(for: uvi))
            .font(.caption.bold())
            .foregroundStyle(whoBandTextColor(for: uvi))
            .frame(width: 56, height: 22)
            .background(whoBandColor(for: uvi), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .stroke(Color(.label), lineWidth: pillBorderWidth)
            )
    }

    // MARK: - Reveal affordance row (Iris §3, §8 item 7 — verified + chevron animation)

    private var revealAffordanceRow: some View {
        Button {
            toggleExtendedDays()
        } label: {
            HStack(spacing: 8) {
                // Single symbol rotated 180° for up/down — .easeInOut(0.15) per Iris §3.
                // Under Reduce Motion: instant rotation (animation nil = no tween).
                Image(systemName: "chevron.down.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color(.secondaryLabel))
                    .rotationEffect(.degrees(showExtendedDays ? 180 : 0))
                    .animation(
                        reduceMotion ? nil : .easeInOut(duration: 0.15),
                        value: showExtendedDays
                    )

                Text(showExtendedDays ? "Show fewer days" : "3 more days")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            showExtendedDays ? "Show fewer forecast days" : "Show 3 more forecast days"
        )
        .accessibilityHint(
            showExtendedDays
                ? "Double-tap to collapse days 8 through 10."
                : "Double-tap to reveal days 8 through 10."
        )
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Hourly strip (horizontal scroll with snap, Iris §8 item 4; AX4 vertical Iris §8 item 8)

    private var hourlyStripSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Hourly")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .accessibilityAddTraits(.isHeader)
                .padding(.horizontal, 16)
                .padding(.top, 12)

            let dayHours = hoursForSelectedDay()
            // AX4+ (XXXLarge Dynamic Type): switch to vertical list to prevent illegible truncation.
            // Breakpoint: .xxLarge (AX3+). Iris empirical flag: test at AX4 (xxxLarge) on simulator;
            // lower to .xLarge if horizontal cells still clip at that size.
            if dynamicTypeSize >= .xxLarge {
                hourlyVerticalList(dayHours)
            } else {
                hourlyHorizontalStrip(dayHours)
            }
        }
    }

    /// Horizontal scroll strip with snap-to-cell and auto-center on day change (Iris §8 item 4).
    private func hourlyHorizontalStrip(_ dayHours: [HourForecast]) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 4) {
                    if dayHours.isEmpty {
                        ForEach(0..<6, id: \.self) { _ in hourSkeletonCell }
                    } else {
                        ForEach(dayHours, id: \.timestamp) { hour in
                            hourCellWrapped(for: hour)
                                .id(hour.timestamp)
                        }
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .scrollTargetBehavior(.viewAligned)
            .onChange(of: selectedDate) { _, _ in
                scrollToSelectedHour(in: dayHours, proxy: proxy)
            }
            .onAppear {
                scrollToSelectedHour(in: dayHours, proxy: proxy)
            }
        }
    }

    private func scrollToSelectedHour(in dayHours: [HourForecast], proxy: ScrollViewProxy) {
        guard let hour = dayHours.first(where: { isSelectedHour($0.timestamp) }) else { return }
        if reduceMotion {
            proxy.scrollTo(hour.timestamp, anchor: .center)
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(hour.timestamp, anchor: .center)
            }
        }
    }

    // MARK: - AX4+ vertical list layout (Iris §8 item 8)

    /// Vertical list for Dynamic Type sizes ≥ .xxLarge.
    /// Each row: HStack { hourLabel | UVI integer or dash | band chip } — 44pt min height.
    @ViewBuilder
    private func hourlyVerticalList(_ dayHours: [HourForecast]) -> some View {
        if dayHours.isEmpty {
            ForEach(0..<6, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color(.systemFill))
                    .frame(height: 44)
                    .padding(.horizontal, 16)
            }
        } else {
            ForEach(dayHours, id: \.timestamp) { hour in
                hourlyVerticalRow(for: hour)
            }
        }
    }

    /// Single row in the AX4+ vertical layout: time | UVI | band chip (Iris §8 item 8).
    private func hourlyVerticalRow(for hour: HourForecast) -> some View {
        let isSelected = isSelectedHour(hour.timestamp)
        let isNighttime = hour.uvIndex == 0

        return Button {
            selectHour(hour)
        } label: {
            HStack(spacing: 12) {
                Text(hour.timestamp.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated))))
                    .font(.body)
                    .foregroundStyle(Color(.secondaryLabel))
                    .frame(width: 64, alignment: .leading)
                Text(isNighttime ? "—" : "\(Int(hour.uvIndex))")
                    .font(.headline.bold())
                    .foregroundStyle(isNighttime ? Color(.tertiaryLabel) : Color(.label))
                if !isNighttime {
                    bandChip(uvi: hour.uvIndex)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 44)
            .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(hourCellA11yLabel(for: hour))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    /// Wraps hourCell in a VStack to host the current-hour dot outside the cell frame (Iris §2).
    @ViewBuilder
    private func hourCellWrapped(for hour: HourForecast) -> some View {
        let isCurrent = isCurrentHour(hour.timestamp)
        let isSelected = isSelectedHour(hour.timestamp)
        VStack(spacing: 4) {
            hourCell(for: hour)
            // Current-hour indicator: circle.fill 5pt Color(.label), below cell (Iris §2).
            // Hidden (clear) when the cell is selected — accent border already distinguishes it.
            Circle()
                .fill(isCurrent && !isSelected ? Color(.label) : Color.clear)
                .frame(width: 5, height: 5)
        }
    }

    /// One hourly cell per Iris §2 anatomy: hour label → icon → UVI → band bar (Iris §8 item 3).
    @ViewBuilder
    private func hourCell(for hour: HourForecast) -> some View {
        let isSelected = isSelectedHour(hour.timestamp)
        let isNighttime = hour.uvIndex == 0
        let bandColor = whoBandColor(for: hour.uvIndex)

        Button {
            selectHour(hour)
        } label: {
            VStack(spacing: 0) {
                // Top section: hour label, icon, UVI scalar — centered vertically.
                VStack(spacing: 4) {
                    Spacer(minLength: 0)
                    Text(hour.timestamp.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated))))
                        .font(.caption2)
                        .foregroundStyle(Color(.secondaryLabel))
                    // sun.max.fill tinted to WHO band color; moon.fill in tertiaryLabel for UVI=0.
                    Image(systemName: isNighttime ? "moon.fill" : "sun.max.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(isNighttime ? Color(.tertiaryLabel) : bandColor)
                    // "—" dash for nighttime/UVI=0; integer scalar for daytime.
                    Text(isNighttime ? "—" : "\(Int(hour.uvIndex))")
                        .font(.headline.bold())
                        .foregroundStyle(isNighttime ? Color(.tertiaryLabel) : Color(.label))
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                // 4pt band bar at bottom — clear for nighttime (Iris §2).
                // Increase Contrast: 6pt height (Iris §8 item 10).
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(isNighttime ? Color.clear : bandColor)
                    .frame(height: bandBarHeight)
            }
            .frame(width: 60, height: 88)
            .background(
                isSelected
                    ? Color.accentColor.opacity(0.15)
                    : Color(.secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
            // 2pt accent border on selected cell (Iris §2).
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(hourCellA11yLabel(for: hour))
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var hourSkeletonCell: some View {
        // IRIS-HOOK: shimmer animation overlay.
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color(.systemFill))
            .frame(width: 60, height: 88)
    }

    // MARK: - Loading skeleton (forecastDays empty → cold start / no snapshot)

    /// 10 skeleton day rows + 6 skeleton hourly cells (§1.2 / §6).
    private var skeletonContent: some View {
        VStack(spacing: 0) {
            ForEach(0..<10, id: \.self) { _ in
                HStack(spacing: 12) {
                    // Day label placeholder: 88×14pt (§1.2 skeleton anatomy).
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color(.systemFill))
                        .frame(width: 88, height: 14)
                    Spacer()
                    // Badge placeholder: 36×20pt pill (§1.2).
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(.systemFill))
                        .frame(width: 36, height: 20)
                }
                .padding(.horizontal, 16)
                .frame(height: 52)
            }

            Divider().padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(0..<6, id: \.self) { _ in hourSkeletonCell }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        // IRIS-HOOK: shimmer L→R gradient animation, suppressed under reduceMotion (§1.2).
        .redacted(reason: .placeholder)
    }

    // MARK: - Interaction

    private func selectDay(_ day: DayForecast) {
        let candidate = ForecastPickerLogic.sameHourOnDay(
            dayStart: day.date,
            referenceDate: selectedDate
        )
        let clamped: Date
        if let first = forecastHours.first?.timestamp,
           let last  = forecastHours.last?.timestamp {
            clamped = ForecastPickerLogic.clamp(candidate, firstHour: first, lastHour: last)
        } else {
            clamped = candidate
        }
        selectedDate = clamped
        onUserSelection(clamped)
    }

    private func selectHour(_ hour: HourForecast) {
        let dayStart: Date = forecastDays.first(where: { selectedDay(matches: $0) })?.date
            ?? ForecastPickerLogic.roundedDownToHour(selectedDate)
        let newDate = ForecastPickerLogic.sameHourOnDay(
            dayStart: dayStart,
            referenceDate: hour.timestamp
        )
        selectedDate = newDate
        onUserSelection(newDate)
    }

    private func toggleExtendedDays() {
        if reduceMotion {
            showExtendedDays.toggle()
            if showExtendedDays { day8Focused = true }
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                showExtendedDays.toggle()
            }
            if showExtendedDays {
                // Delay focus until the animation has started so VoiceOver finds
                // the newly-materialized day 8 row.
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(300))
                    day8Focused = true
                }
            }
        }
    }

    // MARK: - Selection helpers

    private func hoursForSelectedDay() -> [HourForecast] {
        guard let day = forecastDays.first(where: { selectedDay(matches: $0) }) else { return [] }
        return ForecastPickerLogic.hours(for: day, in: forecastHours)
    }

    private func selectedDay(matches day: DayForecast) -> Bool {
        isSameUTCDay(day.date, selectedDate)
    }

    private func isSelectedHour(_ timestamp: Date) -> Bool {
        var utcCal = Calendar(identifier: .gregorian)
        utcCal.timeZone = TimeZone(identifier: "UTC")!
        let a = utcCal.dateComponents([.year, .month, .day, .hour], from: timestamp)
        let b = utcCal.dateComponents([.year, .month, .day, .hour], from: selectedDate)
        return a.year == b.year && a.month == b.month && a.day == b.day && a.hour == b.hour
    }

    private func isCurrentHour(_ timestamp: Date) -> Bool {
        var utcCal = Calendar(identifier: .gregorian)
        utcCal.timeZone = TimeZone(identifier: "UTC")!
        let a = utcCal.dateComponents([.year, .month, .day, .hour], from: timestamp)
        let b = utcCal.dateComponents([.year, .month, .day, .hour], from: now)
        return a.year == b.year && a.month == b.month && a.day == b.day && a.hour == b.hour
    }

    private func isSameUTCDay(_ a: Date, _ b: Date) -> Bool {
        var utcCal = Calendar(identifier: .gregorian)
        utcCal.timeZone = TimeZone(identifier: "UTC")!
        let ca = utcCal.dateComponents([.year, .month, .day], from: a)
        let cb = utcCal.dateComponents([.year, .month, .day], from: b)
        return ca.year == cb.year && ca.month == cb.month && ca.day == cb.day
    }

    // MARK: - Accessibility labels

    private func dayRowA11yLabel(day: DayForecast, isToday: Bool) -> String {
        let dateStr: String
        if isToday {
            dateStr = "Today, " + day.date.formatted(.dateTime.month().day())
        } else {
            dateStr = day.date.formatted(.dateTime.weekday(.wide).month().day())
        }
        return "\(dateStr), UV index \(Int(day.dailyMaxUVI)), \(whoBandName(for: day.dailyMaxUVI))"
    }

    private func hourCellA11yLabel(for hour: HourForecast) -> String {
        let timeStr = hour.timestamp.formatted(
            .dateTime.hour(.defaultDigits(amPM: .abbreviated))
        )
        let currentSuffix = isCurrentHour(hour.timestamp) ? ", current hour" : ""
        if hour.uvIndex == 0 { return "\(timeStr), no UV\(currentSuffix)" }
        return "\(timeStr), UV index \(Int(hour.uvIndex)), \(whoBandName(for: hour.uvIndex))\(currentSuffix)"
    }
}
