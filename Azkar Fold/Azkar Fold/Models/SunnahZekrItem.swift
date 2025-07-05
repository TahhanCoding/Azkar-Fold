import Foundation

struct SunnahAzkar: Decodable {
    let title: String
    let content: [SunnahZekrItem]
}
struct SunnahZekrItem: Identifiable, Decodable {
    let id: Int
    let zekr: String
    let transliteration: String
    let en_tr: String
    let `repeat`: Int
    let bless: String?
    let bless_en: String?
    let source: String

    enum CodingKeys: String, CodingKey {
        case id
        case zekr = "zekr_arabic"
        case `repeat` = "to_count"
        case en_tr = "zekr_english"
        case transliteration = "zekr_english_transliteration"
        case bless = "bless_arabic"
        case bless_en = "bless_english"
        case source
    }
}
