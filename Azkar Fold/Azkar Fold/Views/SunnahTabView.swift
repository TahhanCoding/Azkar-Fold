//
//  SunnahTabView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 02/05/2025.
//

import SwiftUI

struct SunnahTabView: View {
    private let azkarService = SunnahAzkarService()
    @StateObject private var progressStore = SunnahProgressStore()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Daily Sunnah Azkar")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.azkarPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Morning Azkar Card
                    NavigationLink(destination: {
                        loadSunnahZekrView(for: .morning)
                    }) {
                        AzkarCard(
                            title: "Morning Azkar",
                            iconName: "sun.max.fill",
                            isCompleted: isCategoryCompleted(for: .morning),
                            backgroundColor: .azkarPrimary
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Evening Azkar Card
                    NavigationLink(destination: {
                        loadSunnahZekrView(for: .evening)
                    }) {
                        AzkarCard(
                            title: "Evening Azkar",
                            iconName: "moon.stars.fill",
                            isCompleted: isCategoryCompleted(for: .evening),
                            backgroundColor: .azkarPrimary.opacity(0.8)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
            }
            .navigationTitle("Sunnah")
            .background(
                Image("islamic_pattern")
                    .resizable(resizingMode: .tile)
                    .opacity(0.05)
            )
            .onAppear {
                progressStore.resetDailyProgressIfNeeded()
            }
        }
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
    
    private func isCategoryCompleted(for category: SunnahAzkarCategory) -> Bool {
        switch category {
        case .morning:
            return !progressStore.morningAzkarCompleted.isEmpty && progressStore.morningAzkarCompleted.values.allSatisfy { $0 }
        case .evening:
            return !progressStore.eveningAzkarCompleted.isEmpty && progressStore.eveningAzkarCompleted.values.allSatisfy { $0 }
        }
    }
}

// Helper view for Azkar cards
struct AzkarCard: View {
    let title: String
    let iconName: String
    let isCompleted: Bool
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
                    .foregroundColor(.white)
                
                Text(isCompleted ? "Completed" : "Not completed yet")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(
            Rectangle()
                .fill(isCompleted ? backgroundColor.opacity(0.6) : backgroundColor)
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
