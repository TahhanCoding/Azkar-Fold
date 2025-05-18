import Foundation

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
}
