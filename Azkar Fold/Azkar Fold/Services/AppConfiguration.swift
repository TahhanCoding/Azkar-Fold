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
    static var shareMessage: String {
        L10n.t("share.app_message")
    }
    static let repositoryURL = "https://github.com/TahhanCoding/Azkar-Fold"
    static let repositoryDisplayLabel = "github.com/TahhanCoding/Azkar-Fold"
    static let privacyPolicyURL = "https://tahhancoding.github.io/Azkar-Fold/privacy-policy.html"

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
