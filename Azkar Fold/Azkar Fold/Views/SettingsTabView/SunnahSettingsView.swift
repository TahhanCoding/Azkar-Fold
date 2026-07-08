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
    @EnvironmentObject var appLanguage: AppLanguageManager
    @ObservedObject private var settingsStore = SunnahSettingsStore.shared
    
    var body: some View {
        ZStack {
            BackgroundPatternView()
            
            List {
                Section {
                    HStack {
                        Text("sunnah_settings.initial_view")
                            .foregroundColor(theme.currentTheme.text)
                        Spacer()
                        CustomSegmentedPicker(
                            selection: $settingsStore.initialViewMode,
                            theme: theme
                        )
                        .frame(width: 150)
                    }
                    .listRowBackground(theme.currentTheme.cardBackground)

                    if !settingsStore.availableLanguages.isEmpty {
                        HStack {
                            Text("sunnah_settings.secondary_language")
                                .foregroundColor(theme.currentTheme.text)
                            Spacer()

                            Menu {
                                Button(action: {
                                    settingsStore.secondaryLanguage = "ar_only"
                                }) {
                                    HStack {
                                        Text("sunnah_settings.arabic_only")
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
                                            Text(appLanguage.locale.localizedString(forLanguageCode: lang)?.capitalized ?? lang.uppercased())
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
                        Text("sunnah_settings.3d_effects")
                            .foregroundColor(theme.currentTheme.text)
                        Spacer()
                        Toggle("", isOn: $settingsStore.enable3DEffects)
                            .toggleStyle(SwitchToggleStyle(tint: theme.currentTheme.primary))
                            .accessibilityLabel(appLanguage.text("sunnah_settings.3d_effects"))
                    }
                    .listRowBackground(theme.currentTheme.cardBackground)
                } header: {
                    Text("sunnah_settings.display_settings")
                        .foregroundColor(theme.currentTheme.text.opacity(0.8))
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("settings.sunnah_manager")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func languageDisplayName(for code: String) -> String {
        if code == "ar_only" {
            return appLanguage.text("sunnah_settings.arabic_only")
        }
        return appLanguage.locale.localizedString(forLanguageCode: code)?.capitalized ?? code.uppercased()
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
