//
//  SunnahSettingsView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct SunnahSettingsView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var patternManager: PatternManager
    @StateObject private var settingsStore = SunnahSettingsStore.shared
    
    var body: some View {
        ZStack {
            BackgroundPatternView()
            
            List {
                Section {
                    // Initial View Mode
                    HStack {
                        Text("Initial View Mode")
                            .foregroundColor(theme.currentTheme.text)
                        Spacer()
                        Picker("", selection: $settingsStore.initialViewMode) {
                            ForEach(SunnahSettingsStore.InitialViewMode.allCases) { mode in
                                Text(mode.displayName).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 150)
                    }
                    .listRowBackground(theme.currentTheme.cardBackground)
                    
                    // Card Height Mode
                    HStack {
                        Text("Card Height")
                            .foregroundColor(theme.currentTheme.text)
                        Spacer()
                        Picker("", selection: $settingsStore.cardHeightMode) {
                            ForEach(SunnahSettingsStore.CardHeightMode.allCases) { mode in
                                Text(mode.displayName).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 150)
                    }
                    .listRowBackground(theme.currentTheme.cardBackground)
                    
                    // Secondary Language (Disabled for now)
                    HStack {
                        Text("Secondary Language")
                            .foregroundColor(theme.currentTheme.text)
                        Spacer()
                        Text("English")
                            .foregroundColor(theme.currentTheme.text.opacity(0.5))
                    }
                    .listRowBackground(theme.currentTheme.cardBackground)
                    
                    // 3D Effects Toggle
                    HStack {
                        Text("3D Effects")
                            .foregroundColor(theme.currentTheme.text)
                        Spacer()
                        Toggle("", isOn: $settingsStore.enable3DEffects)
                            .toggleStyle(SwitchToggleStyle(tint: theme.currentTheme.primary))
                    }
                    .listRowBackground(theme.currentTheme.cardBackground)
                } header: {
                    Text("Display Settings")
                        .foregroundColor(theme.currentTheme.text.opacity(0.8))
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Sunnah Zekr Manager")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func BackgroundPatternView() -> some View {
        GeometryReader { geometry in
            if patternManager.currentPattern == "none" {
                theme.currentTheme.background
                    .ignoresSafeArea(.all)
            } else {
                ZStack {
                    theme.currentTheme.background
                        .ignoresSafeArea(.all)
                    
                    Image(patternManager.currentPattern)
                        .resizable(resizingMode: .tile)
                        .opacity(0.55)
                        .ignoresSafeArea(.all)
                }
            }
        }
        .ignoresSafeArea(.all)
    }
}
