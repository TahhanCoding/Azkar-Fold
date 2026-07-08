import Foundation
import SwiftUI

enum SunnahAzkarCategory: String, CaseIterable, Identifiable {
    case morning = "MorningAzkar"
    case evening = "Evening Azkar"
    case prayer = "PrayerAzkar"
    case sleeping = "SleepAzkar"
    case wakeup = "WakeUpAzkar"

    var id: String { self.rawValue }

    var dbCategoryName: String {
        switch self {
        case .morning:
            return "أذكار الصباح"
        case .evening:
            return "أذكار المساء"
        case .prayer:
            return "الأذكار بعد السلام من الصلاة"
        case .sleeping:
            return "أذكار النوم"
        case .wakeup:
            return "أذكار الاستيقاظ من النوم"
        }
    }

    func localizedTitle(using language: AppLanguageManager) -> String {
        language.text(localizationKey)
    }

    var title: String {
        AppLanguageManager.shared.text(localizationKey)
    }

    var localizationKey: String.LocalizationValue {
        switch self {
        case .morning:
            return "sunnah.category.morning"
        case .evening:
            return "sunnah.category.evening"
        case .prayer:
            return "sunnah.category.prayer"
        case .sleeping:
            return "sunnah.category.sleeping"
        case .wakeup:
            return "sunnah.category.wakeup"
        }
    }
    
    var iconName: String {
        switch self {
        case .morning:
            return "sunrise.fill"
        case .evening:
            return "sunset.fill"
        case .prayer:
            return "hands.sparkles.fill"
        case .sleeping:
            return "moon.stars.fill"
        case .wakeup:
            return "sun.max.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .morning:
            return .orange
        case .evening:
            return .purple
        case .prayer:
            return .blue
        case .sleeping:
            return .indigo
        case .wakeup:
            return .yellow
        }
    }
}
