//
//  AzkarFont.swift
//  HRSD
//
//  Created by Ahmed AlTahhan on 08/07/2026.
//  Copyright © 2026 Future Workshops. All rights reserved.
//

import CoreText
import SwiftUI
import UIKit

enum AzkarFont {
    static let bundleFileName = "AmiriQuran-Regular"
    static let bundleExtension = "ttf"
    static let bundleSubdirectory = "Fonts"
    static let postScriptName = "AmiriQuran-Regular"

    static let listSize: CGFloat = 22
    static let detailSize: CGFloat = 28
    static let shareBaseSize: CGFloat = 28
    static let inputSize: CGFloat = 22
    static let launchTitleSize: CGFloat = 42
    static let launchTaglineSize: CGFloat = 17
    static let settingsHeaderSize: CGFloat = 28
    static let settingsDuaSize: CGFloat = 18

    static func registerIfNeeded() {
        guard UIFont(name: postScriptName, size: 12) == nil else { return }
        guard let url = fontFileURL else { return }
        CTFontManagerRegisterFontURLs([url] as CFArray, .process, true, nil)
    }

    static var isAvailable: Bool {
        UIFont(name: postScriptName, size: 12) != nil
    }

    static func zekrFont(size: CGFloat) -> Font {
        registerIfNeeded()
        guard isAvailable else {
            return .system(size: size)
        }
        return .custom(postScriptName, size: size)
    }

    static func uiFont(size: CGFloat) -> UIFont {
        registerIfNeeded()
        return UIFont(name: postScriptName, size: size) ?? .systemFont(ofSize: size)
    }

    static func launchFont(size: CGFloat, isArabic: Bool) -> Font {
        guard isArabic else {
            return .system(size: size, weight: .black)
        }
        return zekrFont(size: size)
    }

    static func launchTaglineFont(isArabic: Bool) -> Font {
        guard isArabic else {
            return .headline
        }
        return zekrFont(size: launchTaglineSize)
    }

    private static var fontFileURL: URL? {
        if let url = Bundle.main.url(
            forResource: bundleFileName,
            withExtension: bundleExtension,
            subdirectory: bundleSubdirectory
        ) {
            return url
        }
        return Bundle.main.url(forResource: bundleFileName, withExtension: bundleExtension)
    }
}

extension View {
    func azkarContentFont(size: CGFloat) -> some View {
        font(AzkarFont.zekrFont(size: size))
    }

    func azkarLaunchFont(size: CGFloat, isArabic: Bool) -> some View {
        font(AzkarFont.launchFont(size: size, isArabic: isArabic))
    }
}
