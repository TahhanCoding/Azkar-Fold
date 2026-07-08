//
//  LegalDocumentSheet.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 07/07/2026.
//

import SwiftUI

struct LegalDocumentSection: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

struct LegalDocumentSheet: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var appLanguage: AppLanguageManager
    @Environment(\.dismiss) private var dismiss

    let documentKind: LegalDocumentKind

    private var title: String {
        switch documentKind {
        case .privacy:
            return appLanguage.text("legal.privacy_title")
        case .terms:
            return appLanguage.text("legal.terms_title")
        }
    }

    private var lastUpdated: String {
        LegalDocuments.lastUpdated(language: appLanguage.current)
    }

    private var sections: [LegalDocumentSection] {
        switch documentKind {
        case .privacy:
            return LegalDocuments.privacyPolicySections(language: appLanguage.current)
        case .terms:
            return LegalDocuments.termsOfServiceSections(language: appLanguage.current)
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(appLanguage.text("legal.last_updated", lastUpdated))
                        .font(.caption)
                        .foregroundColor(theme.currentTheme.text.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ForEach(sections) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(section.title)
                                .font(.headline)
                                .foregroundColor(theme.currentTheme.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)

                            Text(section.body)
                                .font(.body)
                                .foregroundColor(theme.currentTheme.text.opacity(0.85))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(theme.currentTheme.background.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(appLanguage.text("common.done")) {
                        dismiss()
                    }
                    .foregroundStyle(theme.currentTheme.accent)
                }
            }
        }
        .environment(\.locale, appLanguage.locale)
        .environment(\.layoutDirection, appLanguage.layoutDirection)
        .id(appLanguage.current)
    }
}

enum LegalDocumentKind {
    case privacy
    case terms
}

enum LegalDocuments {
    static func lastUpdated(language: AppLanguage) -> String {
        switch language {
        case .english:
            return englishLastUpdated()
        case .arabic:
            return arabicLastUpdated()
        }
    }

    static func privacyPolicySections(language: AppLanguage) -> [LegalDocumentSection] {
        switch language {
        case .english:
            return englishPrivacyPolicySections
        case .arabic:
            return arabicPrivacyPolicySections
        }
    }

    static func termsOfServiceSections(language: AppLanguage) -> [LegalDocumentSection] {
        switch language {
        case .english:
            return englishTermsOfServiceSections
        case .arabic:
            return arabicTermsOfServiceSections
        }
    }
}

#Preview {
    LegalDocumentSheet(documentKind: .privacy)
        .environmentObject(ThemeManager.shared)
        .environmentObject(AppLanguageManager.shared)
}
