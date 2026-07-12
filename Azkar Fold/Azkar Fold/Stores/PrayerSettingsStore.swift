//
//  PrayerSettingsStore.swift
//  Azkar Fold
//

import Foundation
import Combine

class PrayerSettingsStore: ObservableObject {
    static let shared = PrayerSettingsStore()

    private enum Keys {
        static let location = "prayer_location"
    }

    @Published private(set) var location: PrayerLocation

    private init() {
        if let data = UserDefaults.standard.data(forKey: Keys.location),
           let saved = try? JSONDecoder().decode(PrayerLocation.self, from: data) {
            location = saved
        } else {
            location = .makkah
        }
    }

    func setLocation(_ location: PrayerLocation) {
        self.location = location
        if let data = try? JSONEncoder().encode(location) {
            UserDefaults.standard.set(data, forKey: Keys.location)
        }
    }
}
