//
//  AzkarDBContentService.swift
//  Azkar Fold
//
//  Created by Ahmed AlTahhan on 29/05/2026.
//  Copyright © 2026 Ahmed AlTahhan. All rights reserved.
//

import Foundation

final class AzkarDBContentService {
    static let shared = AzkarDBContentService()

    private let sqliteStore = AzkarSQLiteStore()
    private var entriesByCategory: [String: [AzkarDBEntry]]?
    private var loadError: Error?

    private init() {
        AzkarDebugLog.log("AzkarDBContentService initialized (SQLite source)")
    }

    func items(for category: SunnahAzkarCategory) -> Result<[SunnahZekrItem], Error> {
        AzkarDebugLog.log("items(for:) requested category=\(category.rawValue) dbCategory=\(category.dbCategoryName)")

        switch loadIfNeeded() {
        case .failure(let error):
            AzkarDebugLog.log("items(for:) loadIfNeeded failed error=\(error.localizedDescription)")
            return .failure(error)
        case .success(let byCategory):
            AzkarDebugLog.log("items(for:) cache has \(byCategory.count) DB categories")
            let dbCategory = category.dbCategoryName
            guard let entries = byCategory[dbCategory], !entries.isEmpty else {
                let available = byCategory.keys.sorted().joined(separator: " | ")
                AzkarDebugLog.log("items(for:) categoryNotFound lookup=\(dbCategory) availableCategories=[\(available)]")
                return .failure(AzkarDBContentError.categoryNotFound(dbCategory))
            }
            let items = entries.enumerated().map { index, entry in
                SunnahZekrItem(entry: entry, id: index + 1)
            }
            AzkarDebugLog.log("items(for:) success category=\(category.rawValue) itemCount=\(items.count)")
            return .success(items)
        }
    }

    private func loadIfNeeded() -> Result<[String: [AzkarDBEntry]], Error> {
        if let entriesByCategory {
            AzkarDebugLog.log("loadIfNeeded using cached categories count=\(entriesByCategory.count)")
            return .success(entriesByCategory)
        }
        if let loadError {
            AzkarDebugLog.log("loadIfNeeded returning cached error=\(loadError.localizedDescription)")
            return .failure(loadError)
        }

        AzkarDebugLog.log("loadIfNeeded starting fresh SQLite load")
        logBundleDiagnostics()

        do {
            let entries = try sqliteStore.loadAllEntries()
            var grouped: [String: [AzkarDBEntry]] = [:]
            for entry in entries {
                grouped[entry.category, default: []].append(entry)
            }
            entriesByCategory = grouped
            AzkarDebugLog.log("loadIfNeeded grouped into \(grouped.count) categories from SQLite")
            for (name, list) in grouped.sorted(by: { $0.key < $1.key }).prefix(8) {
                AzkarDebugLog.log("loadIfNeeded sample category=\(name) count=\(list.count)")
            }
            return .success(grouped)
        } catch {
            loadError = error
            AzkarDebugLog.log("loadIfNeeded SQLite load failed error=\(error)")
            return .failure(error)
        }
    }

    private func logBundleDiagnostics() {
        AzkarDebugLog.log("bundle id=\(Bundle.main.bundleIdentifier ?? "nil")")
        AzkarDebugLog.log("bundle resourcePath=\(Bundle.main.resourcePath ?? "nil")")

        if let resourcePath = Bundle.main.resourcePath {
            do {
                let topLevel = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                let azkarFiles = topLevel.filter { $0.contains("azkar") }
                AzkarDebugLog.log("bundle azkar-related top-level files=\(azkarFiles)")
            } catch {
                AzkarDebugLog.log("bundle top-level listing failed error=\(error)")
            }
        }
    }
}

enum AzkarDBContentError: LocalizedError {
    case fileNotFound
    case categoryNotFound(String)
    case databaseOpenFailed(String)
    case queryFailed(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Azkar database file not found in app bundle."
        case .categoryNotFound(let name):
            return "No azkar found for category: \(name)"
        case .databaseOpenFailed(let message):
            return "Failed to open azkar database: \(message)"
        case .queryFailed(let message):
            return "Failed to read azkar database: \(message)"
        }
    }
}
