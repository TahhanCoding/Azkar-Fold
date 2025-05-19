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

    enum CodingKeys: String, CodingKey {
        case id, zekr, `repeat`, bless
        case transliteration = "zekr_transliteration"
        case bless_en = "bless_english_translation"
        case en_tr = "english_translation"
    }
}
