//
//  SettingsTabView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    var body: some View {
        TabView {
            AzkaryTabView()
                .tabItem {
                    Label("Azkary", systemImage: "heart.fill")
                }
                .tag(0)

            
            SunnahTabView()
                .tabItem {
                    Label("Sunnah", systemImage: "book.fill")
                }
                .tag(1)
            
            SettingsTabView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .accentColor(.appPrimary)
    }
}
