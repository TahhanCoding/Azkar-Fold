//
//  AzkarDBModels.swift
//  Azkar Fold
//
//  Created by Ahmed AlTahhan on 29/05/2026.
//  Copyright © 2026 Ahmed AlTahhan. All rights reserved.
//

import Foundation

struct AzkarDBEntry {
    let category: String
    let zekr: String
    let description: String?
    let count: Int?
    let reference: String?
    let search: String?
}

extension AzkarDBEntry: Decodable {
    enum CodingKeys: String, CodingKey {
        case category
        case zekr
        case description
        case count
        case reference
        case search
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        category = try container.decode(String.self, forKey: .category)
        zekr = try container.decode(String.self, forKey: .zekr)
        description = try container.decodeFlexibleString(forKey: .description)
        count = try container.decodeFlexibleInt(forKey: .count)
        reference = try container.decodeFlexibleString(forKey: .reference)
        search = try container.decodeFlexibleString(forKey: .search)
    }
}

private extension KeyedDecodingContainer {
    func decodeFlexibleString(forKey key: Key) throws -> String? {
        if (try? decodeNil(forKey: key)) == true {
            return nil
        }
        if let value = try? decode(String.self, forKey: key) {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }
        if let value = try? decode(Int.self, forKey: key) {
            return String(value)
        }
        return nil
    }

    func decodeFlexibleInt(forKey key: Key) throws -> Int? {
        if (try? decodeNil(forKey: key)) == true {
            return nil
        }
        if let value = try? decode(Int.self, forKey: key) {
            return value
        }
        if let value = try? decode(String.self, forKey: key) {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty, let parsed = Int(trimmed) else {
                return nil
            }
            return parsed
        }
        return nil
    }
}
