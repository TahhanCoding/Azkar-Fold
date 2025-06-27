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
        List {
            // Current theme section
            Section {
                currentThemeCard
            } header: {
                Text("Current Theme")
                    .foregroundColor(themeManager.currentTheme.text)
            }
            
            // Default themes section
            Section {
                ForEach(Theme.defaultThemes) { theme in
                    ThemeRowView(
                        theme: theme,
                        isSelected: theme.id == themeManager.currentTheme.id,
                        onSelect: {
                            withAnimation {
                                themeManager.setCurrentTheme(theme)
                            }
                        },
                        onEdit: nil,
                        onDuplicate: {
                            let duplicatedTheme = themeManager.duplicateTheme(theme)
                            editingTheme = duplicatedTheme
                            showingThemeEditor = true
                        },
                        onDelete: nil
                    )
                }
            } header: {
                Text("Default Themes")
                    .foregroundColor(themeManager.currentTheme.text)
            }
            
            // Custom themes section
            Section {
                if themeManager.customThemes.isEmpty {
                    Text("No custom themes yet")
                        .foregroundColor(themeManager.currentTheme.text)
                        .font(.subheadline)
                        .padding(.vertical, 8)
                } else {
                    ForEach(themeManager.customThemes) { theme in
                        ThemeRowView(
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
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(themeManager.currentTheme.primary)
                        Text("Create New Theme")
                            .foregroundColor(themeManager.currentTheme.primary)
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text("Custom Themes")
                    .foregroundColor(themeManager.currentTheme.text)
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
            
            ThemePreviewView(theme: themeManager.currentTheme, isCompact: true)
                .frame(height: 60)
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

struct ThemeRowView: View {
    let theme: Theme
    let isSelected: Bool
    let onSelect: () -> Void
    let onEdit: (() -> Void)?
    let onDuplicate: () -> Void
    let onDelete: (() -> Void)?
    
    @State private var showingActionSheet = false
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Theme preview
                ThemePreviewView(theme: theme, isCompact: true)
                    .frame(width: 60, height: 40)
                    .cornerRadius(6)
                
                // Theme info
                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.name)
                    .font(.headline)
                    .foregroundColor(theme.text)
                    
                    if theme.isDefault {
                        Text("Default Theme")
                            .font(.caption)
                            .foregroundColor(theme.text)
                    } else {
                        Text("Custom Theme")
                            .font(.caption)
                            .foregroundColor(theme.text)
                    }
                }
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(theme.primary)
                        .font(.title3)
                }
                
                // More options button
                Button(action: {
                    showingActionSheet = true
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
        .confirmationDialog("Theme Options", isPresented: $showingActionSheet) {
            Button("Select Theme") {
                onSelect()
            }
            
            if let onEdit = onEdit {
                Button("Edit Theme") {
                    onEdit()
                }
            }
            
            Button("Duplicate Theme") {
                onDuplicate()
            }
            
            if let onDelete = onDelete {
                Button("Delete Theme", role: .destructive) {
                    onDelete()
                }
            }
            
            Button("Cancel", role: .cancel) { }
        }
    }
}

#Preview {
    NavigationView {
        ThemeManagerView()
            .environmentObject(ThemeManager.shared)
    }
}
