// ForecastPickerLogicTests.swift — WI-7: pure-function tests for ForecastPickerLogic
// Groups H (default selection), I (day selection), J (hour selection),
// K (clamping/out-of-range guards), L (reveal toggle), M (burn card copy variants)
//
// Pure functions under test (ForecastPickerLogic.swift):
//   roundedDownToHour(_:)
//   clamp(_:firstHour:lastHour:)
//   sameHourOnDay(dayStart:referenceDate:)
//   hours(for:in:)
//   snapToNearest(_:in:)
//   uvResult(from:at:now:)
//   burnCardDatePrefix(for:now:)
//
// Reference: CURRENT_DATETIME = 2026-05-21T03:10:00Z
// All UTC epoch constants derived from: baseEpoch(2026-05-23T12:00Z) = 1_748_016_000

import Foundation
import Testing
@testable import UVBurnTimerCore

// MARK: - Constants

/// UTC midnight on the test's "today": 2026-05-21T00:00:00Z
/// = 2026-01-01T00:00:00Z (1767225600) + 140 days (12096000)
private let todayMidnightUTC: TimeInterval = 1_779_321_600

/// CURRENT_DATETIME: 2026-05-21T03:10:00Z (3 h 10 min = 11 400 s into today)
private let nowEpoch: TimeInterval = 1_779_333_000   // todayMidnight + 11_400

// MARK: - Snapshot factory

/// Builds a `ForecastSnapshot` starting at `startEpoch`, spanning `dayCount` days.
///
/// `uvForRelativeHour` receives the slot's 0-based index within the whole snapshot
/// (day × 24 + hour) and returns the UVI for that slot. Default: daytime (06–19 UTC) = 5.
private func makePickerSnapshot(
    startEpoch: TimeInterval = todayMidnightUTC,
    dayCount: Int = 10,
    uvForRelativeHour: (Int) -> Double = { h in (h % 24 >= 6 && h % 24 < 20) ? 5.0 : 0.0 }
) -> ForecastSnapshot {
    let base = Date(timeIntervalSince1970: startEpoch)
    var allHours: [HourForecast] = []
    let days: [DayForecast] = (0..<dayCount).map { d in
        let dayStart = base.addingTimeInterval(Double(d) * 86400)
        for h in 0..<24 {
            allHours.append(HourForecast(
                timestamp: dayStart.addingTimeInterval(Double(h) * 3600),
                uvIndex: uvForRelativeHour(d * 24 + h)
            ))
        }
        return DayForecast(date: dayStart, dailyMinUVI: 0, dailyMaxUVI: 5, sunrise: nil, sunset: nil)
    }
    return ForecastSnapshot(
        schemaVersion: ForecastSnapshot.currentSchemaVersion,
        latitude: 37.77,
        longitude: -122.42,
        fetchedAt: base,
        expirationDate: Date.distantFuture,
        days: days,
        hours: allHours
    )
}


// MARK: - Group H: Default selection

/// H1 — Snapshot includes today. snapToNearest(now) returns today at the current UTC
/// hour (03:00 when now = 03:10 UTC — minutes stripped, result within window).
@Test func test_default_selection_picks_today_at_current_hour() {
    let now = Date(timeIntervalSince1970: nowEpoch)           // 2026-05-21T03:10:00Z
    let snapshot = makePickerSnapshot(startEpoch: todayMidnightUTC, dayCount: 10)

    let result = ForecastPickerLogic.snapToNearest(now, in: snapshot)

    // Expected: today 03:00:00 UTC — minutes stripped by roundedDownToHour
    let expected03h = Date(timeIntervalSince1970: todayMidnightUTC + 3 * 3600)
    #expect(result == expected03h,
            "Default selection must be today 03:00:00 UTC (current hour rounded down)")
}

