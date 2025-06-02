import Foundation
import SwiftUI

enum SunnahAzkarCategory: String, CaseIterable, Identifiable {
    case morning = "MorningAzkar"
    case evening = "Evening Azkar"

    var id: String { self.rawValue }

    var fileName: String {
        switch self {
        case .morning:
            return "MorningAzkar.json"
        case .evening:
            return "EveningAzkar.json"
        }
    }
    
    var title: String {
        switch self {
        case .morning:
            return "Morning Azkar"
        case .evening:
            return "Evening Azkar"
        }
    }
    
    var iconName: String {
        switch self {
        case .morning:
            return "sunrise.fill"
        case .evening:
            return "sunset.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .morning:
            return .orange
        case .evening:
            return .purple
        }
    }
}
