//
//  SettingsTabView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct EmptyZekrView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 80))
                .foregroundColor(theme.currentTheme.primary.opacity(0.7))
            
            Text("No custom Azkar created yet")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(theme.currentTheme.text)
            
            Text("Tap the Create button to start your first Zekr")
                .font(.subheadline)
                .foregroundColor(theme.currentTheme.text)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                coordinator.navigate(to: .createZekr)
            }) {
                Text("Create Zekr")
                    .font(.headline)
                    .foregroundColor(theme.currentTheme.buttonText)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(theme.currentTheme.primary)
                    .cornerRadius(8)
            }
            .padding(.top, 10)
        }
        .padding()
    }
}
