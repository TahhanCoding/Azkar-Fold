//
//  ThemeManagerView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct ThemeManagerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var patternManager: PatternManager
    @State private var showingThemeEditor = false
    @State private var editingTheme: Theme?
    @State private var showingDeleteAlert = false
    @State private var themeToDelete: Theme?
    
    var body: some View {
        ZStack {
            BackgroundPatternView()
            MainContentView()
        }
        .navigationTitle("Theme Manager")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingThemeEditor) {
            ThemeEditorView(theme: editingTheme)
                .environmentObject(themeManager)
        }
        .alert("Delete Theme", isPresented: $showingDeleteAlert) {
            DeleteThemeAlert()
        } message: {
            Text("Are you sure you want to delete \"\(themeToDelete?.name ?? "this theme")\"? This action cannot be undone.")
        }
    }
}



// MARK: - Background Pattern View
extension ThemeManagerView {
    @ViewBuilder
    private func BackgroundPatternView() -> some View {
        GeometryReader { geometry in
            if patternManager.currentPattern == "none" {
                Color.clear
                    .frame(width: geometry.size.width, height: geometry.size.height)
            } else {
                Image(patternManager.currentPattern)
                    .resizable(resizingMode: .tile)
                    .opacity(0.55)
                    .ignoresSafeArea(.all)
            }
        }
        .ignoresSafeArea(.all)
    }
}

// MARK: - Main Content View
extension ThemeManagerView {
    @ViewBuilder
    private func MainContentView() -> some View {
        ScrollView {
            VStack(alignment: .center, spacing: 24) {
                BackgroundPatternSection()
                CurrentThemeSection()
                DefaultThemesSection()
                CustomThemesSection()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .safeAreaInset(edge: .top) {
            Color.clear.frame(height: 0)
        }
    }
}

// MARK: - Background Pattern Section
extension ThemeManagerView {
    @ViewBuilder
    private func BackgroundPatternSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Background Pattern")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(patternManager.availablePatterns, id: \.self) { pattern in
                        PatternCardView(
                            pattern: pattern,
                            isSelected: patternManager.currentPattern == pattern,
                            onSelect: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    patternManager.setCurrentPattern(pattern)
                                }
                            }
                        )
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Current Theme Section
extension ThemeManagerView {
    @ViewBuilder
    private func CurrentThemeSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Current Theme")
            CurrentThemeCard()
        }
    }
    
    @ViewBuilder
    private func CurrentThemeCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(themeManager.currentTheme.name)
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.text)
                
                Spacer()
                
                if themeManager.currentTheme.isDefault {
                    DefaultThemeBadge()
                }
            }
            
            ThemePreviewView(theme: themeManager.currentTheme, isCompact: false)
                .frame(height: 150)
        }
        .padding(16)
        .background(themeManager.currentTheme.cardBackground.opacity(0.9))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(themeManager.currentTheme.primary, lineWidth: 2)
        )
    }
    
    @ViewBuilder
    private func DefaultThemeBadge() -> some View {
        Text("Default")
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(themeManager.currentTheme.primary.opacity(0.2))
            .foregroundColor(themeManager.currentTheme.primary)
            .cornerRadius(8)
    }
}

