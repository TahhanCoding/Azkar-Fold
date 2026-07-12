//
//  AppGroup.swift
//  Azkar Fold
//

import Foundation

enum AppGroup {
    static let identifier = "group.com.AhmedAlTahhan.Azkar-Fold"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: identifier) ?? .standard
    }

    enum Keys {
        static let prayerLocation = "prayer_location"
    }
}
