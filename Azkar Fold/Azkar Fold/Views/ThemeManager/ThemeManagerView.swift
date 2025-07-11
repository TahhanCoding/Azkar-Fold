//
//  ThemeManagerView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct ThemeManagerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingThemeEditor = false
    @State private var editingTheme: Theme?
    @State private var showingDeleteAlert = false
    @State private var themeToDelete: Theme?
    
    var body: some View {
        VStack(alignment: .leading) {
            // Current theme section
            currentThemeCard
                .padding(.horizontal)
                .padding(.bottom, 10)
            
            Text("Default Themes")
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.text)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(Theme.defaultThemes) { theme in
                        ThemeCardView(
                            theme: theme,
                            isSelected: theme.id == themeManager.currentTheme.id,
                            onSelect: {
                                withAnimation {
                                    themeManager.setCurrentTheme(theme)
                                }
                            },
                            onDuplicate: {
                                let duplicatedTheme = themeManager.duplicateTheme(theme)
                                editingTheme = duplicatedTheme
                                showingThemeEditor = true
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            Divider()
                .padding(.horizontal)
                .padding(.vertical, 5)
            
            Text("Custom Themes")
                .font(.headline)
                .foregroundColor(themeManager.currentTheme.text)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    if !themeManager.customThemes.isEmpty {
                        ForEach(themeManager.customThemes) { theme in
                            ThemeCardView(
                                theme: theme,
                                isSelected: theme.id == themeManager.currentTheme.id,
                                onSelect: {
                                    withAnimation {
                                        themeManager.setCurrentTheme(theme)
                                    }
                                },
                                onEdit: {
                                    editingTheme = theme
                                    showingThemeEditor = true
                                },
                                onDuplicate: {
                                    let duplicatedTheme = themeManager.duplicateTheme(theme)
                                    editingTheme = duplicatedTheme
                                    showingThemeEditor = true
                                },
                                onDelete: {
                                    themeToDelete = theme
                                    showingDeleteAlert = true
                                }
                            )
                        }
                    }
                    
                    // Create new theme button
                    Button(action: {
                        editingTheme = nil
                        showingThemeEditor = true
                    }) {
                        VStack {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(themeManager.currentTheme.primary)
                            Text("Create New Theme")
                                .font(.caption)
                                .foregroundColor(themeManager.currentTheme.primary)
                        }
                        .frame(width: 120, height: 120)
                        .background(themeManager.currentTheme.cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(themeManager.currentTheme.primary.opacity(0.5), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Theme Manager")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingThemeEditor) {
            ThemeEditorView(theme: editingTheme)
                .environmentObject(themeManager)
        }
        .alert("Delete Theme", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                themeToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let theme = themeToDelete {
                    themeManager.deleteCustomTheme(theme)
                }
                themeToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete \"\(themeToDelete?.name ?? "this theme")\"? This action cannot be undone.")
        }
    }
    
    private var currentThemeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(themeManager.currentTheme.name)
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.text)
                
                Spacer()
                
                if themeManager.currentTheme.isDefault {
                    Text("Default")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(themeManager.currentTheme.primary.opacity(0.2))
                        .foregroundColor(themeManager.currentTheme.primary)
                        .cornerRadius(8)
                }
            }
            
            ThemePreviewView(theme: themeManager.currentTheme, isCompact: false)
                .frame(height: 150) // Increased height for full preview
        }
        .padding()
        .background(themeManager.currentTheme.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.currentTheme.primary, lineWidth: 2)
        )
    }
}

struct ThemeCardView: View {
    let theme: Theme
    var isSelected: Bool
    let onSelect: () -> Void
    var onEdit: (() -> Void)? = nil
    let onDuplicate: () -> Void
    var onDelete: (() -> Void)? = nil

    var body: some View {
        Button(action: onSelect) {
            ThemeMiniCardView(theme: theme, isSelected: isSelected)
                .contextMenu {
                    Button("Select") {
                        onSelect()
                    }
                    if let onEdit = onEdit {
                        Button("Edit") {
                            onEdit()
                        }
                    }
                    Button("Duplicate") {
                        onDuplicate()
                    }
                    if let onDelete = onDelete {
                        Button("Delete", role: .destructive) {
                            onDelete()
                        }
                    }
                }
        }
    }
}

struct ThemeMiniCardView: View {
    let theme: Theme
    var isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Color preview section
            themeColorsGrid()
            
            // Theme name
            Text(theme.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(theme.text)
                .padding(.vertical, 5)
        }
        .frame(width: 80)
        .padding(8)
        .background(theme.background)
        .cornerRadius(16)
        .overlay(
            Group {
                if isSelected {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(theme.primary, lineWidth: 3)
                }
            }
        )
        .padding(5)
    }
    
    
    @ViewBuilder
    private func themeColorsGrid() -> some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(theme.primary)
                .frame(height: 20)
            Rectangle()
                .fill(theme.secondary)
                .frame(height: 20)
            Rectangle()
                .fill(theme.accent)
                .frame(height: 20)
        }
        
        // Color preview section
        HStack(spacing: 0) {
            Rectangle()
                .fill(theme.text)
                .frame(height: 20)
            Rectangle()
                .fill(theme.cardBackground)
                .frame(height: 20)
            Rectangle()
                .fill(theme.buttonText)
                .frame(height: 20)
        }
    }
}
