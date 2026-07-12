//
//  HomeView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var theme: ThemeManager
    @ObservedObject private var tabPreferences = TabPreferencesStore.shared
    @State private var selectedTab: MainTab = TabPreferencesStore.shared.resolvedStartupTab()
    @State private var didApplyStartupTab = false

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(tabPreferences.visibleTabs) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Label(tab.titleLocalizedStringKey, systemImage: tab.systemImage)
                    }
                    .tag(tab)
            }
        }
        .accentColor(theme.currentTheme.primary)
        .onAppear {
            applyStartupTabIfNeeded()
        }
        .onChange(of: tabPreferences.isPrayerVisible) { _ in
            ensureValidSelection()
        }
        .onChange(of: tabPreferences.tabOrder) { _ in
            ensureValidSelection()
        }
        .onReceive(NotificationCenter.default.publisher(for: AppDeepLink.openPrayerTab)) { _ in
            openPrayerTabIfAvailable()
        }
    }

    @ViewBuilder
    private func tabContent(for tab: MainTab) -> some View {
        switch tab {
        case .azkary:
            AzkaryTabView()
        case .sunnah:
            SunnahTabView()
        case .prayer:
            PrayerTabView()
        case .settings:
            SettingsTabView()
        }
    }

    private func applyStartupTabIfNeeded() {
        guard !didApplyStartupTab else { return }
        didApplyStartupTab = true
        selectedTab = tabPreferences.resolvedStartupTab()
    }

    private func ensureValidSelection() {
        if !tabPreferences.visibleTabs.contains(selectedTab) {
            selectedTab = tabPreferences.resolvedStartupTab()
        }
    }

    private func openPrayerTabIfAvailable() {
        if tabPreferences.visibleTabs.contains(.prayer) {
            selectedTab = .prayer
        }
    }
}
