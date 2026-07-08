//
//  LocalizationBundle.swift
//  Azkar Fold
//
//  Created by Ahmed AlTahhan on 08/07/2026.
//  Copyright © 2026 Ahmed AlTahhan. All rights reserved.
//

import Foundation

enum LocalizationBundle {
    static func bundle(for languageCode: String) -> Bundle {
        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return .main
    }

    static func bundle(for locale: Locale) -> Bundle {
        let code = locale.language.languageCode?.identifier ?? locale.identifier
        return bundle(for: code)
    }
}
