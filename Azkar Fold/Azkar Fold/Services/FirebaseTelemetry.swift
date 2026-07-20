//
//  FirebaseTelemetry.swift
//  Azkar Fold
//
//  Created by Ahmed AlTahhan on 18/07/2026.
//  Copyright © 2026 Ahmed AlTahhan. All rights reserved.
//

import Foundation
import FirebaseAnalytics
import FirebaseCrashlytics

/// Thin wrapper around Analytics + Crashlytics. No PII (no zekr text, no coordinates).
enum FirebaseTelemetry {
    enum Event {
        static let shareZekr = "share_zekr"
        static let prayerTabOpen = "prayer_tab_open"
        static let openAppStore = "open_app_store"
        static let whatsNewDismiss = "whats_new_dismiss"
    }

    private static let appLanguageProperty = "app_language"

    static func configure() {
        syncAppLanguage(AppLanguageManager.shared.current)
    }

    static func syncAppLanguage(_ language: AppLanguage) {
        Analytics.setUserProperty(language.rawValue, forName: appLanguageProperty)
        Crashlytics.crashlytics().setCustomValue(language.rawValue, forKey: appLanguageProperty)
    }

    static func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }

    static func log(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }

    static func recordNonFatal(_ error: Error) {
        Crashlytics.crashlytics().record(error: error)
    }
}
