// ForecastPickerLogic.swift — WI-7: pure, testable picker selection logic
// All methods are static and depend only on Foundation types and
// UVBurnTimerCore model types.

import Foundation

/// Pure, side-effect-free logic for ``ForecastPickerView`` selection management.
///
/// All methods are static and depend only on Foundation types, making
/// them straightforwardly unit-testable without SwiftUI or UIKit.
/// Ma-Ti can test these via `UVBurnTimerCoreTests`.
public enum ForecastPickerLogic {

    // MARK: - Hour rounding

    /// Returns `date` truncated to the start of its UTC hour.
    public static func roundedDownToHour(_ date: Date) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        let comps = cal.dateComponents([.year, .month, .day, .hour], from: date)
        return cal.date(from: comps) ?? date
    }

    // MARK: - Clamp

    /// Clamps `date` to `[firstHour, lastHour]`.
    public static func clamp(_ date: Date, firstHour: Date, lastHour: Date) -> Date {
        min(max(date, firstHour), lastHour)
    }

    // MARK: - Same hour on different day

    /// Returns a Date that falls on `dayStart`'s UTC calendar day but shares
    /// the same UTC hour-of-day as `referenceDate`.
    ///
    /// Used when the user switches to a different day while preserving the
    /// currently selected hour — e.g., "Wed 14:00 → Fri 14:00".
    public static func sameHourOnDay(dayStart: Date, referenceDate: Date) -> Date {
        var utcCal = Calendar(identifier: .gregorian)
        utcCal.timeZone = TimeZone(identifier: "UTC")!
        let hour = utcCal.component(.hour, from: referenceDate)
        var comps = utcCal.dateComponents([.year, .month, .day], from: dayStart)
        comps.hour = hour
        comps.minute = 0
        comps.second = 0
        return utcCal.date(from: comps) ?? dayStart
    }

    // MARK: - Hours for a day

    /// Returns the subset of `hours` whose UTC timestamps fall within the
    /// UTC calendar day defined by `day.date`.
    public static func hours(for day: DayForecast, in hours: [HourForecast]) -> [HourForecast] {
        var utcCal = Calendar(identifier: .gregorian)
        utcCal.timeZone = TimeZone(identifier: "UTC")!
        guard let dayEnd = utcCal.date(byAdding: .day, value: 1, to: day.date) else { return [] }
        return hours.filter { $0.timestamp >= day.date && $0.timestamp < dayEnd }
    }

    // MARK: - Snap to nearest available hour

    /// Snaps `date` (rounded to UTC hour) to the nearest available
    /// ``HourForecast`` entry in `snapshot.hours`.
    ///
    /// Falls back to `roundedDownToHour(date)` when `snapshot` is nil or
    /// its hours array is empty.
    public static func snapToNearest(_ date: Date, in snapshot: ForecastSnapshot?) -> Date {
        guard let snap = snapshot, !snap.hours.isEmpty else {
            return roundedDownToHour(date)
        }
        let rounded = roundedDownToHour(date)
        // If the rounded date is within the snapshot window, return it clamped.
        let firstHour = roundedDownToHour(snap.hours.first!.timestamp)
        let lastHour  = roundedDownToHour(snap.hours.last!.timestamp)
        return clamp(rounded, firstHour: firstHour, lastHour: lastHour)
    }

    // MARK: - UV result from snapshot (synchronous, no actor hop)

    /// Returns the ``UVResult`` for `date` directly from `snapshot` without
    /// requiring an actor hop.
    ///
    /// Mirrors `ForecastStore.uvIndex(at:)` semantics. Using the already-loaded
    /// `ForecastSnapshot` value from `RootView.forecastSnapshot` keeps the
    /// hot path synchronous and avoids @MainActor ↔ actor round-trips.
    public static func uvResult(
        from snapshot: ForecastSnapshot?,
        at date: Date,
        now: Date = Date()
    ) -> UVResult {
        guard let snap = snapshot else {
            return .unavailable(reason: .noSnapshot)
        }
        guard !snap.isStale(now: now) else {
            return .unavailable(reason: .snapshotExpired)
        }

        let target = roundedDownToHour(date)

        guard let entry = snap.hours.first(where: {
            roundedDownToHour($0.timestamp) == target
        }) else {
            // Distinguish window edge (truly out-of-range) vs. missing slot inside window.
            if let first = snap.hours.first.map({ roundedDownToHour($0.timestamp) }),
               let last  = snap.hours.last.map({ roundedDownToHour($0.timestamp) }),
               target >= first && target <= last {
                return .nighttime  // absent slot inside window → polar/DST coercion
            }
            return .unavailable(reason: .snapshotExpired)
        }

        return entry.uvIndex == 0 ? .nighttime : .value(entry.uvIndex)
    }

    // MARK: - Default selection

    /// Returns the default selected ``Date`` when the picker opens or returns to foreground.
    ///
    /// - Day: the first ``DayForecast`` whose date matches today in the device calendar.
    /// - Hour: the first ``HourForecast`` whose timestamp is ≥ `now` (current or next upcoming hour).
    ///
    /// Falls back to `roundedDownToHour(now)` when snapshot is nil or has no hours.
    public static func defaultSelectedDate(in snapshot: ForecastSnapshot?, now: Date = Date()) -> Date {
        guard let snap = snapshot, !snap.hours.isEmpty else {
            return roundedDownToHour(now)
        }
        let roundedNow = roundedDownToHour(now)
        // First hour slot at or after now (current hour or next upcoming).
        if let upcoming = snap.hours.first(where: { roundedDownToHour($0.timestamp) >= roundedNow }) {
            return upcoming.timestamp
        }
        // All hours are in the past (end-of-snapshot edge case) — return last available.
        return snap.hours.last!.timestamp
    }

    // MARK: - Burn card date prefix

    /// Returns an optional date context string for the burn card header (Iris §5).
    ///
    /// - Returns `nil` when `selectedDate` is the current UTC hour — card shows bare estimate ("23 min").
    /// - Returns `"Burn time at 6 PM"` when a future hour on today is selected.
    /// - Returns `"Burn time on Wed at 6 PM"` when a future day is selected.
    ///
    /// "on Wed" uses abbreviated day name (`E` token) per Iris §5 note.
    public static func burnCardDatePrefix(for selectedDate: Date, now: Date) -> String? {
        let currentHour = roundedDownToHour(now)
        let selectedHour = roundedDownToHour(selectedDate)
        guard selectedHour != currentHour else { return nil }

        let timeStr = selectedDate.formatted(
            .dateTime.hour(.defaultDigits(amPM: .abbreviated))
        )
        // Same UTC calendar day → "Burn time at 6 PM".
        // Different day → "Burn time on Wed at 6 PM".
        var utcCal = Calendar(identifier: .gregorian)
        utcCal.timeZone = TimeZone(identifier: "UTC")!
        if utcCal.isDate(selectedDate, inSameDayAs: now) {
            return "Burn time at \(timeStr)"
        } else {
            let dayStr = selectedDate.formatted(.dateTime.weekday(.abbreviated))
            return "Burn time on \(dayStr) at \(timeStr)"
        }
    }
}
