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
    
    private var formattedImprovements: [String] {
        guard !updateManager.whatIsNew.isEmpty else { return [] }
        return updateManager.whatIsNew
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    var body: some View {
        ZStack {
            // Background
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
                    Text("Update Required")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(themeManager.currentTheme.text)
                    
                    Text("A new version of Azkar Fold is available. Please update to continue using the app.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(themeManager.currentTheme.text.opacity(0.7))
                        .padding(.horizontal)
                    
                    if !formattedImprovements.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What's New:")
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
                    
                    Text("Current: \(updateManager.currentVersion) • Required: \(updateManager.requiredVersion)")
                        .font(.caption)
                        .foregroundStyle(themeManager.currentTheme.text.opacity(0.7))
                        .padding(.top, 4)
                }
                
                Button(action: {
                    updateManager.openAppStore()
                }) {
                    Text("Update Now")
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
}

