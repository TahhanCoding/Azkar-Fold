//
//  ThemePreviewView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct ThemePreviewView: View {
    @EnvironmentObject private var appLanguage: AppLanguageManager
    let theme: Theme
    let isCompact: Bool
    
    init(theme: Theme, isCompact: Bool = false) {
        self.theme = theme
        self.isCompact = isCompact
    }
    
    var body: some View {
        if isCompact {
            compactPreview
        } else {
            fullPreview
        }
    }
    
    private var compactPreview: some View {
        VStack(spacing: 8) {
            HStack {
                Text(appLanguage.text("theme.preview.label"))
                    .font(.caption)
                    .foregroundColor(theme.text)
                Spacer()
                Circle()
                    .fill(theme.primary)
                    .frame(width: 12, height: 12)
            }
            
            RoundedRectangle(cornerRadius: 6)
                .fill(theme.cardBackground)
                .frame(height: 40)
                .overlay(
                    HStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(theme.primary)
                            .frame(width: 20, height: 20)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Rectangle()
                                .fill(theme.text)
                                .frame(height: 3)
                            Rectangle()
                                .fill(theme.text.opacity(0.6))
                                .frame(width: 30, height: 2)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                )
        }
        .padding(8)
        .background(theme.background)
        .cornerRadius(8)
    }
    
    private var fullPreview: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerSection
                cardSection
                buttonSection
                listSection
                tabBarSection
            }
            .padding()
        }
        .background(theme.background)
        .cornerRadius(12)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(appLanguage.text("theme.preview.app_header"))
                .font(.caption)
                .foregroundColor(theme.text.opacity(0.7))
                .textCase(.uppercase)
            
            HStack {
                Text(appLanguage.text("app.name"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.primary)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "gear")
                        .foregroundColor(theme.accent)
                }
                .accessibilityLabel(appLanguage.text("tab.settings"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var cardSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(appLanguage.text("theme.preview.cards"))
                .font(.caption)
                .foregroundColor(theme.text.opacity(0.7))
                .textCase(.uppercase)
            
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.cardBackground)
                    .frame(height: 80)
                    .overlay(
                        HStack {
                            Circle()
                                .fill(theme.primary)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(theme.buttonText)
                                        .font(.system(size: 16))
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(appLanguage.text("sunnah.category.morning"))
                                    .font(.headline)
                                    .foregroundColor(theme.text)
                                
                                Text(appLanguage.text("theme.preview.sample_subtitle"))
                                    .font(.caption)
                                    .foregroundColor(theme.text.opacity(0.6))
                            }
                            
                            Spacer()
                            
                            Text("12/15")
                                .font(.caption)
                                .foregroundColor(theme.accent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(theme.accent.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding()
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(theme.primary.opacity(0.2), lineWidth: 1)
                    )
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.secondary.opacity(0.1))
                    .frame(height: 60)
                    .overlay(
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(theme.secondary)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "book.fill")
                                        .foregroundColor(theme.buttonText)
                                        .font(.system(size: 14))
                                )
                            
                            Text(appLanguage.text("tab.sunnah"))
                                .font(.subheadline)
                                .foregroundColor(theme.text)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.forward")
                                .foregroundColor(theme.text.opacity(0.4))
                                .font(.system(size: 12))
                        }
                        .padding()
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var buttonSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(appLanguage.text("theme.preview.buttons"))
                .font(.caption)
                .foregroundColor(theme.text.opacity(0.7))
                .textCase(.uppercase)
            
            VStack(spacing: 12) {
                Button(action: {}) {
                    Text(appLanguage.text("theme.preview.primary_button"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.buttonText)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(theme.primary)
                        .cornerRadius(8)
                }
                
                Button(action: {}) {
                    Text(appLanguage.text("theme.preview.secondary_button"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.primary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(theme.primary.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(theme.primary, lineWidth: 1)
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var listSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(appLanguage.text("theme.preview.list_items"))
                .font(.caption)
                .foregroundColor(theme.text.opacity(0.7))
                .textCase(.uppercase)
            
            VStack(spacing: 1) {
                ForEach(0..<3) { index in
                    HStack {
                        Circle()
                            .fill(theme.accent.opacity(0.2))
                            .frame(width: 8, height: 8)
                        
                        Text(appLanguage.text("theme.preview.list_item", index + 1))
                            .font(.body)
                            .foregroundColor(theme.text)
                        
                        Spacer()
                        
                        Text(appLanguage.text("theme.preview.detail"))
                            .font(.caption)
                            .foregroundColor(theme.text.opacity(0.6))
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(theme.cardBackground)
                }
            }
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var tabBarSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(appLanguage.text("theme.preview.tab_bar"))
                .font(.caption)
                .foregroundColor(theme.text.opacity(0.7))
                .textCase(.uppercase)
            
            HStack {
                ForEach(["heart.fill", "book.fill", "gear"], id: \.self) { icon in
                    VStack(spacing: 4) {
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundColor(icon == "heart.fill" ? theme.primary : theme.text.opacity(0.6))
                        
                        Rectangle()
                            .fill(icon == "heart.fill" ? theme.primary : Color.clear)
                            .frame(width: 20, height: 2)
                            .cornerRadius(1)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 8)
            .background(theme.cardBackground)
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack {
        ThemePreviewView(theme: Theme.defaultTheme, isCompact: true)
            .frame(height: 80)
        
        ThemePreviewView(theme: Theme.defaultTheme)
            .frame(height: 400)
    }
    .padding()
    .environmentObject(AppLanguageManager.shared)
}
