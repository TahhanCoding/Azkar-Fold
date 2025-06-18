//
//  Theme.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI
import Foundation

struct Theme: Codable, Identifiable, Equatable {
    let id = UUID()
    var name: String
    var primaryColor: String
    var secondaryColor: String
    var backgroundColor: String
    var accentColor: String
    var textColor: String
    var cardBackgroundColor: String
    var buttonTextColor: String
    var isDefault: Bool
    var createdAt: Date
    
    init(
        name: String,
        primaryColor: String = "#4A9897",
        secondaryColor: String = "#45968B",
        backgroundColor: String = "#FAD358",
        accentColor: String = "#000000",
        textColor: String = "#000000",
        cardBackgroundColor: String = "#FEFEF7",
        buttonTextColor: String = "#FFFFFF",
        isDefault: Bool = false
    ) {
        self.name = name
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
        self.textColor = textColor
        self.cardBackgroundColor = cardBackgroundColor
        self.buttonTextColor = buttonTextColor
        self.isDefault = isDefault
        self.createdAt = Date()
    }
    
    // Default themes
    static let defaultTheme = Theme(
        name: "Default",
        primaryColor: "#4A9897",
        secondaryColor: "#45968B",
        backgroundColor: "#FAD358",
        accentColor: "#000000",
        textColor: "#000000",
        cardBackgroundColor: "#FEFEF7",
        buttonTextColor: "#FFFFFF",
        isDefault: true
    )
    
    static let darkTheme = Theme(
        name: "Dark",
        primaryColor: "#2D5A5A",
        secondaryColor: "#1E3A3A",
        backgroundColor: "#1C1C1E",
        accentColor: "#FFFFFF",
        textColor: "#FFFFFF",
        cardBackgroundColor: "#2C2C2E",
        buttonTextColor: "#FFFFFF",
        isDefault: true
    )
    
    static let oceanTheme = Theme(
        name: "Ocean",
        primaryColor: "#006994",
        secondaryColor: "#004D6B",
        backgroundColor: "#E6F3FF",
        accentColor: "#003D52",
        textColor: "#003D52",
        cardBackgroundColor: "#FFFFFF",
        buttonTextColor: "#FFFFFF",
        isDefault: true
    )
    
    static let sunsetTheme = Theme(
        name: "Sunset",
        primaryColor: "#FF6B35",
        secondaryColor: "#F7931E",
        backgroundColor: "#FFF8E1",
        accentColor: "#D84315",
        textColor: "#D84315",
        cardBackgroundColor: "#FFFFFF",
        buttonTextColor: "#FFFFFF",
        isDefault: true
    )
    
    static let defaultThemes: [Theme] = [
        defaultTheme,
        darkTheme,
        oceanTheme,
        sunsetTheme
    ]
}

// Theme colors as SwiftUI Colors
extension Theme {
    var primary: Color { Color(hex: primaryColor) }
    var secondary: Color { Color(hex: secondaryColor) }
    var background: Color { Color(hex: backgroundColor) }
    var accent: Color { Color(hex: accentColor) }
    var text: Color { Color(hex: textColor) }
    var cardBackground: Color { Color(hex: cardBackgroundColor) }
    var buttonText: Color { Color(hex: buttonTextColor) }
}