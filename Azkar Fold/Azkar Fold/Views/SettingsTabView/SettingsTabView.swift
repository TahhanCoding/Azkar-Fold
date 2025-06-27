//
//  SettingsTabView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI
import StoreKit
import WebKit

struct WebView: UIViewRepresentable {
    let url: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        if let url = URL(string: url) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct SettingsTabView: View {
    @EnvironmentObject var theme: ThemeManager
    @State private var showingPrivacyPolicy = false
    @State private var showingTerms = false
    
    var body: some View {
        List {
            headerSection
            preferencesSection
            actionsSection
            aboutSection
            legalSection
        }
        .navigationTitle("Settings")
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(backgroundView)
        .sheet(isPresented: $showingPrivacyPolicy) {
            WebView(url: "https://yourapp.com/privacy")
                .background(theme.currentTheme.background.ignoresSafeArea())
        }
        .sheet(isPresented: $showingTerms) {
            WebView(url: "https://yourapp.com/terms")
                .background(theme.currentTheme.background.ignoresSafeArea())
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text("Azkar Fold")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(theme.currentTheme.primary)
                
                Text("Your Islamic Remembrance Companion")
                    .font(.subheadline)
                    .foregroundColor(theme.currentTheme.text.opacity(0.8))
                
                Text("Version \(appVersion)")
                    .font(.caption)
                    .foregroundColor(theme.currentTheme.text.opacity(0.6))
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .listRowBackground(theme.currentTheme.background)
    }
    
    private var preferencesSection: some View {
        Section("Preferences") {
            themeNavigationLink
        }
        .listRowBackground(theme.currentTheme.background)
    }
    
    private var actionsSection: some View {
        Section("Actions") {
            actionButton(
                title: "Rate This App",
                icon: "star.fill",
                action: requestAppReview
            )
            
            actionButton(
                title: "Share With Friends",
                icon: "square.and.arrow.up",
                action: shareApp
            )
            
            actionButton(
                title: "Contact Support",
                icon: "envelope.fill",
                action: sendEmail
            )
        }
        .listRowBackground(theme.currentTheme.background)
    }
    
    private var aboutSection: some View {
        Section("About This App") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Azkar Fold is an Islamic app designed to help Muslims maintain their daily remembrances (Azkar).")
                    .font(.body)
                    .foregroundColor(theme.currentTheme.text)
                
                Text("The app allows you to create and track your custom Azkar with a simple counter interface, helping you stay connected to your faith throughout the day.")
                    .font(.body)
                    .foregroundColor(theme.currentTheme.text.opacity(0.8))
            }
            .padding(.vertical, 4)
            .fixedSize(horizontal: false, vertical: true)
        }
        .listRowBackground(theme.currentTheme.background)
    }
    
    private var legalSection: some View {
        Section("Legal") {
            Button("Privacy Policy") {
                showingPrivacyPolicy = true
            }
            .foregroundColor(theme.currentTheme.text)
            
            Button("Terms of Service") {
                showingTerms = true
            }
            .foregroundColor(theme.currentTheme.text)
        }
        .listRowBackground(theme.currentTheme.background)
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
            .padding(.vertical, 4)
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
    
    private var backgroundView: some View {
        ZStack {
            theme.currentTheme.background.opacity(0.5).ignoresSafeArea()
            
            Image("islamic_pattern")
                .resizable(resizingMode: .tile)
                .opacity(0.55)
                .ignoresSafeArea(.all)
        }
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
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Computed Properties
    
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

