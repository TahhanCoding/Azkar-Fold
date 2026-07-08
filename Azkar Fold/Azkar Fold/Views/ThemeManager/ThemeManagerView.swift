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
    @EnvironmentObject var appLanguage: AppLanguageManager
    @State private var showingThemeEditor = false
    @State private var editingTheme: Theme?
    @State private var showingDeleteAlert = false
    @State private var themeToDelete: Theme?
    
    var body: some View {
        ZStack {
            BackgroundPatternView()
            MainContentView()
        }
        .navigationTitle("theme.manager_title")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingThemeEditor) {
            ThemeEditorView(theme: editingTheme)
                .environmentObject(themeManager)
                .environmentObject(appLanguage)
        }
        .alert(appLanguage.text("theme.delete_title"), isPresented: $showingDeleteAlert) {
            DeleteThemeAlert()
        } message: {
            Text(appLanguage.text("theme.delete_named_message", themeToDelete?.localizedName(using: appLanguage) ?? appLanguage.text("theme.new")))
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
            SectionHeaderView(titleKey: "theme.background_pattern")
            
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
            SectionHeaderView(titleKey: "theme.current_theme")
            CurrentThemeCard()
        }
    }
    
    @ViewBuilder
    private func CurrentThemeCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(themeManager.currentTheme.localizedName(using: appLanguage))
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
        Text("theme.default")
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
            SectionHeaderView(titleKey: "theme.default_themes")
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 15) {
                    ForEach(Theme.defaultThemes) { theme in
                        ThemeCardView(
                            theme: theme,
                            isSelected: theme.isSameTheme(as: themeManager.currentTheme),
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
            SectionHeaderView(titleKey: "theme.custom_themes")
            
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
                isSelected: theme.isSameTheme(as: themeManager.currentTheme),
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
        .accessibilityLabel(appLanguage.text("theme.create_title"))
        .padding(12)
    }
}

// MARK: - Helper Views
extension ThemeManagerView {
    @ViewBuilder
    private func SectionHeaderView(titleKey: String.LocalizationValue) -> some View {
        Text(appLanguage.text(titleKey))
            .font(.headline)
            .foregroundColor(themeManager.currentTheme.text)
    }
    
    @ViewBuilder
    private func DeleteThemeAlert() -> some View {
        Group {
            Button(appLanguage.text("common.cancel"), role: .cancel) {
                themeToDelete = nil
            }
            Button(appLanguage.text("common.delete"), role: .destructive) {
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
                        Text("theme.none")
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
    @EnvironmentObject var appLanguage: AppLanguageManager
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
            Button(appLanguage.text("theme.select")) {
                onSelect()
            }
            
            if let onEdit = onEdit {
                Button(appLanguage.text("common.edit")) {
                    onEdit()
                }
            }
            
            Button(appLanguage.text("theme.duplicate")) {
                onDuplicate()
            }
            
            if let onDelete = onDelete {
                Button(appLanguage.text("common.delete"), role: .destructive) {
                    onDelete()
                }
            }
        }
    }
}

// MARK: - Theme Mini Card View
struct ThemeMiniCardView: View {
    @EnvironmentObject var appLanguage: AppLanguageManager
    let theme: Theme
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ThemeColorsGrid()
            
            Text(theme.localizedName(using: appLanguage))
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
