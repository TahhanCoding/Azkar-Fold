//
//  PatternManager.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 11/07/2025.
//

import SwiftUI
import Combine

class PatternManager: ObservableObject {
    static let shared = PatternManager()
    
    @Published var currentPattern: String = "Islamic-Geometric-Tile"
    @Published var availablePatterns: [String] = []
    
    private let userDefaults = UserDefaults.standard
    private let currentPatternKey = "currentPattern"
    
    private init() {
        // Initialize with default patterns including "none" option
        availablePatterns = [
            "none",
            "Islamic-Geometric-Tile_1",
            "Islamic-Geometric-Tile_2"
        ]
        
        // Load current pattern from UserDefaults
        if let savedPattern = userDefaults.string(forKey: currentPatternKey),
           availablePatterns.contains(savedPattern) {
            self.currentPattern = savedPattern
        } else {
            self.currentPattern = availablePatterns.first ?? "none"
        }
    }
    
    // MARK: - Pattern Management
    
    func setCurrentPattern(_ pattern: String) {
        if availablePatterns.contains(pattern) {
            currentPattern = pattern
            saveCurrentPattern()
        }
    }
    
    func addCustomPattern(_ patternName: String) {
        if !availablePatterns.contains(patternName) {
            availablePatterns.append(patternName)
            saveAvailablePatterns()
        }
    }
    
    func removePattern(_ patternName: String) {
        if patternName != currentPattern { // Don't remove the currently selected pattern
            availablePatterns.removeAll { $0 == patternName }
            saveAvailablePatterns()
        }
    }
    
    // MARK: - Private Methods
    
    private func saveCurrentPattern() {
        userDefaults.set(currentPattern, forKey: currentPatternKey)
    }
    
    private func saveAvailablePatterns() {
        userDefaults.set(availablePatterns, forKey: "availablePatterns")
    }
}

// MARK: - Environment Key

struct PatternManagerKey: EnvironmentKey {
    static let defaultValue = PatternManager.shared
}

extension EnvironmentValues {
    var patternManager: PatternManager {
        get { self[PatternManagerKey.self] }
        set { self[PatternManagerKey.self] = newValue }
    }
}

// MARK: - View Extension

extension View {
    func withPatternManager() -> some View {
        self.environmentObject(PatternManager.shared)
    }
}
