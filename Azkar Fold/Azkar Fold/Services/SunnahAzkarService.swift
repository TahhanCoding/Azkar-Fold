//
//  SunnahAzkarService.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import Foundation

class SunnahAzkarService {

    enum AzkarLoadingError: Error {
        case fileNotFound
        case dataCorrupted
        case parsingFailed(Error)
        case unknownError
        case contentNotAvailable(String)
    }

    private let dbContentService = AzkarDBContentService.shared

    func loadAzkar(for category: SunnahAzkarCategory) -> Result<[SunnahZekrItem], AzkarLoadingError> {
        AzkarDebugLog.log("loadAzkar(for:) start category=\(category.rawValue) title=\(category.title)")

        switch dbContentService.items(for: category) {
        case .success(let items):
            AzkarDebugLog.log("loadAzkar(for:) success category=\(category.rawValue) count=\(items.count)")
            return .success(items)
        case .failure(let error as AzkarDBContentError):
            AzkarDebugLog.log("loadAzkar(for:) AzkarDBContentError category=\(category.rawValue) error=\(error.localizedDescription)")
            switch error {
            case .fileNotFound, .databaseOpenFailed, .queryFailed:
                return .failure(.fileNotFound)
            case .categoryNotFound(let name):
                return .failure(.contentNotAvailable("Content not available for \(name)"))
            }
        case .failure(let error):
            AzkarDebugLog.log("loadAzkar(for:) parsingFailed category=\(category.rawValue) error=\(error.localizedDescription)")
            return .failure(.parsingFailed(error))
        }
    }
}

extension SunnahAzkarService.AzkarLoadingError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Azkar database file not found in app bundle."
        case .dataCorrupted:
            return "Azkar data is corrupted."
        case .parsingFailed(let error):
            return "Failed to parse azkar data: \(error.localizedDescription)"
        case .unknownError:
            return "Unknown error loading azkar."
        case .contentNotAvailable(let message):
            return message
        }
    }
}
