//
//  L10n.swift
//  HRSD
//
//  Created by Ahmed AlTahhan on 08/07/2026.
//  Copyright © 2026 Future Workshops. All rights reserved.
//

import Foundation

enum L10n {
    static func t(_ key: String.LocalizationValue, locale: Locale = AppLanguageManager.shared.locale) -> String {
        String(localized: key, bundle: LocalizationBundle.bundle(for: locale))
    }

    static func t(_ key: String.LocalizationValue, locale: Locale, _ args: CVarArg...) -> String {
        String(format: t(key, locale: locale), locale: locale, arguments: args)
    }
}