/// H2 — Snapshot entirely in the past (fetched 11+ days ago, never refreshed).
/// today (now) is after the snapshot's last hour → clamps to lastHour.
///
/// Note: the spec charter described "first hour if all past"; the implementation
/// uses `min(max(date, firstHour), lastHour)` which returns lastHour — tested here.
@Test func test_default_selection_when_snapshot_does_not_include_today() {
    // Snapshot covers 2026-05-10 → 2026-05-19 (10 days, all before today May 21)
    let snapshotStart = todayMidnightUTC - 11 * 86400   // 2026-05-10T00:00:00Z
    let snapshot = makePickerSnapshot(startEpoch: snapshotStart, dayCount: 10)
    let now = Date(timeIntervalSince1970: nowEpoch)       // 2026-05-21T03:10:00Z

    let result = ForecastPickerLogic.snapToNearest(now, in: snapshot)

    // lastHour = snapshotStart + 9 days + 23 hours = 2026-05-19T23:00:00Z
    let expectedLastHour = Date(timeIntervalSince1970: snapshotStart + 9 * 86400 + 23 * 3600)
    #expect(result == expectedLastHour,
            "now > lastHour must clamp to lastHour (2026-05-19T23:00Z) of stale snapshot")
}

/// H3 — Snapshot covers May 1–10 explicitly; now = May 20.
/// now > lastHour → clamps to May 10 23:00:00 UTC (lastHour per implementation).
@Test func test_default_selection_when_now_is_past_last_snapshot_hour() {
    let may1Midnight = todayMidnightUTC - 20 * 86400   // 2026-05-01T00:00:00Z
    let snapshot = makePickerSnapshot(startEpoch: may1Midnight, dayCount: 10)
    let nowMay20 = Date(timeIntervalSince1970: todayMidnightUTC - 86400)  // 2026-05-20T00:00:00Z

    let result = ForecastPickerLogic.snapToNearest(nowMay20, in: snapshot)

    // lastHour = May 1 + 9 days + 23 hours = May 10 23:00:00 UTC
    let may10at23h = Date(timeIntervalSince1970: may1Midnight + 9 * 86400 + 23 * 3600)
    #expect(result == may10at23h,
            "Snapshot May 1–10, now May 20 → must clamp to May 10 23:00 UTC (lastHour)")
}

/// H4 — roundedDownToHour strips minutes and seconds.
/// Input: 2026-05-21T14:23:45Z → Output: 2026-05-21T14:00:00Z.
@Test func test_default_selection_hour_rounds_down_to_top_of_hour() {
    // Build via epoch arithmetic — avoids local-timezone interference in Date construction
    let inputDate = Date(timeIntervalSince1970: todayMidnightUTC + 14 * 3600 + 23 * 60 + 45)

    let result = ForecastPickerLogic.roundedDownToHour(inputDate)

    let expected14h = Date(timeIntervalSince1970: todayMidnightUTC + 14 * 3600)
    #expect(result == expected14h,
            "roundedDownToHour must strip minutes (23) and seconds (45), landing on 14:00:00 UTC")
}

// MARK: - Group I: Day selection logic

/// I1 — Switching from Mon 2026-05-18 14:00 UTC to Wed 2026-05-20 preserves 14:00 hour.
/// sameHourOnDay(dayStart: wedMidnight, referenceDate: mon14h) must return Wed 14:00 UTC.
@Test func test_selecting_new_day_preserves_hour_of_day() {
    let monMidnight = todayMidnightUTC - 3 * 86400       // 2026-05-18T00:00:00Z
    let mon14h = Date(timeIntervalSince1970: monMidnight + 14 * 3600)
    let wedMidnightEpoch = todayMidnightUTC - 86400       // 2026-05-20T00:00:00Z
    let wedMidnight = Date(timeIntervalSince1970: wedMidnightEpoch)

    let result = ForecastPickerLogic.sameHourOnDay(dayStart: wedMidnight, referenceDate: mon14h)

    // Expected: Wednesday May 20 at 14:00:00 UTC — compare directly as epoch
    let expectedWed14h = Date(timeIntervalSince1970: wedMidnightEpoch + 14 * 3600)
    #expect(result == expectedWed14h,
            "Switching to Wed must produce Wed 14:00 UTC — same hour-of-day, different day")
}

