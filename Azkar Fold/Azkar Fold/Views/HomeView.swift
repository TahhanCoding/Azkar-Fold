//
//  HomeView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        TabView {
            AzkaryTabView()
                .tabItem {
                    Label("tab.azkary", systemImage: "heart.fill")
                }
                .tag(0)

            
            SunnahTabView()
                .tabItem {
                    Label("tab.sunnah", systemImage: "book.fill")
                }
                .tag(1)
            
            SettingsTabView()
                .tabItem {
                    Label("tab.settings", systemImage: "gear")
                }
                .tag(2)
        }
        .accentColor(theme.currentTheme.primary)
    }
}
