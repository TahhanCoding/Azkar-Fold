//
//  AppConfiguration.swift
//  HRSD
//
//  Created by Ahmed AlTahhan on 08/07/2026.
//  Copyright © 2026 Future Workshops. All rights reserved.
//

import Foundation

enum AppConfiguration {
    static let appStoreID = "6745419190"

    static let supportEmail = "tahhancoding@gmail.com"
    static let shareMessage = "Check out Azkar Fold - Your Islamic Remembrance Companion!"

    static var marketingVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    static var appStoreURL: URL? {
        guard !appStoreID.isEmpty else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(appStoreID)")
    }

    static var isAppStoreConfigured: Bool {
        appStoreURL != nil
    }
}