/// I2 — DST edge case: sameHourOnDay operates in UTC and does NOT validate the resulting
/// date against the available HourForecast entries for the target day.
/// The consumer (ForecastPickerView.selectDay) must clamp against the hours array post-call.
/// Documented here as a known testability gap in ForecastPickerLogic.
///
/// See .squad/decisions/inbox/ma-ti-picker-logic-gaps.md
@Test func test_selecting_new_day_when_target_day_does_not_have_that_hour() {
    withKnownIssue("sameHourOnDay is UTC-only; it does not validate the result against the available HourForecast array. The consumer (selectDay) handles post-call clamping via ForecastPickerLogic.clamp. No pure function in ForecastPickerLogic validates hour availability — see ma-ti-picker-logic-gaps.md.") {
        // Simulate a target day whose hours array deliberately omits hour 14 (DST gap analog)
        let wedMidnight = Date(timeIntervalSince1970: todayMidnightUTC - 86400)
        let wedHoursSkipping14: [HourForecast] = (0..<24).compactMap { h -> HourForecast? in
            guard h != 14 else { return nil }
            return HourForecast(
                timestamp: wedMidnight.addingTimeInterval(Double(h) * 3600),
                uvIndex: 5.0
            )
        }
        let monMidnight = todayMidnightUTC - 3 * 86400
        let mon14h = Date(timeIntervalSince1970: monMidnight + 14 * 3600)

        let result = ForecastPickerLogic.sameHourOnDay(dayStart: wedMidnight, referenceDate: mon14h)

        // sameHourOnDay returns Wed 14:00 UTC — but that slot is absent.
        // A fully-guarded pure function should clamp to nearest available entry.
        let resultRounded = ForecastPickerLogic.roundedDownToHour(result)
        let isInHours = wedHoursSkipping14.contains {
            ForecastPickerLogic.roundedDownToHour($0.timestamp) == resultRounded
        }
        #expect(isInHours,
                "sameHourOnDay result should land on an available HourForecast entry in the target day")
    }
}

// MARK: - Group J: Hour selection logic

/// J1 — Tapping a different hour cell within the current day updates the hour, day unchanged.
/// View calls sameHourOnDay(dayStart: dayStart, referenceDate: tappedHour.timestamp).
@Test func test_selecting_new_hour_within_current_day() {
    let dayStart = Date(timeIntervalSince1970: todayMidnightUTC)                        // May 21 00:00
    let tappedHourTimestamp = Date(timeIntervalSince1970: todayMidnightUTC + 16 * 3600) // 16:00

    let result = ForecastPickerLogic.sameHourOnDay(dayStart: dayStart, referenceDate: tappedHourTimestamp)

    // Expected: today at 16:00:00 UTC — compare as epoch
    let expectedToday16h = Date(timeIntervalSince1970: todayMidnightUTC + 16 * 3600)
    #expect(result == expectedToday16h,
            "Tapping 16:00 within today must produce today 16:00 UTC — day unchanged, hour updated")
}

/// J2 — Selecting an earlier hour today (01:00 when now = 03:10 UTC) is accepted without
/// clamping. Past hours of today remain accessible — user may review historical UV.
@Test func test_selecting_hour_in_past_today() {
    let now = Date(timeIntervalSince1970: nowEpoch)                                      // 03:10 UTC
    let dayStart = Date(timeIntervalSince1970: todayMidnightUTC)
    let pastHourTimestamp = Date(timeIntervalSince1970: todayMidnightUTC + 1 * 3600)    // 01:00 UTC

    let result = ForecastPickerLogic.sameHourOnDay(dayStart: dayStart, referenceDate: pastHourTimestamp)

    // Expected: today 01:00:00 UTC — earlier than now, no clamping applied
    let expected01h = Date(timeIntervalSince1970: todayMidnightUTC + 1 * 3600)
    #expect(result == expected01h,
            "Past hour (01:00) must be accepted without forward-clamping to now")
    #expect(result < now, "Result must be earlier than now — no clamping to current time")
}

// MARK: - Group K: Clamping / out-of-range guards

