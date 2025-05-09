import Foundation

enum SunnahAzkarCategory: String, CaseIterable {
    case morning = "MorningAzkar"
    case evening = "EveningAzkar"

    var fileName: String {
        switch self {
        case .morning:
            return "MorningAzkar.json"
        case .evening:
            return "EveningAzkar.json"
        }
    }
}
