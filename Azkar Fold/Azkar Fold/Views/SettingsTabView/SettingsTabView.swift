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
    @State private var showingPrivacyPolicy = false
    @State private var showingTerms = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                    .padding(.vertical, 20)
                
                Group {
                    sectionHeader("Preferences")
                    VStack(spacing: 0) {
                        sunnahSettingsNavigationLink
                        
                        Divider()
                            .background(.gray.opacity(0.3))
                            .padding(.horizontal, 32)

                        themeNavigationLink
                    }
                    .padding(.vertical, 12)
                }
                .padding(.horizontal, 14)
                
                sectionHeader("Actions")
                    .padding(.horizontal, 14)

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
                    .padding(.horizontal, 14)

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
    
    private var sunnahSettingsNavigationLink: some View {
        NavigationLink(destination: SunnahSettingsView()) {
            HStack(spacing: 12) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(theme.currentTheme.primary)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sunnah Zekr Manager")
                        .font(.headline)
                        .foregroundColor(theme.currentTheme.text)
                    
                    Text("Customize reading experience")
                        .font(.caption)
                        .foregroundColor(theme.currentTheme.text.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(theme.currentTheme.text.opacity(0.5))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(theme.currentTheme.background)
            .cornerRadius(12)
        }
    }
    
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
        let body = "Hi there,\n\nI need help with Azkar Fold.\n\nApp Version: \(appVersion)\n\nIssue Description:\n"
        
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SettingsTabView()
        .environmentObject(ThemeManager.shared)
}

