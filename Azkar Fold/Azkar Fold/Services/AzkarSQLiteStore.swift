//
//  AzkarSQLiteStore.swift
//  Azkar Fold
//
//  Created by Ahmed AlTahhan on 29/05/2026.
//  Copyright © 2026 Ahmed AlTahhan. All rights reserved.
//

import Foundation
import SQLite3

final class AzkarSQLiteStore {
    private let databaseName = "azkar-db"
    private let subdirectory = "azkar-db-master"

    func loadAllEntries() throws -> [AzkarDBEntry] {
        guard let url = bundleDatabaseURL() else {
            AzkarDebugLog.log("AzkarSQLiteStore bundleDatabaseURL not found")
            throw AzkarDBContentError.fileNotFound
        }

        AzkarDebugLog.log("AzkarSQLiteStore opening database path=\(url.path)")

        var database: OpaquePointer?
        let openResult = sqlite3_open_v2(url.path, &database, SQLITE_OPEN_READONLY, nil)
        guard openResult == SQLITE_OK, let database else {
            let message = database.flatMap { String(cString: sqlite3_errmsg($0)) } ?? "unknown"
            AzkarDebugLog.log("AzkarSQLiteStore open failed code=\(openResult) message=\(message)")
            throw AzkarDBContentError.databaseOpenFailed(message)
        }
        defer { sqlite3_close(database) }

        let sql = """
        SELECT category, zekr, description, count, reference, search
        FROM azkar
        ORDER BY rowid
        """

        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(database, sql, -1, &statement, nil) == SQLITE_OK,
              let statement else {
            let message = String(cString: sqlite3_errmsg(database))
            AzkarDebugLog.log("AzkarSQLiteStore prepare failed message=\(message)")
            throw AzkarDBContentError.queryFailed(message)
        }
        defer { sqlite3_finalize(statement) }

        var entries: [AzkarDBEntry] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            entries.append(
                AzkarDBEntry(
                    category: columnText(statement, index: 0) ?? "",
                    zekr: columnText(statement, index: 1) ?? "",
                    description: columnOptionalText(statement, index: 2),
                    count: columnOptionalInt(statement, index: 3),
                    reference: columnOptionalText(statement, index: 4),
                    search: columnOptionalText(statement, index: 5)
                )
            )
        }

        AzkarDebugLog.log("AzkarSQLiteStore loaded entries count=\(entries.count)")
        return entries
    }

    private func bundleDatabaseURL() -> URL? {
        let subdirectories: [String?] = [subdirectory, nil]
        for subdir in subdirectories {
            if let url = Bundle.main.url(
                forResource: databaseName,
                withExtension: nil,
                subdirectory: subdir
            ) {
                AzkarDebugLog.log("AzkarSQLiteStore found database subdir=\(subdir ?? "nil") path=\(url.path)")
                return url
            }
        }

        if let walked = walkBundleForDatabase() {
            AzkarDebugLog.log("AzkarSQLiteStore found database via walk path=\(walked.path)")
            return walked
        }

        return nil
    }

    private func walkBundleForDatabase() -> URL? {
        guard let resourcePath = Bundle.main.resourcePath else { return nil }

        let root = URL(fileURLWithPath: resourcePath)
        guard let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else { return nil }

        for case let fileURL as URL in enumerator where fileURL.lastPathComponent == databaseName {
            return fileURL
        }
        return nil
    }

    private func columnText(_ statement: OpaquePointer, index: Int32) -> String? {
        guard let cString = sqlite3_column_text(statement, index) else { return nil }
        return String(cString: cString)
    }

    private func columnOptionalText(_ statement: OpaquePointer, index: Int32) -> String? {
        guard sqlite3_column_type(statement, index) != SQLITE_NULL else { return nil }
        guard let value = columnText(statement, index: index) else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func columnOptionalInt(_ statement: OpaquePointer, index: Int32) -> Int? {
        guard sqlite3_column_type(statement, index) != SQLITE_NULL else { return nil }
        return Int(sqlite3_column_int(statement, index))
    }
}
