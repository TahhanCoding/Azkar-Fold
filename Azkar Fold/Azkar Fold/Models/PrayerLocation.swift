//
//  PrayerLocation.swift
//  Azkar Fold
//

import Foundation
import CoreLocation

enum PrayerLocationSource: String, Codable {
    case search
    case device
    case map
    case defaultMakkah
}

struct PrayerLocation: Codable, Equatable {
    var latitude: Double
    var longitude: Double
    var displayName: String
    var timeZoneIdentifier: String?
    var source: PrayerLocationSource

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var timeZone: TimeZone {
        if let timeZoneIdentifier,
           let zone = TimeZone(identifier: timeZoneIdentifier) {
            return zone
        }
        return .current
    }

    static let makkah = PrayerLocation(
        latitude: 21.4225,
        longitude: 39.8262,
        displayName: "Makkah",
        timeZoneIdentifier: "Asia/Riyadh",
        source: .defaultMakkah
    )

    func resolvedDisplayName(using appLanguage: AppLanguageManager) -> String {
        if source == .defaultMakkah {
            return appLanguage.text("prayer.location_makkah")
        }
        return displayName
    }
}
