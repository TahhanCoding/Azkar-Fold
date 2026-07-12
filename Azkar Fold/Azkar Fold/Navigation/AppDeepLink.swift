//
//  AppDeepLink.swift
//  Azkar Fold
//

import Foundation

enum AppDeepLink {
    static let openPrayerTab = Notification.Name("AzkarFoldOpenPrayerTab")
    static let prayerURLHost = "prayer"

    static func handle(_ url: URL) {
        let host = url.host?.lowercased() ?? ""
        let path = url.path.lowercased()
        if host == prayerURLHost || path.contains(prayerURLHost) {
            NotificationCenter.default.post(name: openPrayerTab, object: nil)
        }
    }
}
