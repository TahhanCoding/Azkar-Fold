//
//  Color+Extensions.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

// MARK: - Theme-Aware Colors
extension Color {
    /// Get the current theme's primary color
    static var themePrimary: Color {
        ThemeManager.shared.currentTheme.primary
    }
    
    /// Get the current theme's secondary color
    static var themeSecondary: Color {
        ThemeManager.shared.currentTheme.secondary
    }
    
    /// Get the current theme's background color
    static var themeBackground: Color {
        ThemeManager.shared.currentTheme.background
    }
    
    /// Get the current theme's accent color
    static var themeAccent: Color {
        ThemeManager.shared.currentTheme.accent
    }
    
    /// Get the current theme's text color
    static var themeText: Color {
        ThemeManager.shared.currentTheme.text
    }
    
    /// Get the current theme's card background color
    static var themeCardBackground: Color {
        ThemeManager.shared.currentTheme.cardBackground
    }
    
    /// Get the current theme's button text color
    static var themeButtonText: Color {
        ThemeManager.shared.currentTheme.buttonText
    }
}

// MARK: - Hex Color Support
extension Color {
    /// Initialize a Color from a hex string
    /// Supports formats: #RGB, #RRGGBB, #AARRGGBB
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
            (a, r, g, b) = (255, 0, 0, 0) // Default to black for invalid hex
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Convert Color to hex string
//    func toHex() -> String {
//        let uiColor = UIColor(self)
//        var red: CGFloat = 0
//        var green: CGFloat = 0
//        var blue: CGFloat = 0
//        var alpha: CGFloat = 0
//        
//        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
//        
//        let r = Int(red * 255)
//        let g = Int(green * 255)
//        let b = Int(blue * 255)
//        
//        return String(format: "#%02X%02X%02X", r, g, b)
//    }
    
    /// Check if a hex string is valid
    static func isValidHex(_ hex: String) -> Bool {
        let hexPattern = "^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$"
        let regex = try? NSRegularExpression(pattern: hexPattern)
        let range = NSRange(location: 0, length: hex.count)
        return regex?.firstMatch(in: hex, options: [], range: range) != nil
    }
}

// MARK: - Color Utilities
extension Color {
    /// Create a lighter version of the color
    func lighter(by percentage: Double = 0.2) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return Color(UIColor(hue: hue, saturation: saturation, brightness: min(brightness + CGFloat(percentage), 1.0), alpha: alpha))
    }
    
    /// Create a darker version of the color
    func darker(by percentage: Double = 0.2) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return Color(UIColor(hue: hue, saturation: saturation, brightness: max(brightness - CGFloat(percentage), 0.0), alpha: alpha))
    }
}
