//
//  SettingsTabView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI
import StoreKit

struct SettingsTabView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var purchaseManager: PurchaseManager
    @State private var showingPrivacyPolicy = false
    @State private var showingTerms = false
    @State private var showingSubscriptionSheet = false
    @State private var isRestoringPurchases = false
    @State private var showingRestoreAlert = false
    @State private var restoreAlertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                    .padding(.vertical, 20)
                
                Group {
                    sectionHeader("Preferences")
                    themeNavigationLink
                        .padding(.vertical, 12)
                }
                .padding(.horizontal)
                
                // Subscription Management Section
                Group {
                    sectionHeader("Subscription")
                    subscriptionSection
                        .padding(.vertical, 12)
                }
                .padding(.horizontal)
                
                sectionHeader("Actions")
                    .padding(.horizontal)

                VStack {
                    actionButton(
                        title: "Rate This App",
                        icon: "star.fill",
                        action: requestAppReview
                    )
                    
                    Divider()
                        .background(.gray.opacity(0.3))
                        .padding(.horizontal, 32)

                    actionButton(
                        title: "Share With Friends",
                        icon: "square.and.arrow.up",
                        action: shareApp
                    )
                    
                    Divider()
                        .background(.gray.opacity(0.3))
                        .padding(.horizontal, 32)

                    actionButton(
                        title: "Contact Support",
                        icon: "envelope.fill",
                        action: sendEmail
                    )
                }
                .padding(.vertical, 12)
                .background(theme.currentTheme.background)
                .cornerRadius(12)
                .padding(.horizontal, 14)

                Divider()
                    .background(theme.currentTheme.secondary.opacity(0.2))
                
                sectionHeader("Legal")
                    .padding(.horizontal)

                VStack {
                    actionButton(
                        title: "Privacy Policy",
                        icon: "person.badge.shield.checkmark.fill",
                        action: { showingPrivacyPolicy = true }
                    )
                    
                    Divider()
                        .background(.gray.opacity(0.3))
                        .padding(.horizontal, 32)

                    actionButton(
                        title: "Terms of Service",
                        icon: "newspaper.fill",
                        action: { showingTerms = true }
                    )
                }
                .padding(.vertical, 12)
                .background(theme.currentTheme.background)
                .cornerRadius(12)
                .padding(.horizontal, 14)

            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Settings")
        .scrollContentBackground(.hidden)
        .background(BackgroundView())
        .sheet(isPresented: $showingPrivacyPolicy) {
            WebView(url: "https://www.azkarfold.com/privacy")
                .background(theme.currentTheme.background.ignoresSafeArea())
        }
        .sheet(isPresented: $showingTerms) {
            WebView(url: "https://yourapp.com/terms")
                .background(theme.currentTheme.background.ignoresSafeArea())
        }
        .sheet(isPresented: $showingSubscriptionSheet) {
            SubscriptionManagementView()
                .environmentObject(purchaseManager)
                .environmentObject(theme)
        }
        .alert("Restore Purchases", isPresented: $showingRestoreAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(restoreAlertMessage)
        }
    }
    
    // MARK: - Subscription Section
    
    private var subscriptionSection: some View {
        VStack(spacing: 0) {
            // Subscription Status
            subscriptionStatusRow
            
            Divider()
                .background(.gray.opacity(0.3))
                .padding(.horizontal, 32)
            
            // Manage Subscription Button
            manageSubscriptionButton
            
            Divider()
                .background(.gray.opacity(0.3))
                .padding(.horizontal, 32)
            
            // Restore Purchases Button
            restorePurchasesButton
        }
        .background(theme.currentTheme.background)
        .cornerRadius(12)
        .padding(.horizontal, 14)
    }
    
    private var subscriptionStatusRow: some View {
        HStack(spacing: 12) {
            Image(systemName: purchaseManager.isPremium ? "crown.fill" : "crown")
                .font(.headline)
                .foregroundColor(purchaseManager.isPremium ? .yellow : theme.currentTheme.primary)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Premium Status")
                    .font(.headline)
                    .foregroundColor(theme.currentTheme.text)
                
                HStack {
                    Text(subscriptionStatusText)
                        .font(.caption)
                        .foregroundColor(theme.currentTheme.text.opacity(0.7))
                    
                    if purchaseManager.isOffline {
                        Image(systemName: "wifi.slash")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            // Status indicator
            Circle()
                .fill(purchaseManager.isPremium ? Color.green : Color.gray.opacity(0.5))
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
    }
    
    private var manageSubscriptionButton: some View {
        Button(action: { showingSubscriptionSheet = true }) {
            HStack(spacing: 12) {
                Image(systemName: "gear")
                    .font(.headline)
                    .foregroundColor(theme.currentTheme.primary)
                    .frame(width: 24, height: 24)
                
                Text(purchaseManager.isPremium ? "Manage Subscription" : "Upgrade to Premium")
                    .font(.headline)
                    .foregroundColor(theme.currentTheme.text)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(theme.currentTheme.text.opacity(0.5))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var restorePurchasesButton: some View {
        Button(action: restorePurchases) {
            HStack(spacing: 12) {
                if isRestoringPurchases {
                    ProgressView()
                        .scaleEffect(0.8)
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "arrow.clockwise")
                        .font(.headline)
                        .foregroundColor(theme.currentTheme.primary)
                        .frame(width: 24, height: 24)
                }
                
                Text("Restore Purchases")
                    .font(.headline)
                    .foregroundColor(theme.currentTheme.text.opacity(isRestoringPurchases ? 0.5 : 1.0))
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isRestoringPurchases)
    }
    
    // MARK: - Computed Properties
    
    private var subscriptionStatusText: String {
        if purchaseManager.isPremium {
            return purchaseManager.isOffline ? "Premium (Cached)" : "Premium Active"
        } else {
            return "Free Version"
        }
    }
    
    // MARK: - Sections
    
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(theme.currentTheme.text.opacity(0.7))
                .padding(.vertical, 8)
            Spacer()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Azkar Fold")
                .font(.system(size: 28, weight: .black))
                .foregroundColor(theme.currentTheme.primary)
                        
            Text("Version \(appVersion)")
                .font(.caption)
                .foregroundColor(theme.currentTheme.text.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Subviews
    
    private var themeNavigationLink: some View {
        NavigationLink(destination: ThemeManagerView().environmentObject(ThemeManager.shared)) {
            HStack(spacing: 12) {
                Image(systemName: "paintbrush.fill")
                    .foregroundColor(theme.currentTheme.primary)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Theme Manager")
                        .font(.headline)
                        .foregroundColor(theme.currentTheme.text)
                    
                    Text("Customize app colors and themes")
                        .font(.caption)
                        .foregroundColor(theme.currentTheme.text.opacity(0.7))
                }
                
                Spacer()
                
                themePreviewCircle
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(theme.currentTheme.background)
            .cornerRadius(12)
        }
    }
    
    private var themePreviewCircle: some View {
        Circle()
            .fill(theme.currentTheme.primary)
            .frame(width: 20, height: 20)
            .overlay(
                Circle()
                    .stroke(theme.currentTheme.secondary, lineWidth: 1)
            )
    }
        
    private func actionButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(theme.currentTheme.primary)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(theme.currentTheme.text)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(theme.currentTheme.text.opacity(0.5))
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    // MARK: - Actions
    
    private func restorePurchases() {
        isRestoringPurchases = true
        
        Task {
            do {
                try await purchaseManager.restorePurchases()
                
                await MainActor.run {
                    isRestoringPurchases = false
                    restoreAlertMessage = purchaseManager.isPremium
                        ? "✅ Purchases restored successfully!"
                        : "No previous purchases found."
                    showingRestoreAlert = true
                }
            } catch {
                await MainActor.run {
                    isRestoringPurchases = false
                    restoreAlertMessage = "❌ Failed to restore purchases: \(error.localizedDescription)"
                    showingRestoreAlert = true
                }
            }
        }
    }
    
    private func requestAppReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private func shareApp() {
        let appURL = "https://apps.apple.com/app/azkar-fold/id[YOUR_APP_ID]"
        let shareText = "Check out Azkar Fold - Your Islamic Remembrance Companion!"
        let activityItems = [shareText, appURL]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            // For iPad support
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func sendEmail() {
        let email = "support@yourapp.com"
        let subject = "Azkar Fold Support Request"
        let body = "Hi there,\n\nI need help with Azkar Fold.\n\nApp Version: \(appVersion)\nPremium Status: \(purchaseManager.isPremium ? "Premium" : "Free")\n\nIssue Description:\n"
        
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Subscription Management Sheet

struct SubscriptionManagementView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Status Card
                    statusCard
                    
                    if purchaseManager.isPremium {
                        // Premium Features List
                        premiumFeaturesCard
                        
                        // Manage on App Store Button
                        manageOnAppStoreButton
                    } else {
                        // Available Plans
                        Text("Choose Your Plan")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(theme.currentTheme.text)
                        
                        // Show available products here
                        ForEach(purchaseManager.products, id: \.id) { product in
                            ProductRowView(product: product)
                                .environmentObject(purchaseManager)
                                .environmentObject(theme)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: purchaseManager.isPremium ? "crown.fill" : "crown")
                    .foregroundColor(purchaseManager.isPremium ? .yellow : theme.currentTheme.primary)
                    .font(.title2)
                
                VStack(alignment: .leading) {
                    Text(purchaseManager.isPremium ? "Premium Active" : "Free Version")
                        .font(.headline)
                        .foregroundColor(theme.currentTheme.text)
                    
                    if purchaseManager.isOffline {
                        Text("Status cached offline")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(theme.currentTheme.background)
        .cornerRadius(12)
    }
    
    private var premiumFeaturesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Premium Features")
                .font(.headline)
                .foregroundColor(theme.currentTheme.text)
            
            VStack(alignment: .leading, spacing: 8) {
                FeatureRow(icon: "infinity", text: "Unlimited Access")
                FeatureRow(icon: "paintbrush", text: "All Themes")
                FeatureRow(icon: "bell", text: "Custom Notifications")
                FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Advanced Analytics")
            }
        }
        .padding()
        .background(theme.currentTheme.background)
        .cornerRadius(12)
    }
    
    private var manageOnAppStoreButton: some View {
        Button(action: openAppStoreSubscriptions) {
            HStack {
                Image(systemName: "app.badge")
                    .foregroundColor(.white)
                Text("Manage in App Store")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(theme.currentTheme.primary)
            .cornerRadius(12)
        }
    }
    
    private func openAppStoreSubscriptions() {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(theme.currentTheme.primary)
                .frame(width: 20)
            
            Text(text)
                .foregroundColor(theme.currentTheme.text)
            
            Spacer()
        }
    }
}

struct ProductRowView: View {
    let product: Product
    @EnvironmentObject var purchaseManager: PurchaseManager
    @EnvironmentObject var theme: ThemeManager
    
    var body: some View {
        Button(action: purchaseProduct) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                        .foregroundColor(theme.currentTheme.text)
                    
                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(theme.currentTheme.text.opacity(0.7))
                }
                
                Spacer()
                
                Text(product.displayPrice)
                    .font(.headline)
                    .foregroundColor(theme.currentTheme.primary)
            }
            .padding()
            .background(theme.currentTheme.background)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.currentTheme.primary.opacity(0.2), lineWidth: 1)
            )
        }
        .disabled(purchaseManager.isProcessingPurchase)
    }
    
    private func purchaseProduct() {
        Task {
            do {
                try await purchaseManager.purchase(product)
            } catch {
                print("Purchase failed: \(error)")
            }
        }
    }
}

#Preview {
    SettingsTabView()
        .environmentObject(ThemeManager.shared)
        .environmentObject(PurchaseManager())
}