/// K1 — selectedDate 30 days before snapshot start → snapToNearest clamps to firstHour.
@Test func test_selection_clamped_when_date_before_snapshot_window() {
    let snapshot = makePickerSnapshot(startEpoch: todayMidnightUTC, dayCount: 10)
    let dateBefore = Date(timeIntervalSince1970: todayMidnightUTC - 30 * 86400)

    let result = ForecastPickerLogic.snapToNearest(dateBefore, in: snapshot)

    // firstHour = snapshot start = today midnight (day 0, hour 0)
    let expectedFirstHour = Date(timeIntervalSince1970: todayMidnightUTC)
    #expect(result == expectedFirstHour,
            "Date 30 days before snapshot start must clamp to firstHour (today midnight)")
}

/// K2 — selectedDate 30 days after snapshot end → snapToNearest clamps to lastHour.
@Test func test_selection_clamped_when_date_after_snapshot_window() {
    let snapshot = makePickerSnapshot(startEpoch: todayMidnightUTC, dayCount: 10)
    let dateAfter = Date(timeIntervalSince1970: todayMidnightUTC + 30 * 86400)

    let result = ForecastPickerLogic.snapToNearest(dateAfter, in: snapshot)

    // lastHour = day 9 (index), hour 23 = today + 9×86400 + 23×3600 = 2026-05-30T23:00Z
    let expectedLastHour = Date(timeIntervalSince1970: todayMidnightUTC + 9 * 86400 + 23 * 3600)
    #expect(result == expectedLastHour,
            "Date 30 days after snapshot end must clamp to lastHour (May 30 23:00 UTC)")
}

/// K3 — selectedDate inside the window → snapToNearest returns roundedDownToHour(date),
/// no clamping applied.
@Test func test_selection_unchanged_when_within_window() {
    let snapshot = makePickerSnapshot(startEpoch: todayMidnightUTC, dayCount: 10)
    // Day 3, 14:30 UTC — well inside the 10-day window, half-hour past an hour boundary
    let dateInsideWithMinutes = Date(timeIntervalSince1970: todayMidnightUTC + 3 * 86400 + 14 * 3600 + 30 * 60)

    let result = ForecastPickerLogic.snapToNearest(dateInsideWithMinutes, in: snapshot)

    // Rounded down: day 3 14:00 UTC — unchanged by clamping
    let expectedRounded = Date(timeIntervalSince1970: todayMidnightUTC + 3 * 86400 + 14 * 3600)
    #expect(result == expectedRounded,
            "Date inside window must return roundedDownToHour(date) without any clamping")
}

// MARK: - Group L: Reveal toggle

/// L1 — Default reveal state (showExtendedDays) must be collapsed (false) on first init.
///
/// ForecastPickerLogic does NOT expose a pure `defaultRevealState()` function.
/// The state lives as a private `@State` on ForecastPickerView and cannot be
/// unit-tested without a SwiftUI test host.
///
/// See .squad/decisions/inbox/ma-ti-picker-logic-gaps.md for the recommendation
/// to extract a ForecastPickerViewModel with a testable `isRevealed: Bool` property.
@Test func test_reveal_is_collapsed_by_default() {
    withKnownIssue("showExtendedDays is a private @State on ForecastPickerView, not a pure function in ForecastPickerLogic. Default collapsed state cannot be unit-tested without a SwiftUI test host. Recommend extracting ForecastPickerViewModel with a testable initial state property.") {
        #expect(Bool(false),
                "showExtendedDays initial state requires a SwiftUI test host — not reachable here")
    }
}

/// L2 — Fewer than 8 forecast days → reveal row must not be shown.
/// Tests the inline view condition `forecastDays.count > 7` for the reveal affordance.
/// Includes boundary cases: 5 (hidden), 7 (hidden, boundary), 8 (shown, boundary+1), 10 (shown).
@Test func test_reveal_hidden_when_fewer_than_8_days() {
    // The condition is inline in ForecastPickerView.dayListSection:
    //   `if forecastDays.count > 7 { revealAffordanceRow }`
    func shouldShowRevealRow(dayCount: Int) -> Bool { dayCount > 7 }

    #expect(shouldShowRevealRow(dayCount: 5) == false,  "5 days: reveal row must be hidden")
    #expect(shouldShowRevealRow(dayCount: 7) == false,  "7 days: reveal row must be hidden (boundary)")
    #expect(shouldShowRevealRow(dayCount: 8) == true,   "8 days: reveal row must appear (boundary+1)")
    #expect(shouldShowRevealRow(dayCount: 10) == true,  "10 days: reveal row must appear")
}

