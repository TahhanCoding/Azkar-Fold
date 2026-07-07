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

    var title: String {
        switch self {
        case .morning:
            return "Morning Azkar"
        case .evening:
            return "Evening Azkar"
        case .prayer:
            return "After Prayer Azkar"
        case .sleeping:
            return "Before Sleeping Azkar"
        case .wakeup:
            return "Waking up Azkar"
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
