//
//  PrayerSettingsStore.swift
//  Azkar Fold
//

import Foundation
import Combine
import WidgetKit

class PrayerSettingsStore: ObservableObject {
    static let shared = PrayerSettingsStore()

    private enum LegacyKeys {
        static let location = "prayer_location"
    }

    @Published private(set) var location: PrayerLocation

    private init() {
        if let data = AppGroup.defaults.data(forKey: AppGroup.Keys.prayerLocation),
           let saved = try? JSONDecoder().decode(PrayerLocation.self, from: data) {
            location = saved
        } else if let data = UserDefaults.standard.data(forKey: LegacyKeys.location),
                  let saved = try? JSONDecoder().decode(PrayerLocation.self, from: data) {
            location = saved
            persist(saved)
        } else {
            location = .makkah
            persist(.makkah)
        }
    }

    func setLocation(_ location: PrayerLocation) {
        self.location = location
        persist(location)
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func persist(_ location: PrayerLocation) {
        guard let data = try? JSONEncoder().encode(location) else { return }
        AppGroup.defaults.set(data, forKey: AppGroup.Keys.prayerLocation)
        UserDefaults.standard.set(data, forKey: LegacyKeys.location)
    }
}
