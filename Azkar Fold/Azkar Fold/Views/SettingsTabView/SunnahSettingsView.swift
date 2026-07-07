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
    @ObservedObject private var settingsStore = SunnahSettingsStore.shared
    
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
                        CustomSegmentedPicker(
                            selection: $settingsStore.initialViewMode,
                            theme: theme
                        )
                        .frame(width: 150)
                    }
                    .listRowBackground(theme.currentTheme.cardBackground)
                    
                    // Card Height Mode
                    HStack {
                        Text("Card Height")
                            .foregroundColor(theme.currentTheme.text)
                        Spacer()
                        CustomSegmentedPicker(
                            selection: $settingsStore.cardHeightMode,
                            theme: theme
                        )
                        .frame(width: 150)
                    }
                    .listRowBackground(theme.currentTheme.cardBackground)

                    if !settingsStore.availableLanguages.isEmpty {
                        HStack {
                            Text("Secondary Language")
                                .foregroundColor(theme.currentTheme.text)
                            Spacer()

                            Menu {
                                Button(action: {
                                    settingsStore.secondaryLanguage = "ar_only"
                                }) {
                                    HStack {
                                        Text("Arabic Only")
                                        if settingsStore.secondaryLanguage == "ar_only" {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }

                                ForEach(settingsStore.availableLanguages, id: \.self) { lang in
                                    Button(action: {
                                        settingsStore.secondaryLanguage = lang
                                    }) {
                                        HStack {
                                            Text(Locale.current.localizedString(forLanguageCode: lang)?.capitalized ?? lang.uppercased())
                                            if settingsStore.secondaryLanguage == lang {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(languageDisplayName(for: settingsStore.secondaryLanguage))
                                        .foregroundColor(theme.currentTheme.text)
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption)
                                        .foregroundColor(theme.currentTheme.text.opacity(0.5))
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(theme.currentTheme.cardBackground.opacity(0.5))
                                .cornerRadius(8)
                            }
                        }
                        .listRowBackground(theme.currentTheme.cardBackground)
                    }

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
    
    private func languageDisplayName(for code: String) -> String {
        if code == "ar_only" {
            return "Arabic Only"
        }
        return Locale.current.localizedString(forLanguageCode: code)?.capitalized ?? code.uppercased()
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