// MARK: - Default Themes Section
extension ThemeManagerView {
    @ViewBuilder
    private func DefaultThemesSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Default Themes")
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 15) {
                    ForEach(Theme.defaultThemes) { theme in
                        ThemeCardView(
                            theme: theme,
                            isSelected: theme.id == themeManager.currentTheme.id,
                            onSelect: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    themeManager.setCurrentTheme(theme)
                                }
                            },
                            onDuplicate: {
                                duplicateTheme(theme)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Custom Themes Section
extension ThemeManagerView {
    @ViewBuilder
    private func CustomThemesSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Custom Themes")
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 15) {
                    CustomThemeCards()
                    CreateNewThemeButton()
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    @ViewBuilder
    private func CustomThemeCards() -> some View {
        ForEach(themeManager.customThemes) { theme in
            ThemeCardView(
                theme: theme,
                isSelected: theme.id == themeManager.currentTheme.id,
                onSelect: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        themeManager.setCurrentTheme(theme)
                    }
                },
                onEdit: {
                    editTheme(theme)
                },
                onDuplicate: {
                    duplicateTheme(theme)
                },
                onDelete: {
                    deleteTheme(theme)
                }
            )
        }
    }
    
    @ViewBuilder
    private func CreateNewThemeButton() -> some View {
        Button(action: createNewTheme) {
            VStack(spacing: 8) {
                Image(systemName: "paintbrush.pointed.fill")
                    .resizable()
                    .frame(width: 35, height: 35)
                    .foregroundColor(themeManager.currentTheme.primary)
            }
            .frame(width: 90, height: 80)
            .background(themeManager.currentTheme.cardBackground.opacity(0.8))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(themeManager.currentTheme.primary.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(12)
    }
}

// MARK: - Helper Views
extension ThemeManagerView {
    @ViewBuilder
    private func SectionHeaderView(title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(themeManager.currentTheme.text)
    }
    
    @ViewBuilder
    private func DeleteThemeAlert() -> some View {
        Group {
            Button("Cancel", role: .cancel) {
                themeToDelete = nil
            }
            Button("Delete", role: .destructive) {
                performDeleteTheme()
            }
        }
    }
}

// MARK: - Actions
extension ThemeManagerView {
    private func createNewTheme() {
        editingTheme = nil
        showingThemeEditor = true
    }
    
    private func editTheme(_ theme: Theme) {
        editingTheme = theme
        showingThemeEditor = true
    }
    
    private func duplicateTheme(_ theme: Theme) {
        let duplicatedTheme = themeManager.duplicateTheme(theme)
        editingTheme = duplicatedTheme
        showingThemeEditor = true
    }
    
    private func deleteTheme(_ theme: Theme) {
        themeToDelete = theme
        showingDeleteAlert = true
    }
    
    private func performDeleteTheme() {
        if let theme = themeToDelete {
            themeManager.deleteCustomTheme(theme)
        }
        themeToDelete = nil
    }
}

// MARK: - Pattern Card View
struct PatternCardView: View {
    let pattern: String
    let isSelected: Bool
    let onSelect: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                if pattern == "none" {
                    ZStack {
                        Color.clear
                        Text("None")
                            .font(.caption)
                            .foregroundColor(themeManager.currentTheme.text)
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(themeManager.currentTheme.text.opacity(0.5), style: .init(dash: [2, 2]))
                    )
                } else {
                    Image(pattern)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .cornerRadius(12)
                        .clipped()
                }
            }
            .background(themeManager.currentTheme.cardBackground.opacity(0.8))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? themeManager.currentTheme.primary : themeManager.currentTheme.primary.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .padding(7)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.15 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Theme Card View
struct ThemeCardView: View {
    let theme: Theme
    let isSelected: Bool
    let onSelect: () -> Void
    let onEdit: (() -> Void)?
    let onDuplicate: () -> Void
    let onDelete: (() -> Void)?
    
    init(theme: Theme, isSelected: Bool, onSelect: @escaping () -> Void, onEdit: (() -> Void)? = nil, onDuplicate: @escaping () -> Void, onDelete: (() -> Void)? = nil) {
        self.theme = theme
        self.isSelected = isSelected
        self.onSelect = onSelect
        self.onEdit = onEdit
        self.onDuplicate = onDuplicate
        self.onDelete = onDelete
    }
    
    var body: some View {
        Button(action: onSelect) {
            ThemeMiniCardView(theme: theme, isSelected: isSelected)
                .contextMenu {
                    ContextMenuItems()
                }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private func ContextMenuItems() -> some View {
        Group {
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

// MARK: - Theme Mini Card View
struct ThemeMiniCardView: View {
    let theme: Theme
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ThemeColorsGrid()
            
            Text(theme.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(theme.text)
                .padding(.vertical, 8)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 90)
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
        .shadow(color: theme.primary.opacity(isSelected ? 0.3 : 0), radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder
    private func ThemeColorsGrid() -> some View {
        VStack(spacing: 0) {
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
        .cornerRadius(8)
    }
}
