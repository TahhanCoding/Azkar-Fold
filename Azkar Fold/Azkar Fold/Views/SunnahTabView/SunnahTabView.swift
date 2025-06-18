//
//  SunnahTabView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 02/05/2025.
//

import SwiftUI

struct SunnahTabView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    private let azkarService = SunnahAzkarService()
    @EnvironmentObject private var progressStore: SunnahProgressStore // Changed to EnvironmentObject
    @State private var isEditing = false
    // Temporary set to store selections in edit mode before saving
    @State private var temporarySelectedCategories: Set<SunnahAzkarCategory> = []
    
    @State private var morningAzkarCount: Int = 0
    @State private var eveningAzkarCount: Int = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Text("Daily Sunnah Azkar")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 16) {
                        if isEditing {
                            ForEach(SunnahAzkarCategory.allCases) { category in
                                AzkarCard(
                                    title: category.title,
                                    iconName: category.iconName,
                                    isEditing: true,
                                    isSelectedForEditing: Binding(
                                        get: { temporarySelectedCategories.contains(category) },
                                        set: { isSelected in
                                            if isSelected {
                                                temporarySelectedCategories.insert(category)
                                            } else {
                                                temporarySelectedCategories.remove(category)
                                            }
                                        }
                                    ),
                                    backgroundColor: category.color
                                )
                                .onTapGesture {
                                    // This gesture ensures the binding is updated if the user taps the whole card
                                    if temporarySelectedCategories.contains(category) {
                                        temporarySelectedCategories.remove(category)
                                    } else {
                                        temporarySelectedCategories.insert(category)
                                    }
                                }
                            }
                        } else {
                            if progressStore.selectedSunnahCategories.isEmpty {
                                Text("No Sunnah categories selected. Tap 'Edit' to choose categories.")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                ForEach(SunnahAzkarCategory.allCases.filter { progressStore.selectedSunnahCategories.contains($0) }) { category in
                                    NavigationLink(destination: {
                                        loadSunnahZekrView(for: category)
                                    }) {
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
                    .padding()
                }
                
                Spacer()
            }
            .background(
                Image("islamic_pattern")
                    .resizable(resizingMode: .tile)
                    .opacity(0.55)
                    .ignoresSafeArea(.all)
            )
            .background(
                Color.themeBackground.opacity(0.3).ignoresSafeArea(.all)
            )
            .onAppear {
                progressStore.resetDailyProgressIfNeeded()
                progressStore.loadSelectedCategories()
                temporarySelectedCategories = progressStore.selectedSunnahCategories
                
                // Cache the azkar counts
                loadAzkarCounts()
            }
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if isEditing {
                            // Save was tapped
                            progressStore.selectedSunnahCategories = temporarySelectedCategories
                            progressStore.saveSelectedCategories()
                        } else {
                            // Edit was tapped, initialize temporary selections
                            temporarySelectedCategories = progressStore.selectedSunnahCategories
                        }
                        isEditing.toggle()
                    }) {
                        Text(isEditing ? "Save" : "Edit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.themePrimary)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .navigationViewStyle(.stack) // Added to potentially fix toolbar item visibility
        .environmentObject(progressStore)
    }
    
    private func loadSunnahZekrView(for category: SunnahAzkarCategory) -> some View {
        let result = azkarService.loadAzkar(for: category)
        switch result {
        case .success(let azkarList):
            return AnyView(SunnahZekrView(
                azkarList: azkarList,
                category: category,
                progressStore: progressStore
            ))
        case .failure(let error):
            return AnyView(ErrorView(error: "Failed to load \(category.rawValue): \(error.localizedDescription)"))
        }
    }
    

    private func loadAzkarCounts() {
        // Load morning azkar count
        let morningResult = azkarService.loadAzkar(for: .morning)
        if case .success(let morningList) = morningResult {
            morningAzkarCount = morningList.count
        }
        
        // Load evening azkar count
        let eveningResult = azkarService.loadAzkar(for: .evening)
        if case .success(let eveningList) = eveningResult {
            eveningAzkarCount = eveningList.count
        }
    }
    
    private func isCategoryCompleted(for category: SunnahAzkarCategory) -> Bool {
        let totalCount: Int
        switch category {
        case .morning:
            totalCount = morningAzkarCount
        case .evening:
            totalCount = eveningAzkarCount
        }
        
        return progressStore.isCategoryFullyCompleted(category: category, totalAzkarCount: totalCount)
    }
    
    
}


// Helper view for Azkar cards
struct AzkarCard: View {
    let title: String
    let iconName: String
    var isCompleted: Bool = false // Default value
    var isEditing: Bool = false
    @Binding var isSelectedForEditing: Bool
    let backgroundColor: Color

    // Initializer for normal display mode
    init(title: String, iconName: String, isCompleted: Bool, backgroundColor: Color) {
        self.title = title
        self.iconName = iconName
        self.isCompleted = isCompleted
        self.backgroundColor = backgroundColor
        self.isEditing = false
        self._isSelectedForEditing = .constant(false) // Dummy binding for non-editing mode
    }

    // Initializer for editing mode
    init(title: String, iconName: String, isEditing: Bool, isSelectedForEditing: Binding<Bool>, backgroundColor: Color) {
        self.title = title
        self.iconName = iconName
        self.isCompleted = false // Not used in editing mode
        self.isEditing = isEditing
        self._isSelectedForEditing = isSelectedForEditing
        self.backgroundColor = backgroundColor
    }
    
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
                    .foregroundColor(.white)
                
                Text(isCompleted ? "Completed" : "Not completed yet")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            if isEditing {
                Image(systemName: isSelectedForEditing ? "checkmark.square.fill" : "square")
                    .foregroundColor(.white)
                    .font(.system(size: 24))
            } else if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
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
    let error: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
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
