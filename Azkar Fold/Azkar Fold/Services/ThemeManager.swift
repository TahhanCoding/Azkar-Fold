//
//  ThemeManager.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: Theme
    @Published var customThemes: [Theme] = []
    @Published var allThemes: [Theme] = []
    
    private let userDefaults = UserDefaults.standard
    private let currentThemeKey = "currentTheme"
    private let customThemesKey = "customThemes"
    
    private init() {
        // Load current theme
        if let themeData = userDefaults.data(forKey: currentThemeKey),
           let theme = try? JSONDecoder().decode(Theme.self, from: themeData) {
            self.currentTheme = theme
        } else {
            self.currentTheme = Theme.defaultTheme
        }
        
        // Load custom themes
        if let themesData = userDefaults.data(forKey: customThemesKey),
           let themes = try? JSONDecoder().decode([Theme].self, from: themesData) {
            self.customThemes = themes
        }
        
        updateAllThemes()
    }
    
    // MARK: - Theme Management
    
    func setCurrentTheme(_ theme: Theme) {
        self.currentTheme = theme
        if let encoded = try? JSONEncoder().encode(currentTheme) {
            userDefaults.set(encoded, forKey: currentThemeKey)
        }
        userDefaults.synchronize()
    }
    
    func addCustomTheme(_ theme: Theme) {
        customThemes.append(theme)
        updateAllThemes()
        saveCustomThemes()
    }
    
    func updateCustomTheme(_ theme: Theme) {
        if let index = customThemes.firstIndex(where: { $0.id == theme.id }) {
            customThemes[index] = theme
            updateAllThemes()
            saveCustomThemes()
            
            // Update current theme if it's the one being edited
            if currentTheme.id == theme.id {
                setCurrentTheme(theme)
            }
        }
    }
    
    func deleteCustomTheme(_ theme: Theme) {
        customThemes.removeAll { $0.id == theme.id }
        updateAllThemes()
        saveCustomThemes()
        
        // If deleted theme was current, switch to default
        if currentTheme.id == theme.id {
            setCurrentTheme(Theme.defaultTheme)
        }
    }
    
    func duplicateTheme(_ theme: Theme) -> Theme {
        var newTheme = theme
        newTheme.name = "\(theme.name) Copy"
        newTheme.isDefault = false
        return newTheme
    }
    
    // MARK: - Private Methods
    
    private func updateAllThemes() {
        allThemes = Theme.defaultThemes + customThemes
    }
    

    private func saveCustomThemes() {
        if let encoded = try? JSONEncoder().encode(customThemes) {
            userDefaults.set(encoded, forKey: customThemesKey)
            userDefaults.synchronize()
        }
    }
    
    // MARK: - Theme Validation
    
    func isValidHexColor(_ hex: String) -> Bool {
        let hexPattern = "^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$"
        let regex = try? NSRegularExpression(pattern: hexPattern)
        let range = NSRange(location: 0, length: hex.count)
        return regex?.firstMatch(in: hex, options: [], range: range) != nil
    }
    
    func validateTheme(_ theme: Theme) -> [String] {
        var errors: [String] = []
        
        if theme.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Theme name cannot be empty")
        }
        
        let colorProperties = [
            ("Primary Color", theme.primaryColor),
            ("Secondary Color", theme.secondaryColor),
            ("Background Color", theme.backgroundColor),
            ("Accent Color", theme.accentColor),
            ("Text Color", theme.textColor),
            ("Card Background Color", theme.cardBackgroundColor),
            ("Button Text Color", theme.buttonTextColor)
        ]
        
        for (name, color) in colorProperties {
            if !isValidHexColor(color) {
                errors.append("\(name) must be a valid hex color")
            }
        }
        
        return errors
    }
}

// MARK: - Environment Key

struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager.shared
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    func withThemeManager() -> some View {
        self.environmentObject(ThemeManager.shared)
    }
}