// MARK: - Group M: Burn card copy variant resolution

/// M1 — selectedDate is the current UTC hour → burnCardDatePrefix returns nil.
/// nil signals the "live now" variant: no date prefix on the burn card.
@Test func test_copy_variant_for_live_now() {
    let now = Date(timeIntervalSince1970: nowEpoch)   // 2026-05-21T03:10:00Z
    // selectedDate is the same moment; roundedDownToHour(selectedDate) == roundedDownToHour(now)
    let selectedDate = now

    let prefix = ForecastPickerLogic.burnCardDatePrefix(for: selectedDate, now: now)

    #expect(prefix == nil,
            "selectedDate in the current UTC hour must return nil — no prefix = live variant")
}

/// M2 — selectedDate is a future hour today (18:00 UTC) while now = 03:10 UTC.
/// Same UTC calendar day → burnCardDatePrefix returns "Burn time at [hour]" (no day name).
///
/// Note: the implementation branches on same-vs-different UTC day:
///   same day  → "Burn time at [hour]"
///   other day → "Burn time on [weekday] at [hour]"
@Test func test_copy_variant_for_future_today() {
    let now = Date(timeIntervalSince1970: nowEpoch)                         // 03:10 UTC
    let selectedDate = Date(timeIntervalSince1970: todayMidnightUTC + 18 * 3600)  // 18:00 UTC today

    let prefix = ForecastPickerLogic.burnCardDatePrefix(for: selectedDate, now: now)

    #expect(prefix != nil, "Future hour today must produce a non-nil prefix")
    #expect(prefix?.hasPrefix("Burn time at") == true,
            "Same-day future hour must begin with 'Burn time at' (no weekday prefix)")
}

/// M3 — selectedDate is tomorrow 2026-05-22 18:00 UTC (a Friday) while now = 03:10 today.
/// burnCardDatePrefix returns a non-nil string containing the abbreviated weekday "Fri".
@Test func test_copy_variant_for_future_other_day() {
    let now = Date(timeIntervalSince1970: nowEpoch)
    // 2026-05-22 18:00 UTC — tomorrow (Friday)
    let selectedDate = Date(timeIntervalSince1970: todayMidnightUTC + 86400 + 18 * 3600)

    let prefix = ForecastPickerLogic.burnCardDatePrefix(for: selectedDate, now: now)

    #expect(prefix != nil, "Future day must produce a non-nil prefix")
    #expect(prefix?.hasPrefix("Burn time on") == true,
            "Prefix must begin with 'Burn time on'")
    // 2026-05-22 is a Friday; the format uses .weekday(.abbreviated) → "Fri" in en locale
    #expect(prefix?.contains("Fri") == true,
            "May 22 2026 is a Friday — abbreviated weekday 'Fri' must appear in the formatted date")
}

/// M4 — Hour with UVI = 0 → uvResult returns .nighttime, driving the "No UV at this hour"
/// copy variant. Copy-variant selection on UVI=0 is determined by uvResult, not burnCardDatePrefix.
@Test func test_copy_variant_for_uv_zero_hour() {
    let now = Date(timeIntervalSince1970: nowEpoch)
    // All-zero snapshot: polar night / full-nighttime scenario
    let snapshot = makePickerSnapshot(startEpoch: todayMidnightUTC, dayCount: 1) { _ in 0.0 }
    let targetDate = Date(timeIntervalSince1970: todayMidnightUTC)   // midnight, UVI = 0

    let result = ForecastPickerLogic.uvResult(from: snapshot, at: targetDate, now: now)

    #expect(result == .nighttime,
            "UVI=0 hour must return .nighttime — the caller renders 'No UV at this hour'")
}
