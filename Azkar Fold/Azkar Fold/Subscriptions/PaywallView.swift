//
//  PaywallView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 29/07/2025.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    
    /// Dismiss handler
    var onDismiss: () -> Void
    
    /// Grid layout for plans
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    header
                    features
                    plansGrid
                    footer
                }
                .padding(.horizontal, 20)
            }
            .background(
                BackgroundView()
            )
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Header
    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 56))
                .foregroundColor(theme.currentTheme.accent)
                .padding(.bottom, 8)
            
            Text("Go Premium")
                .font(.largeTitle.bold())
                .foregroundColor(theme.currentTheme.text)
            
            Text("Unlock the full power of AzkarFold")
                .font(.title3.weight(.medium))
                .foregroundColor(theme.currentTheme.text.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 32)
    }
    
    // MARK: - Features
    private var features: some View {
        VStack(spacing: 16) {
            ForEach(PremiumFeature.allCases, id: \.self) { feature in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: feature.icon)
                        .font(.title2.weight(.semibold))
                        .foregroundColor(theme.currentTheme.accent)
                        .frame(width: 28)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .font(.headline)
                            .foregroundColor(theme.currentTheme.text)
                        
                        Text(feature.subtitle)
                            .font(.subheadline)
                            .foregroundColor(theme.currentTheme.text.opacity(0.6))
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
            }
        }
        .padding(.vertical, 32)
    }
    
    // MARK: - Plans Grid
    private var plansGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(purchaseManager.products) { product in
                planCard(for: product)
            }
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Plan Card
    private func planCard(for product: Product) -> some View {
        let isPopular = product.id.contains("yearly")
        
        return VStack(spacing: 0) {
            if isPopular {
                Text("Most Popular")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(theme.currentTheme.accent)
                    )
                    .offset(y: 12)
                    .zIndex(1)
            }
            
            VStack(spacing: 16) {
                Text(product.displayName)
                    .font(.title3.bold())
                    .foregroundColor(theme.currentTheme.text)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(product.displayPrice)
                        .font(.largeTitle.bold())
                        .foregroundColor(theme.currentTheme.accent)
                    
                    Text(product.durationDescription)
                        .font(.body.weight(.medium))
                        .foregroundColor(theme.currentTheme.text.opacity(0.6))
                }
                
                Button(action: { purchase(product) }) {
                    HStack {
                        if purchaseManager.isProcessingPurchase {
                            ProgressView()
                        } else {
                            Text("Continue")
                                .font(.headline.weight(.semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(theme.currentTheme.primary)
                    )
                }
                .disabled(purchaseManager.isProcessingPurchase)
            }
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(theme.currentTheme.cardBackground)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(theme.currentTheme.accent, lineWidth: isPopular ? 2 : 0)
                }
            )
            .scaleEffect(isPopular ? 1.05 : 1)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isPopular)
        }
    }
    
    // MARK: - Footer
    private var footer: some View {
        VStack(spacing: 12) {
            Button("Restore Purchases") {
                Task {
                    do {
                        try await purchaseManager.restorePurchases()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            .font(.body.weight(.medium))
            .foregroundColor(theme.currentTheme.accent)
            
            Text("No commitment, cancel anytime")
                .font(.caption)
                .foregroundColor(theme.currentTheme.text.opacity(0.5))
            
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(theme.currentTheme.text.opacity(0.4))
            }
            .padding(.top, 12)
        }
        .padding(.top, 12)
        .padding(.bottom, 32)
    }
    
    // MARK: - Purchase
    private func purchase(_ product: Product) {
        Task {
            do {
                try await purchaseManager.purchase(product)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - Premium Features
enum PremiumFeature: CaseIterable {
    case customAzkar
    case sunnahAzkar
    case fullInfo
    case themes
    
    var icon: String {
        switch self {
        case .customAzkar: return "note.text.badge.plus"
        case .sunnahAzkar: return "sun.max.fill"
        case .fullInfo: return "text.bubble.fill"
        case .themes: return "paintbrush.fill"
        }
    }
    
    var title: String {
        switch self {
        case .customAzkar: return "Unlimited Custom Azkar"
        case .sunnahAzkar: return "Full Sunnah Azkar Library"
        case .fullInfo: return "Complete Zekr Details"
        case .themes: return "All Themes Unlocked"
        }
    }
    
    var subtitle: String {
        switch self {
        case .customAzkar: return "Create & manage as many personal azkar as you need"
        case .sunnahAzkar: return "Access every sunnah supplication beyond morning & evening"
        case .fullInfo: return "Arabic, transliteration, translation, sources & more"
        case .themes: return "Choose from all premium color schemes & patterns"
        }
    }
}

struct xPaywallView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    
    var body: some View {
        VStack {
            ForEach(purchaseManager.products) { product in
                Button(action: { purchase(product) }) {
                    VStack {
                        Text(product.displayName)
                        Text(product.displayPrice)
                        Text(product.durationDescription)
                            .font(.caption)
                    }
                }
            }
            
            if purchaseManager.isProcessingPurchase {
                ProgressView()
            }
            
            Button("Restore Purchases") {
                Task {
                    do {
                        try await purchaseManager.restorePurchases()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func purchase(_ product: Product) {
        Task {
            do {
                try await purchaseManager.purchase(product)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
