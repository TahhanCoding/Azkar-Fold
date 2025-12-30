//
//  SunnahSettingsStore.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI
import Combine

class SunnahSettingsStore: ObservableObject {
    static let shared = SunnahSettingsStore()
    
    enum InitialViewMode: String, CaseIterable, Identifiable {
        case simple
        case full
        
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .simple: return "Simple"
            case .full: return "Full"
            }
        }
    }
    
    enum CardHeightMode: String, CaseIterable, Identifiable {
        case fixed
        case adaptive
        
        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .fixed: return "Fixed"
            case .adaptive: return "Adaptive"
            }
        }
    }
    
    @AppStorage("sunnah_initial_view_mode") var initialViewMode: InitialViewMode = .full
    @AppStorage("sunnah_card_height_mode") var cardHeightMode: CardHeightMode = .fixed
    @AppStorage("sunnah_secondary_language") var secondaryLanguage: String = "en"
    
    // Published property for immediate UI updates with UserDefaults persistence
    @Published var enable3DEffects: Bool
    
    private init() {
        // Initialize enable3DEffects from UserDefaults before calling super
        let savedValue = UserDefaults.standard.object(forKey: "enable3DEffects") as? Bool ?? true
        self.enable3DEffects = savedValue
        
        // Ensure defaults are set on first launch
        initializeDefaults()
        
        // Setup observer to persist changes
        setupObservers()
    }
    
    private func setupObservers() {
        // Use Combine to observe changes and persist
        $enable3DEffects
            .dropFirst() // Skip initial value
            .sink { [weak self] newValue in
                UserDefaults.standard.set(newValue, forKey: "enable3DEffects")
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func initializeDefaults() {
        let defaults = UserDefaults.standard
        
        // Set default values if keys don't exist
        if defaults.string(forKey: "sunnah_initial_view_mode") == nil {
            defaults.set(InitialViewMode.full.rawValue, forKey: "sunnah_initial_view_mode")
        }
        
        if defaults.string(forKey: "sunnah_card_height_mode") == nil {
            defaults.set(CardHeightMode.fixed.rawValue, forKey: "sunnah_card_height_mode")
        }
        
        if defaults.string(forKey: "sunnah_secondary_language") == nil {
            defaults.set("en", forKey: "sunnah_secondary_language")
        }
        
        // enable3DEffects already has a default via @AppStorage, but ensure it exists
        if defaults.object(forKey: "enable3DEffects") == nil {
            defaults.set(true, forKey: "enable3DEffects")
        }
        
        defaults.synchronize()
    }
}
