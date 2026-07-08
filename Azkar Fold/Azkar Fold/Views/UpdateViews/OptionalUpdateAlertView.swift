//
//  OptionalUpdateAlertView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct OptionalUpdateAlertView: View {
    @ObservedObject var updateManager: UpdateManager
    @EnvironmentObject var themeManager: ThemeManager
    
    private var formattedImprovements: [String] {
        guard !updateManager.whatIsNew.isEmpty else { return [] }
        return updateManager.whatIsNew
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    updateManager.dismissOptionalUpdate()
                }
            
            // Alert Content
            VStack(spacing: 20) {
                Text("Update Available")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(themeManager.currentTheme.text)
                
                Text("A new version (\(updateManager.availableVersion)) of Azkar Fold is available with new features and improvements.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(themeManager.currentTheme.text.opacity(0.7))
                
                if !formattedImprovements.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("What's New:")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(themeManager.currentTheme.text)
                            .padding(.top, 4)
                        
                        ForEach(formattedImprovements, id: \.self) { improvement in
                            HStack(alignment: .top, spacing: 6) {
                                Text("•")
                                    .font(.caption)
                                    .foregroundStyle(themeManager.currentTheme.primary)
                                Text(improvement)
                                    .font(.caption)
                                    .foregroundStyle(themeManager.currentTheme.text.opacity(0.7))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
                }
                
                HStack(spacing: 15) {
                    Button(action: {
                        updateManager.dismissOptionalUpdate()
                    }) {
                        Text(AppConfiguration.isAppStoreConfigured ? "Later" : "OK")
                            .font(.body)
                            .foregroundStyle(themeManager.currentTheme.text.opacity(0.7))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                    }

                    if AppConfiguration.isAppStoreConfigured {
                        Button(action: {
                            updateManager.openAppStore()
                        }) {
                            Text("Update")
                                .font(.headline)
                                .foregroundStyle(themeManager.currentTheme.buttonText)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 25)
                                .background(themeManager.currentTheme.primary)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.top, 10)
            }
            .padding(24)
            .background(themeManager.currentTheme.cardBackground)
            .cornerRadius(16)
            .shadow(radius: 10)
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    let mockManager = UpdateManager.shared
    mockManager.availableVersion = "1.2.0"
    mockManager.currentVersion = "1.0.0"
    
    return OptionalUpdateAlertView(updateManager: mockManager)
        .environmentObject(ThemeManager.shared)
}

