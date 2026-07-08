//
//  SunnahZekrItem.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import Foundation

struct SunnahZekrItem: Identifiable, Decodable {
    let id: Int
    let zekr: String // Arabic Zekr
    let `repeat`: Int
    let bless: String? // Arabic Bless
    let source: String // Arabic Source
    
    // Translated Fields (Optional)
    let translatedZekr: String?
    let translatedBless: String?
    let translatedSource: String?

    enum CodingKeys: String, CodingKey {
        case id
        case zekr
        case `repeat` = "count" // Mapped from "count" in simplified JSON
        case bless
        case source
        case translatedZekr
        case translatedBless
        case translatedSource
    }
    
    init(entry: AzkarDBEntry, id: Int) {
        self.id = id
        self.zekr = entry.zekr
        self.repeat = entry.count ?? 1
        if let description = entry.description, !description.isEmpty {
            self.bless = description
        } else {
            self.bless = nil
        }
        self.source = entry.reference ?? ""
        self.translatedZekr = nil
        self.translatedBless = nil
        self.translatedSource = nil
    }
}
