//
//  AppLanguageManager.swift
//  HRSD
//
//  Created by Ahmed AlTahhan on 08/07/2026.
//  Copyright © 2026 Future Workshops. All rights reserved.
//

import SwiftUI
import Combine

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case arabic = "ar"

    var id: String { rawValue }

    var locale: Locale {
        Locale(identifier: rawValue)
    }

    var layoutDirection: LayoutDirection {
        self == .arabic ? .rightToLeft : .leftToRight
    }

    func displayName(using manager: AppLanguageManager) -> String {
        switch self {
        case .english:
            return manager.text("settings.language.english")
        case .arabic:
            return manager.text("settings.language.arabic")
        }
    }
}

final class AppLanguageManager: ObservableObject {
    static let shared = AppLanguageManager()

    private let storageKey = "app_language_code"
    private let hasChosenLanguageKey = "app_language_has_chosen"

    @Published private(set) var current: AppLanguage
    @Published private(set) var refreshID = UUID()

    var locale: Locale { current.locale }
    var layoutDirection: LayoutDirection { current.layoutDirection }

    private var localizationBundle: Bundle {
        LocalizationBundle.bundle(for: current.rawValue)
    }

    private init() {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: hasChosenLanguageKey),
           let saved = defaults.string(forKey: storageKey),
           let language = AppLanguage(rawValue: saved) {
            current = language
        } else if let preferred = Locale.preferredLanguages.first,
                  preferred.hasPrefix("ar") {
            current = .arabic
        } else {
            current = .english
        }
        syncAppleLanguagesPreference()
    }

    func setLanguage(_ language: AppLanguage) {
        guard current != language else { return }
        current = language
        UserDefaults.standard.set(language.rawValue, forKey: storageKey)
        UserDefaults.standard.set(true, forKey: hasChosenLanguageKey)
        syncAppleLanguagesPreference()
        refreshID = UUID()
    }

    func text(_ key: String.LocalizationValue) -> String {
        String(localized: key, bundle: localizationBundle)
    }

    func text(_ key: String.LocalizationValue, _ args: CVarArg...) -> String {
        String(format: text(key), locale: locale, arguments: args)
    }

    private func syncAppleLanguagesPreference() {
        UserDefaults.standard.set([current.rawValue], forKey: "AppleLanguages")
    }
}
