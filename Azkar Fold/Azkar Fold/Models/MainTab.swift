//
//  MainTab.swift
//  Azkar Fold
//

import Foundation
import SwiftUI

enum MainTab: String, CaseIterable, Identifiable, Hashable {
    case azkary
    case sunnah
    case prayer
    case settings

    var id: String { rawValue }

    static let defaultOrder: [MainTab] = [.azkary, .sunnah, .prayer, .settings]

    var titleKey: String.LocalizationValue {
        switch self {
        case .azkary: return "tab.azkary"
        case .sunnah: return "tab.sunnah"
        case .prayer: return "tab.prayer"
        case .settings: return "tab.settings"
        }
    }

    var titleLocalizedStringKey: LocalizedStringKey {
        switch self {
        case .azkary: return "tab.azkary"
        case .sunnah: return "tab.sunnah"
        case .prayer: return "tab.prayer"
        case .settings: return "tab.settings"
        }
    }

    var systemImage: String {
        switch self {
        case .azkary: return "heart.fill"
        case .sunnah: return "book.fill"
        case .prayer: return "moon.stars.fill"
        case .settings: return "gear"
        }
    }
}
