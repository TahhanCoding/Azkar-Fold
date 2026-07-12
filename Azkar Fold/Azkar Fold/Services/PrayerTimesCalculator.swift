//
//  PrayerTimesCalculator.swift
//  Azkar Fold
//

import Foundation
import Adhan

struct DailyPrayerSchedule: Equatable {
    let fajrMinutes: Int
    let sunriseMinutes: Int
    let dhuhrMinutes: Int
    let asrMinutes: Int
    let maghribMinutes: Int
    let ishaMinutes: Int
    let timeZone: TimeZone
    let date: Date

    func startMinutes(for period: PrayerPeriod) -> Int {
        switch period {
        case .fajr: return fajrMinutes
        case .shuruq: return sunriseMinutes
        case .dhuhr: return dhuhrMinutes
        case .asr: return asrMinutes
        case .maghrib: return maghribMinutes
        case .isha: return ishaMinutes
        }
    }

    func endMinutes(for period: PrayerPeriod) -> Int {
        switch period {
        case .fajr: return sunriseMinutes
        case .shuruq: return dhuhrMinutes
        case .dhuhr: return asrMinutes
        case .asr: return maghribMinutes
        case .maghrib: return ishaMinutes
        case .isha: return fajrMinutes
        }
    }

    func startTimeString(for period: PrayerPeriod) -> String {
        Self.hhmm(fromMinutes: startMinutes(for: period))
    }

    func endTimeString(for period: PrayerPeriod) -> String {
        Self.hhmm(fromMinutes: endMinutes(for: period))
    }

    static func hhmm(fromMinutes minutes: Int) -> String {
        let clamped = ((minutes % (24 * 60)) + (24 * 60)) % (24 * 60)
        let hour = clamped / 60
        let minute = clamped % 60
        return String(format: "%02d:%02d", hour, minute)
    }
}

enum PrayerTimesCalculator {
    static func schedule(for location: PrayerLocation, on date: Date = Date()) -> DailyPrayerSchedule {
        let timeZone = location.timeZone
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let coordinates = Coordinates(latitude: location.latitude, longitude: location.longitude)
        var params = CalculationMethod.ummAlQura.params
        params.madhab = .shafi

        if let prayers = PrayerTimes(coordinates: coordinates, date: components, calculationParameters: params) {
            return DailyPrayerSchedule(
                fajrMinutes: minutesFromMidnight(prayers.fajr, timeZone: timeZone),
                sunriseMinutes: minutesFromMidnight(prayers.sunrise, timeZone: timeZone),
                dhuhrMinutes: minutesFromMidnight(prayers.dhuhr, timeZone: timeZone),
                asrMinutes: minutesFromMidnight(prayers.asr, timeZone: timeZone),
                maghribMinutes: minutesFromMidnight(prayers.maghrib, timeZone: timeZone),
                ishaMinutes: minutesFromMidnight(prayers.isha, timeZone: timeZone),
                timeZone: timeZone,
                date: date
            )
        }

        // Fallback: Makkah-like summer times if calculation fails
        return DailyPrayerSchedule(
            fajrMinutes: 4 * 60 + 18,
            sunriseMinutes: 5 * 60 + 45,
            dhuhrMinutes: 12 * 60 + 26,
            asrMinutes: 15 * 60 + 42,
            maghribMinutes: 19 * 60 + 7,
            ishaMinutes: 20 * 60 + 37,
            timeZone: timeZone,
            date: date
        )
    }

    private static func minutesFromMidnight(_ date: Date, timeZone: TimeZone) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let components = calendar.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }
}
