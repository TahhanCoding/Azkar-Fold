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
    @State private var showingPrivacyPolicy = false
    @State private var showingTerms = false
    
    var body: some View {
        NavigationView {
            List {
                headerSection
                Section {
                    neoBrutalismButton(title: "Rate This App", icon: "star.fill") {
                        requestAppReview()
                    }
                    neoBrutalismButton(title: "Share With Friends", icon: "square.and.arrow.up") {
                        shareApp()
                    }
                }
                .listRowBackground(Color.clear)
                
                Section(header: Text("About This App")) {
                    descriptionSection(
                        title: "Azkar Fold is an Islamic app designed to help Muslims maintain their daily remembrances (Azkar). The app allows you to create and track your custom Azkar with a simple counter interface."
                    )
                }
                
                Section(header: Text("Legal")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Privacy Policy") {
                        showingPrivacyPolicy = true
                    }
                    
//                    Button("Terms of Service") {
//                        showingTerms = true
//                    }
                    
                    // Add contact section for App Store requirements
                    Button("Contact Support") {
                        sendEmail()
                    }
                }
            }
            .navigationTitle("Settings")
            .listStyle(InsetGroupedListStyle())
            .background(
                Image("islamic_pattern")
                    .resizable(resizingMode: .tile)
                    .opacity(0.55)
                    .ignoresSafeArea(.all)
            )
            .background(
                Color.appBackground.opacity(0.3).ignoresSafeArea(.all)
            )
            .sheet(isPresented: $showingPrivacyPolicy) {
                WebView(url: "https://yourapp.com/privacy")
            }
//            .sheet(isPresented: $showingTerms) {
//                WebView(url: "https://yourapp.com/terms")
//            }
        }
    }
    
    // MARK: - Actions
    private func requestAppReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private func shareApp() {
        let appURL = "https://apps.apple.com/app/azkar-fold/id[YOUR_APP_ID]" // Replace with actual App Store URL
        let activityVC = UIActivityViewController(activityItems: [appURL], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    private func sendEmail() {
        let email = "support@yourapp.com" // Replace with your email
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    // Your existing code remains the same...
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Azkar Fold")
                .font(.system(size: 28, weight: .black))
                .foregroundColor(.appPrimary)
            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                .font(.subheadline)
                .foregroundColor(.appAccent)
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowBackground(Color.clear)
    }
    
    private func descriptionSection(title: String) -> some View {
        Text(title)
            .font(.body)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 5)
    }
    
    private func neoBrutalismButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(.appClear)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(
                Rectangle()
                    .fill(Color.appPrimary)
                    .shadow(color: .black.opacity(0.3), radius: 0, x: 4, y: 4)
            )
            .cornerRadius(8)
        }
    }
}
