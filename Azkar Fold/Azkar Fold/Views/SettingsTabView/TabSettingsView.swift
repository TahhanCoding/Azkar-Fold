//
//  TabSettingsView.swift
//  Azkar Fold
//

import SwiftUI

struct TabSettingsView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var patternManager: PatternManager
    @EnvironmentObject var appLanguage: AppLanguageManager
    @ObservedObject private var tabPreferences = TabPreferencesStore.shared

    var body: some View {
        ZStack {
            backgroundPatternView

            List {
                Section {
                    HStack {
                        Text(appLanguage.text("tab_settings.show_prayer"))
                            .foregroundColor(theme.currentTheme.text)
                        Spacer()
                        Toggle(
                            "",
                            isOn: Binding(
                                get: { tabPreferences.isPrayerVisible },
                                set: { tabPreferences.setPrayerVisible($0) }
                            )
                        )
                        .toggleStyle(SwitchToggleStyle(tint: theme.currentTheme.primary))
                        .accessibilityLabel(appLanguage.text("tab_settings.show_prayer"))
                    }
                    .listRowBackground(theme.currentTheme.cardBackground)
                } header: {
                    Text(appLanguage.text("tab_settings.visibility"))
                        .foregroundColor(theme.currentTheme.text.opacity(0.8))
                }

                Section {
                    ForEach(tabPreferences.tabOrder) { tab in
                        HStack(spacing: 12) {
                            Image(systemName: tab.systemImage)
                                .foregroundColor(theme.currentTheme.primary)
                                .frame(width: 24)

                            Text(appLanguage.text(tab.titleKey))
                                .foregroundColor(theme.currentTheme.text)

                            if tab == .prayer && !tabPreferences.isPrayerVisible {
                                Spacer()
                                Text(appLanguage.text("tab_settings.hidden"))
                                    .font(.caption)
                                    .foregroundColor(theme.currentTheme.text.opacity(0.5))
                            }
                        }
                        .listRowBackground(theme.currentTheme.cardBackground)
                    }
                    .onMove(perform: tabPreferences.moveTabs)
                } header: {
                    Text(appLanguage.text("tab_settings.order"))
                        .foregroundColor(theme.currentTheme.text.opacity(0.8))
                } footer: {
                    Text(appLanguage.text("tab_settings.order_hint"))
                        .foregroundColor(theme.currentTheme.text.opacity(0.6))
                }

                Section {
                    HStack {
                        Text(appLanguage.text("tab_settings.startup_tab"))
                            .foregroundColor(theme.currentTheme.text)
                        Spacer()

                        Menu {
                            ForEach(tabPreferences.visibleTabs) { tab in
                                Button {
                                    tabPreferences.setStartupTab(tab)
                                } label: {
                                    HStack {
                                        Text(appLanguage.text(tab.titleKey))
                                        if tabPreferences.startupTab == tab {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(appLanguage.text(tabPreferences.resolvedStartupTab().titleKey))
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
                } header: {
                    Text(appLanguage.text("tab_settings.startup"))
                        .foregroundColor(theme.currentTheme.text.opacity(0.8))
                }
            }
            .scrollContentBackground(.hidden)
            .environment(\.editMode, .constant(.active))
        }
        .navigationTitle(appLanguage.text("settings.tabs"))
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var backgroundPatternView: some View {
        GeometryReader { _ in
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

#Preview {
    NavigationStack {
        TabSettingsView()
            .environmentObject(ThemeManager.shared)
            .environmentObject(PatternManager.shared)
            .environmentObject(AppLanguageManager.shared)
    }
}
