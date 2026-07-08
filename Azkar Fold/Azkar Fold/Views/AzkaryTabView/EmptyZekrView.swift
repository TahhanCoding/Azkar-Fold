//
//  EmptyZekrView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct EmptyZekrView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var coordinator: NavigationCoordinator
    @EnvironmentObject var appLanguage: AppLanguageManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 80))
                .foregroundColor(theme.currentTheme.primary.opacity(0.7))
            
            Text(appLanguage.text("azkary.empty_title"))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(theme.currentTheme.text)
            
            Text(appLanguage.text("azkary.empty_subtitle"))
                .font(.subheadline)
                .foregroundColor(theme.currentTheme.text)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                coordinator.navigate(to: .createZekr)
            }) {
                Text(appLanguage.text("azkary.create_button"))
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
