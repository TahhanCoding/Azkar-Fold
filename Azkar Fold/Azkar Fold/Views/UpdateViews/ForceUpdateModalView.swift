//
//  ForceUpdateModalView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct ForceUpdateModalView: View {
    @ObservedObject var updateManager: UpdateManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appLanguage: AppLanguageManager
    
    private var formattedImprovements: [String] {
        guard !updateManager.whatIsNew.isEmpty else { return [] }
        return updateManager.whatIsNew
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    var body: some View {
        ZStack {
            themeManager.currentTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(themeManager.currentTheme.primary)
                
                VStack(spacing: 12) {
                    Text("update.required_title")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(themeManager.currentTheme.text)
                    
                    Text("update.required_message")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(themeManager.currentTheme.text.opacity(0.7))
                        .padding(.horizontal)
                    
                    if !formattedImprovements.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("update.whats_new")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(themeManager.currentTheme.text)
                                .padding(.top, 8)
                            
                            ForEach(formattedImprovements, id: \.self) { improvement in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundStyle(themeManager.currentTheme.primary)
                                    Text(improvement)
                                        .font(.subheadline)
                                        .foregroundStyle(themeManager.currentTheme.text.opacity(0.7))
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    
                    Text(appLanguage.text("update.versions", updateManager.currentVersion, updateManager.requiredVersion))
                        .font(.caption)
                        .foregroundStyle(themeManager.currentTheme.text.opacity(0.7))
                        .padding(.top, 4)
                }
                
                Button(action: {
                    updateManager.openAppStore()
                }) {
                    Text("update.now")
                        .font(.headline)
                        .foregroundStyle(themeManager.currentTheme.buttonText)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.currentTheme.primary)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
        }
        .interactiveDismissDisabled()
    }
}

#Preview {
    let mockManager = UpdateManager.shared
    mockManager.requiredVersion = "2.0.0"
    mockManager.currentVersion = "1.0.0"
    
    return ForceUpdateModalView(updateManager: mockManager)
        .environmentObject(ThemeManager.shared)
        .environmentObject(AppLanguageManager.shared)
}
