//
//  PrayerPeriod.swift
//  Azkar Fold
//

import Foundation
import SwiftUI

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

    var semanticColor: Color {
        switch self {
        case .fajr: return Color(red: 0.35, green: 0.38, blue: 0.72)
        case .shuruq: return Color(red: 0.85, green: 0.68, blue: 0.28)
        case .dhuhr: return Color(red: 0.22, green: 0.62, blue: 0.58)
        case .asr: return Color(red: 0.88, green: 0.55, blue: 0.22)
        case .maghrib: return Color(red: 0.82, green: 0.38, blue: 0.42)
        case .isha: return Color(red: 0.22, green: 0.28, blue: 0.48)
        }
    }

    func wrapsMidnight(in schedule: DailyPrayerSchedule) -> Bool {
        schedule.endMinutes(for: self) <= schedule.startMinutes(for: self)
    }

    func contains(minutesFromMidnight minutes: Int, in schedule: DailyPrayerSchedule) -> Bool {
        let start = schedule.startMinutes(for: self)
        let end = schedule.endMinutes(for: self)
        if wrapsMidnight(in: schedule) {
            return minutes >= start || minutes < end
        }
        return minutes >= start && minutes < end
    }

    func startAngleDegrees(in schedule: DailyPrayerSchedule) -> Double {
        Self.angleDegrees(forMinutes: schedule.startMinutes(for: self))
    }

    func endAngleDegrees(in schedule: DailyPrayerSchedule) -> Double {
        var end = Self.angleDegrees(forMinutes: schedule.endMinutes(for: self))
        let start = startAngleDegrees(in: schedule)
        if wrapsMidnight(in: schedule) && end <= start {
            end += 360
        }
        return end
    }

    static func angleDegrees(forMinutes minutes: Int) -> Double {
        let clamped = ((minutes % (24 * 60)) + (24 * 60)) % (24 * 60)
        return Double(clamped) / Double(24 * 60) * 360.0
    }

    static func period(containing minutesFromMidnight: Int, in schedule: DailyPrayerSchedule) -> PrayerPeriod {
        for period in PrayerPeriod.allCases where period.contains(minutesFromMidnight: minutesFromMidnight, in: schedule) {
            return period
        }
        return .isha
    }

    static func minutesFromMidnight(in timeZone: TimeZone, date: Date = Date()) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }

    func minutesUntilEnd(from minutesFromMidnight: Int, in schedule: DailyPrayerSchedule) -> Int {
        let end = schedule.endMinutes(for: self)
        if wrapsMidnight(in: schedule) {
            if minutesFromMidnight >= schedule.startMinutes(for: self) {
                return (24 * 60 - minutesFromMidnight) + end
            }
            return end - minutesFromMidnight
        }
        return max(0, end - minutesFromMidnight)
    }
}

struct PrayerClockState {
    let now: Date
    let schedule: DailyPrayerSchedule
    let location: PrayerLocation
    let minutesFromMidnight: Int
    let activePeriod: PrayerPeriod
    let minutesUntilNext: Int

    init(
        date: Date = Date(),
        location: PrayerLocation = PrayerSettingsStore.shared.location
    ) {
        self.now = date
        self.location = location
        let schedule = PrayerTimesCalculator.schedule(for: location, on: date)
        self.schedule = schedule
        let minutes = PrayerPeriod.minutesFromMidnight(in: schedule.timeZone, date: date)
        self.minutesFromMidnight = minutes
        let active = PrayerPeriod.period(containing: minutes, in: schedule)
        self.activePeriod = active
        self.minutesUntilNext = active.minutesUntilEnd(from: minutes, in: schedule)
    }

    var timeZone: TimeZone { schedule.timeZone }

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

    func subtitle(using appLanguage: AppLanguageManager) -> String {
        let place = location.resolvedDisplayName(using: appLanguage)
        let dateText = now.formatted(
            Date.FormatStyle(date: .abbreviated, time: .omitted)
                .locale(appLanguage.locale)
        )
        return "\(place) · \(dateText)"
    }
}
