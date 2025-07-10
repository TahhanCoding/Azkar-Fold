//
//  SunnahTabView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 02/05/2025.
//

import SwiftUI

struct SunnahTabView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var coordinator: NavigationCoordinator
    @EnvironmentObject var progressStore: SunnahProgressStore

    private let azkarService = SunnahAzkarService()

    @State private var isEditing = false
    @State private var temporarySelectedCategories: Set<SunnahAzkarCategory> = []
    @State private var azkarCounts: [SunnahAzkarCategory: Int] = [:]

    var body: some View {
        VStack(spacing: 0) {
            headerView
            contentView
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundView())
        .onAppear {
            progressStore.resetDailyProgressIfNeeded()
            progressStore.loadSelectedCategories()
            temporarySelectedCategories = progressStore.selectedSunnahCategories

            Task {
                await loadAzkarCounts()
            }
        }
    }

    private var headerView: some View {
        HStack {
            Text("Daily Sunnah Azkar")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(theme.currentTheme.primary)

            Spacer()

            Button {
                handleEditTap()
            } label: {
                Text(isEditing ? "Save" : "Edit")
                    .font(.headline)
                    .foregroundColor(theme.currentTheme.buttonText)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(theme.currentTheme.primary)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 16) {
                if isEditing {
                    editModeContent
                } else {
                    displayModeContent
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 45)
    }

    private var editModeContent: some View {
        ForEach(SunnahAzkarCategory.allCases) { category in
            AzkarCard(
                title: category.title,
                iconName: category.iconName,
                isEditing: true,
                isSelectedForEditing: temporarySelectedCategories.contains(category),
                onToggleSelection: {
                    toggleCategory(category)
                },
                backgroundColor: category.color
            )
        }
    }
    private var displayModeContent: some View {
        VStack(spacing: 16) {
            if progressStore.selectedSunnahCategories.isEmpty {
                Text("No Sunnah categories selected. Tap 'Edit' to choose categories.")
                    .foregroundColor(theme.currentTheme.text)
                    .padding()
                    .multilineTextAlignment(.center)
            } else {
                ForEach(SunnahAzkarCategory.allCases.filter { progressStore.selectedSunnahCategories.contains($0) }) { category in
                    NavigationLink {
                        loadSunnahZekrView(for: category)
                    } label: {
                        AzkarCard(
                            title: category.title,
                            iconName: category.iconName,
                            isCompleted: isCategoryCompleted(for: category),
                            backgroundColor: category.color
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    

    @ViewBuilder
    private func loadSunnahZekrView(for category: SunnahAzkarCategory) -> some View {
        let result = azkarService.loadAzkar(for: category)
        switch result {
        case .success(let azkarList):
            SunnahZekrView(
                azkarList: azkarList,
                category: category,
                progressStore: progressStore
            )
        case .failure(let error):
            ErrorView(error: "Failed to load \(category.rawValue): \(error.localizedDescription)")
        }
    }

    private func handleEditTap() {
        if isEditing {
            progressStore.selectedSunnahCategories = temporarySelectedCategories
            progressStore.saveSelectedCategories()
        } else {
            temporarySelectedCategories = progressStore.selectedSunnahCategories
        }
        isEditing.toggle()
    }
    private func toggleCategory(_ category: SunnahAzkarCategory) {
        if temporarySelectedCategories.contains(category) {
            temporarySelectedCategories.remove(category)
        } else {
            temporarySelectedCategories.insert(category)
        }
    }
    private func loadAzkarCounts() async {
        await withTaskGroup(of: Void.self) { group in
            for category in SunnahAzkarCategory.allCases {
                group.addTask {
                    let result = await self.azkarService.loadAzkar(for: category)
                    if case .success(let azkarList) = result {
                        await MainActor.run {
                            self.azkarCounts[category] = azkarList.count
                        }
                    }
                }
            }
        }
    }
    private func isCategoryCompleted(for category: SunnahAzkarCategory) -> Bool {
        let totalCount = azkarCounts[category] ?? 0
        return progressStore.isCategoryFullyCompleted(category: category, totalAzkarCount: totalCount)
    }
}


// Helper view for Azkar cards
struct AzkarCard: View {
    @EnvironmentObject var theme: ThemeManager

    let title: String
    let iconName: String
    var isCompleted: Bool = false
    var isEditing: Bool = false
    var isSelectedForEditing: Bool = false
    var onToggleSelection: (() -> Void)? = nil
    let backgroundColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.system(size: 40))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(theme.currentTheme.buttonText)
                
                if !isEditing {
                    Text(isCompleted ? "Completed" : "Not completed yet")
                        .font(.subheadline)
                        .foregroundColor(theme.currentTheme.buttonText.opacity(0.7))
                }
            }
            
            Spacer()
            
            if isEditing {
                Button(action: {
                    onToggleSelection?()
                }) {
                    Image(systemName: isSelectedForEditing ? "checkmark.square.fill" : "square")
                        .foregroundColor(theme.currentTheme.primary)
                        .font(.system(size: 24))
                }
                .buttonStyle(PlainButtonStyle())
            } else if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(theme.currentTheme.primary)
            }
        }
        .padding()
        .background(
            Rectangle()
                .fill(backgroundColor)
                .shadow(color: .black.opacity(0.3), radius: 0, x: 4, y: 4)
        )
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// Simple error view
struct ErrorView: View {
    @EnvironmentObject var theme: ThemeManager
    let error: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(theme.currentTheme.primary)
            
            Text("Error")
                .font(.title)
                .fontWeight(.bold)
            
            Text(error)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }
}

#Preview {
    SunnahTabView()
}
