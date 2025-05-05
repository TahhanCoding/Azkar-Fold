//
//  Color+Extensions.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

extension Color {
    // Hex code initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static let azkarPrimary = Color(hex: "2596be")
    static let azkarSecondary =  Color(hex: "F5C400").opacity(0.7)
    
    static let azkarPrimaryLight = Color(hex: "FFDF4F") // Lighter yellow
    static let azkarPrimaryDark = Color(hex: "D4AF37") // Darker gold
    
    // Background colors
    static let azkarBackground = Color("AzkarBackground", bundle: nil) ?? Color.white.opacity(0.95)
    
    // Neo-brutalism accent colors
    static let azkarAccent = Color("AzkarAccent", bundle: nil) ?? Color.black.opacity(0.8)
    
    // Legacy color names for backward compatibility
    @available(*, deprecated, renamed: "azkarPrimary")
    static let azkarPurple = azkarPrimary
    @available(*, deprecated, renamed: "azkarPrimaryLight")
    static let azkarPurpleLight = azkarPrimaryLight
    @available(*, deprecated, renamed: "azkarPrimaryDark")
    static let azkarPurpleDark = azkarPrimaryDark
}
