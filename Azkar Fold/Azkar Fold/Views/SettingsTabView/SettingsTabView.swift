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
    @EnvironmentObject var appLanguage: AppLanguageManager
    @State private var showingPrivacyPolicy = false
    @State private var showingTerms = false
    @State private var showingSupportSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                    .padding(.vertical, 20)
                
                sectionHeader("settings.preferences")
                    .padding(.horizontal, 14)

                VStack(spacing: 0) {
                    languagePickerRow

                    Divider()
                        .background(.gray.opacity(0.3))
                        .padding(.horizontal, 32)

                    sunnahSettingsNavigationLink
                        
                    Divider()
                        .background(.gray.opacity(0.3))
                        .padding(.horizontal, 32)

                    tabSettingsNavigationLink

                    Divider()
                        .background(.gray.opacity(0.3))
                        .padding(.horizontal, 32)
                        
                    themeNavigationLink
                }
                .padding(.vertical, 12)
                .background(theme.currentTheme.background)
                .cornerRadius(12)
                .padding(.horizontal, 14)
                
                sectionHeader("settings.actions")
                    .padding(.horizontal, 14)

                VStack {
                    actionButton(
                        titleKey: "settings.rate",
                        icon: "star.fill",
                        action: requestAppReview
                    )
                    
                    Divider()
                        .background(.gray.opacity(0.3))
                        .padding(.horizontal, 32)

                    actionButton(
                        titleKey: "settings.share_friends",
                        icon: "square.and.arrow.up",
                        action: shareApp
                    )
                    
                    Divider()
                        .background(.gray.opacity(0.3))
                        .padding(.horizontal, 32)

                    actionButton(
                        titleKey: "settings.contact_support",
                        icon: "envelope.fill",
                        action: { showingSupportSheet = true }
                    )
                }
                .padding(.vertical, 12)
                .background(theme.currentTheme.background)
                .cornerRadius(12)
                .padding(.horizontal, 14)

                Divider()
                    .background(theme.currentTheme.secondary.opacity(0.2))
                
                sectionHeader("settings.legal")
                    .padding(.horizontal, 14)

                VStack {
                    actionButton(
                        titleKey: "settings.privacy",
                        icon: "person.badge.shield.checkmark.fill",
                        action: { showingPrivacyPolicy = true }
                    )
                    
                    Divider()
                        .background(.gray.opacity(0.3))
                        .padding(.horizontal, 32)

                    actionButton(
                        titleKey: "settings.terms",
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
        .navigationTitle(appLanguage.text("settings.title"))
        .scrollContentBackground(.hidden)
        .background(BackgroundView())
        .sheet(isPresented: $showingPrivacyPolicy) {
            LegalDocumentSheet(documentKind: .privacy)
                .environmentObject(theme)
                .environmentObject(appLanguage)
                .environment(\.locale, appLanguage.locale)
                .environment(\.layoutDirection, appLanguage.layoutDirection)
        }
        .sheet(isPresented: $showingTerms) {
            LegalDocumentSheet(documentKind: .terms)
                .environmentObject(theme)
                .environmentObject(appLanguage)
                .environment(\.locale, appLanguage.locale)
                .environment(\.layoutDirection, appLanguage.layoutDirection)
        }
        .sheet(isPresented: $showingSupportSheet) {
            SupportContactSheet()
                .environmentObject(theme)
                .environmentObject(appLanguage)
        }
    }
    
    private func sectionHeader(_ titleKey: String.LocalizationValue) -> some View {
        HStack {
            Text(appLanguage.text(titleKey))
                .font(.subheadline)
                .foregroundColor(theme.currentTheme.text.opacity(0.7))
                .padding(.vertical, 8)
            Spacer()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(appLanguage.text("app.name"))
                .azkarContentFont(size: AzkarFont.settingsHeaderSize)
                .foregroundColor(theme.currentTheme.primary)
                .multilineTextAlignment(.center)
                .environment(\.layoutDirection, appLanguage.layoutDirection)

            Text(appLanguage.text("settings.developer_dua"))
                .azkarContentFont(size: AzkarFont.settingsDuaSize)
                .foregroundColor(theme.currentTheme.primary.opacity(0.85))
                .multilineTextAlignment(.center)
                .environment(\.layoutDirection, appLanguage.layoutDirection)

            Text(appLanguage.text("app.version", appVersion))
                .font(.caption)
                .foregroundColor(theme.currentTheme.text.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }

    private var languagePickerRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "globe")
                .foregroundColor(theme.currentTheme.primary)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(appLanguage.text("settings.language"))
                    .font(.headline)
                    .foregroundColor(theme.currentTheme.text)

                Text(appLanguage.text("settings.language.subtitle"))
                    .font(.caption)
                    .foregroundColor(theme.currentTheme.text.opacity(0.7))
            }

            Spacer()

            Picker("", selection: Binding(
                get: { appLanguage.current },
                set: { appLanguage.setLanguage($0) }
            )) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.displayName(using: appLanguage)).tag(language)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .tint(theme.currentTheme.primary)
            .accessibilityLabel(appLanguage.text("settings.language"))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
    }
    
    private var sunnahSettingsNavigationLink: some View {
        NavigationLink(destination: SunnahSettingsView()) {
            HStack(spacing: 12) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(theme.currentTheme.primary)
                    .frame(width: 24, height: 24)
                    
                VStack(alignment: .leading, spacing: 2) {
                    Text(appLanguage.text("settings.sunnah_manager"))
                        .font(.headline)
                        .foregroundColor(theme.currentTheme.text)

                    Text(appLanguage.text("settings.sunnah_manager.subtitle"))
                        .font(.caption)
                        .foregroundColor(theme.currentTheme.text.opacity(0.7))
                }
                    
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
        }
    }

    private var tabSettingsNavigationLink: some View {
        NavigationLink(destination: TabSettingsView()) {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.split.3x1")
                    .foregroundColor(theme.currentTheme.primary)
                    .frame(width: 24, height: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(appLanguage.text("settings.tabs"))
                        .font(.headline)
                        .foregroundColor(theme.currentTheme.text)

                    Text(appLanguage.text("settings.tabs.subtitle"))
                        .font(.caption)
                        .foregroundColor(theme.currentTheme.text.opacity(0.7))
                }

                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
        }
    }
            
    private var themeNavigationLink: some View {
        NavigationLink(destination: ThemeManagerView().environmentObject(ThemeManager.shared)) {
            HStack(spacing: 12) {
                Image(systemName: "paintbrush.fill")
                    .foregroundColor(theme.currentTheme.primary)
                    .frame(width: 24, height: 24)
                    
                VStack(alignment: .leading, spacing: 2) {
                    Text(appLanguage.text("settings.theme_manager"))
                        .font(.headline)
                        .foregroundColor(theme.currentTheme.text)

                    Text(appLanguage.text("settings.theme_manager.subtitle"))
                        .font(.caption)
                        .foregroundColor(theme.currentTheme.text.opacity(0.7))
                }
                    
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
        }
    }
    
    private func actionButton(titleKey: String.LocalizationValue, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(theme.currentTheme.primary)
                    .frame(width: 24, height: 24)
                
                Text(appLanguage.text(titleKey))
                    .font(.headline)
                    .foregroundColor(theme.currentTheme.text)
                
                Spacer()
                
                Image(systemName: NavigationSymbol.forwardChevron)
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
        AppConfiguration.marketingVersion
    }
    
    private func requestAppReview() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    private func shareApp() {
        var activityItems: [Any] = [AppConfiguration.shareMessage]
        if let appURL = AppConfiguration.appStoreURL {
            activityItems.append(appURL)
        }

        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

#Preview {
    SettingsTabView()
        .environmentObject(ThemeManager.shared)
        .environmentObject(AppLanguageManager.shared)
}
