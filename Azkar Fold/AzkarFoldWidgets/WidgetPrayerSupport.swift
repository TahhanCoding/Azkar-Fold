//
//  WidgetPrayerSupport.swift
//  AzkarFoldWidgets
//

import Foundation
import SwiftUI
import Adhan

enum WidgetAppGroup {
    static let identifier = "group.com.AhmedAlTahhan.Azkar-Fold"
    static let locationKey = "prayer_location"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: identifier) ?? .standard
    }
}

struct WidgetPrayerLocation: Codable {
    var latitude: Double
    var longitude: Double
    var displayName: String
    var timeZoneIdentifier: String?
    var source: String?

    var timeZone: TimeZone {
        if let timeZoneIdentifier, let zone = TimeZone(identifier: timeZoneIdentifier) {
            return zone
        }
        return .current
    }

    static let makkah = WidgetPrayerLocation(
        latitude: 21.4225,
        longitude: 39.8262,
        displayName: "Makkah",
        timeZoneIdentifier: "Asia/Riyadh",
        source: "defaultMakkah"
    )

    static func load() -> WidgetPrayerLocation {
        guard let data = WidgetAppGroup.defaults.data(forKey: WidgetAppGroup.locationKey),
              let location = try? JSONDecoder().decode(WidgetPrayerLocation.self, from: data) else {
            return .makkah
        }
        return location
    }
}

enum WidgetPrayerPeriod: String, CaseIterable {
    case fajr, shuruq, dhuhr, asr, maghrib, isha

    var englishName: String {
        switch self {
        case .fajr: return "Fajr"
        case .shuruq: return "Sunrise"
        case .dhuhr: return "Dhuhr"
        case .asr: return "Asr"
        case .maghrib: return "Maghrib"
        case .isha: return "Isha"
        }
    }

    var arabicName: String {
        switch self {
        case .fajr: return "الفجر"
        case .shuruq: return "الشروق"
        case .dhuhr: return "الظهر"
        case .asr: return "العصر"
        case .maghrib: return "المغرب"
        case .isha: return "العشاء"
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

    var color: Color {
        switch self {
        case .fajr: return Color(red: 0.35, green: 0.38, blue: 0.72)
        case .shuruq: return Color(red: 0.85, green: 0.68, blue: 0.28)
        case .dhuhr: return Color(red: 0.22, green: 0.62, blue: 0.58)
        case .asr: return Color(red: 0.88, green: 0.55, blue: 0.22)
        case .maghrib: return Color(red: 0.82, green: 0.38, blue: 0.42)
        case .isha: return Color(red: 0.22, green: 0.28, blue: 0.48)
        }
    }

    var isFard: Bool { self != .shuruq }

    func localizedName(locale: Locale = .current) -> String {
        let code = locale.languageCode ?? locale.identifier.prefix(2).description
        if code.hasPrefix("ar") {
            return arabicName
        }
        return englishName
    }
}

struct WidgetPrayerSchedule {
    let fajr: Int
    let sunrise: Int
    let dhuhr: Int
    let asr: Int
    let maghrib: Int
    let isha: Int
    let timeZone: TimeZone

    func startMinutes(for period: WidgetPrayerPeriod) -> Int {
        switch period {
        case .fajr: return fajr
        case .shuruq: return sunrise
        case .dhuhr: return dhuhr
        case .asr: return asr
        case .maghrib: return maghrib
        case .isha: return isha
        }
    }

    func endMinutes(for period: WidgetPrayerPeriod) -> Int {
        switch period {
        case .fajr: return sunrise
        case .shuruq: return dhuhr
        case .dhuhr: return asr
        case .asr: return maghrib
        case .maghrib: return isha
        case .isha: return fajr
        }
    }

    func wrapsMidnight(_ period: WidgetPrayerPeriod) -> Bool {
        endMinutes(for: period) <= startMinutes(for: period)
    }

    func contains(_ minutes: Int, period: WidgetPrayerPeriod) -> Bool {
        let start = startMinutes(for: period)
        let end = endMinutes(for: period)
        if wrapsMidnight(period) {
            return minutes >= start || minutes < end
        }
        return minutes >= start && minutes < end
    }

    func activePeriod(at minutes: Int) -> WidgetPrayerPeriod {
        for period in WidgetPrayerPeriod.allCases where contains(minutes, period: period) {
            return period
        }
        return .isha
    }

    func minutesUntilEnd(of period: WidgetPrayerPeriod, from minutes: Int) -> Int {
        let end = endMinutes(for: period)
        if wrapsMidnight(period) {
            if minutes >= startMinutes(for: period) {
                return (24 * 60 - minutes) + end
            }
            return end - minutes
        }
        return max(0, end - minutes)
    }

    func hhmm(_ minutes: Int) -> String {
        let clamped = ((minutes % (24 * 60)) + (24 * 60)) % (24 * 60)
        return String(format: "%02d:%02d", clamped / 60, clamped % 60)
    }

    func startAngle(for period: WidgetPrayerPeriod) -> Double {
        Double(startMinutes(for: period)) / Double(24 * 60) * 360
    }

    func endAngle(for period: WidgetPrayerPeriod) -> Double {
        var end = Double(endMinutes(for: period)) / Double(24 * 60) * 360
        let start = startAngle(for: period)
        if wrapsMidnight(period) && end <= start {
            end += 360
        }
        return end
    }

    static func calculate(for location: WidgetPrayerLocation, on date: Date = Date()) -> WidgetPrayerSchedule {
        let timeZone = location.timeZone
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let coordinates = Coordinates(latitude: location.latitude, longitude: location.longitude)
        var params = CalculationMethod.ummAlQura.params
        params.madhab = .shafi

        func minutes(_ date: Date) -> Int {
            let c = calendar.dateComponents([.hour, .minute], from: date)
            return (c.hour ?? 0) * 60 + (c.minute ?? 0)
        }

        if let prayers = PrayerTimes(coordinates: coordinates, date: components, calculationParameters: params) {
            return WidgetPrayerSchedule(
                fajr: minutes(prayers.fajr),
                sunrise: minutes(prayers.sunrise),
                dhuhr: minutes(prayers.dhuhr),
                asr: minutes(prayers.asr),
                maghrib: minutes(prayers.maghrib),
                isha: minutes(prayers.isha),
                timeZone: timeZone
            )
        }

        return WidgetPrayerSchedule(
            fajr: 4 * 60 + 18,
            sunrise: 5 * 60 + 45,
            dhuhr: 12 * 60 + 26,
            asr: 15 * 60 + 42,
            maghrib: 19 * 60 + 7,
            isha: 20 * 60 + 37,
            timeZone: timeZone
        )
    }

    static func minutesFromMidnight(date: Date, timeZone: TimeZone) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let c = calendar.dateComponents([.hour, .minute], from: date)
        return (c.hour ?? 0) * 60 + (c.minute ?? 0)
    }
}

enum WidgetCountdown {
    static func text(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return String(format: "%dh %02dm", hours, mins)
        }
        return String(format: "%dm", mins)
    }

    static func nextInText(minutes: Int, locale: Locale = .current) -> String {
        let time = text(minutes: minutes)
        return WidgetL10n.nextIn(time, locale: locale)
    }
}

enum WidgetL10n {
    static func nextIn(_ time: String, locale: Locale = .current) -> String {
        let code = locale.languageCode ?? locale.identifier.prefix(2).description
        if code.hasPrefix("ar") {
            return "التالي خلال \(time)"
        }
        return "Next in \(time)"
    }
}
