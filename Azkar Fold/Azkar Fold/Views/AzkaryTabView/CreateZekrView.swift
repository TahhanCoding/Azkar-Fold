//
//  CreateZekrView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 02/05/2025.
//

import SwiftUI

struct CreateZekrView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var zekrStore: ZekrStore
    @EnvironmentObject var appLanguage: AppLanguageManager
    @Environment(\.presentationMode) var presentationMode
    @State private var zekrText = ""
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(appLanguage.text("azkary.create_new"))
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(theme.currentTheme.primary)
                .padding(.top)
            
            TextField(appLanguage.text("azkary.placeholder"), text: $zekrText)
                .font(.headline)
                .foregroundColor(theme.currentTheme.text)
                .padding()
                .environment(\.layoutDirection, .rightToLeft)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.currentTheme.cardBackground)
                        .shadow(color: .black.opacity(0.2), radius: 0, x: 4, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(theme.currentTheme.primary, lineWidth: 2)
                        )
                )
                .padding(.horizontal)
            
            Button(action: {
                if !zekrText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    zekrStore.addZekr(text: zekrText) {
                        presentationMode.wrappedValue.dismiss()
                    }
                } else {
                    showAlert = true
                }
            }) {
                Text(appLanguage.text("azkary.create_button"))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(theme.currentTheme.buttonText)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        Rectangle()
                            .fill(theme.currentTheme.primary)
                            .shadow(color: .black.opacity(0.3), radius: 0, x: 4, y: 4)
                    )
                    .padding(.horizontal)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .navigationTitle(appLanguage.text("azkary.create_title"))
        .navigationBarTitleDisplayMode(.inline)
        .background(
            BackgroundView()
        )
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(appLanguage.text("azkary.empty_alert_title")),
                message: Text(appLanguage.text("azkary.empty_alert_message")),
                dismissButton: .default(Text(appLanguage.text("common.ok")).foregroundColor(theme.currentTheme.text))
            )
        }
    }
}
