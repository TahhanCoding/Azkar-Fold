//
//  PrayerPeriod.swift
//  Azkar Fold
//
//  TEMPORARY: Hardcoded Makkah prayer times snapshot (AlAdhan Umm Al-Qura, 10 Jul 2026).
//

import Foundation
import SwiftUI

/// Temporary Makkah schedule — replace with live calculation later.
enum MakkahPrayerTimesSnapshot {
    static let locationNameKey: String.LocalizationValue = "prayer.location_makkah"
    static let dateLabel = "10 Jul 2026"
    static let hijriLabel = "25 Muharram 1448"
    static let timeZoneIdentifier = "Asia/Riyadh"

    // TEMPORARY hardcoded wall-clock times (HH:mm, Asia/Riyadh)
    static let fajr = "04:18"
    static let sunrise = "05:45"
    static let dhuhr = "12:26"
    static let asr = "15:42"
    static let maghrib = "19:07"
    static let isha = "20:37"

    static var timeZone: TimeZone {
        TimeZone(identifier: timeZoneIdentifier) ?? .current
    }

    static func minutes(fromHHMM string: String) -> Int {
        let parts = string.split(separator: ":")
        guard parts.count == 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]) else {
            return 0
        }
        return hour * 60 + minute
    }
}

enum PrayerPeriod: String, CaseIterable, Identifiable {
    case fajr
    case shuruq
    case dhuhr
    case asr
    case maghrib
    case isha

    var id: String { rawValue }

    var isFard: Bool {
        self != .shuruq
    }

    var nameKey: String.LocalizationValue {
        switch self {
        case .fajr: return "prayer.period.fajr"
        case .shuruq: return "prayer.period.shuruq"
        case .dhuhr: return "prayer.period.dhuhr"
        case .asr: return "prayer.period.asr"
        case .maghrib: return "prayer.period.maghrib"
        case .isha: return "prayer.period.isha"
        }
    }

    var systemImage: String {
        switch self {
        case .fajr: return "moon.haze.fill"
        case .shuruq: return "sunrise.fill"
        case .dhuhr: return "sun.max.fill"
        case .asr: return "sun.haze.fill"
        case .maghrib: return "sunset.fill"
        case .isha: return "moon.stars.fill"
        }
    }

    /// Start time as HH:mm from the Makkah snapshot.
    var startTimeString: String {
        switch self {
        case .fajr: return MakkahPrayerTimesSnapshot.fajr
        case .shuruq: return MakkahPrayerTimesSnapshot.sunrise
        case .dhuhr: return MakkahPrayerTimesSnapshot.dhuhr
        case .asr: return MakkahPrayerTimesSnapshot.asr
        case .maghrib: return MakkahPrayerTimesSnapshot.maghrib
        case .isha: return MakkahPrayerTimesSnapshot.isha
        }
    }

    /// End time as HH:mm (next period start). Isha ends at next Fajr.
    var endTimeString: String {
        switch self {
        case .fajr: return MakkahPrayerTimesSnapshot.sunrise
        case .shuruq: return MakkahPrayerTimesSnapshot.dhuhr
        case .dhuhr: return MakkahPrayerTimesSnapshot.asr
        case .asr: return MakkahPrayerTimesSnapshot.maghrib
        case .maghrib: return MakkahPrayerTimesSnapshot.isha
        case .isha: return MakkahPrayerTimesSnapshot.fajr
        }
    }

    var startMinutes: Int {
        MakkahPrayerTimesSnapshot.minutes(fromHHMM: startTimeString)
    }

    var endMinutes: Int {
        MakkahPrayerTimesSnapshot.minutes(fromHHMM: endTimeString)
    }

    /// Whether this period wraps past midnight (Isha → Fajr).
    var wrapsMidnight: Bool {
        endMinutes <= startMinutes
    }

    /// Semantic day-part color (blended with theme primary in the view).
    var semanticColor: Color {
        switch self {
        case .fajr: return Color(red: 0.35, green: 0.38, blue: 0.72)      // dawn indigo
        case .shuruq: return Color(red: 0.85, green: 0.68, blue: 0.28)    // morning gold
        case .dhuhr: return Color(red: 0.22, green: 0.62, blue: 0.58)     // noon teal
        case .asr: return Color(red: 0.88, green: 0.55, blue: 0.22)       // afternoon amber
        case .maghrib: return Color(red: 0.82, green: 0.38, blue: 0.42)   // sunset rose
        case .isha: return Color(red: 0.22, green: 0.28, blue: 0.48)      // night deep blue
        }
    }

    func contains(minutesFromMidnight minutes: Int) -> Bool {
        if wrapsMidnight {
            return minutes >= startMinutes || minutes < endMinutes
        }
        return minutes >= startMinutes && minutes < endMinutes
    }

    /// Start angle in degrees for a 24h dial (0° = midnight at top, clockwise).
    var startAngleDegrees: Double {
        Self.angleDegrees(forMinutes: startMinutes)
    }

    var endAngleDegrees: Double {
        var end = Self.angleDegrees(forMinutes: endMinutes)
        if wrapsMidnight && end <= startAngleDegrees {
            end += 360
        }
        return end
    }

    static func angleDegrees(forMinutes minutes: Int) -> Double {
        let clamped = ((minutes % (24 * 60)) + (24 * 60)) % (24 * 60)
        return Double(clamped) / Double(24 * 60) * 360.0
    }

    static func period(containing minutesFromMidnight: Int) -> PrayerPeriod {
        for period in PrayerPeriod.allCases where period.contains(minutesFromMidnight: minutesFromMidnight) {
            return period
        }
        return .isha
    }

    static func minutesFromMidnight(in timeZone: TimeZone, date: Date = Date()) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        return hour * 60 + minute
    }

    /// Minutes remaining until this period's end (handles midnight wrap).
    func minutesUntilEnd(from minutesFromMidnight: Int) -> Int {
        if wrapsMidnight {
            if minutesFromMidnight >= startMinutes {
                return (24 * 60 - minutesFromMidnight) + endMinutes
            }
            return endMinutes - minutesFromMidnight
        }
        return max(0, endMinutes - minutesFromMidnight)
    }

    func nextPeriod() -> PrayerPeriod {
        let all = PrayerPeriod.allCases
        guard let index = all.firstIndex(of: self) else { return .fajr }
        return all[(index + 1) % all.count]
    }
}

struct PrayerClockState {
    let now: Date
    let timeZone: TimeZone
    let minutesFromMidnight: Int
    let activePeriod: PrayerPeriod
    let minutesUntilNext: Int

    init(date: Date = Date(), timeZone: TimeZone = MakkahPrayerTimesSnapshot.timeZone) {
        self.now = date
        self.timeZone = timeZone
        let minutes = PrayerPeriod.minutesFromMidnight(in: timeZone, date: date)
        self.minutesFromMidnight = minutes
        let active = PrayerPeriod.period(containing: minutes)
        self.activePeriod = active
        self.minutesUntilNext = active.minutesUntilEnd(from: minutes)
    }

    var nowAngleDegrees: Double {
        PrayerPeriod.angleDegrees(forMinutes: minutesFromMidnight)
    }

    var countdownText: String {
        let hours = minutesUntilNext / 60
        let mins = minutesUntilNext % 60
        if hours > 0 {
            return String(format: "%dh %02dm", hours, mins)
        }
        return String(format: "%dm", mins)
    }
}
