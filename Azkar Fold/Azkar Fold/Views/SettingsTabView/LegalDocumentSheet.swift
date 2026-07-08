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
    @Environment(\.dismiss) private var dismiss

    let title: String
    let lastUpdated: String
    let sections: [LegalDocumentSection]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Last updated: \(lastUpdated)")
                        .font(.caption)
                        .foregroundColor(theme.currentTheme.text.opacity(0.6))

                    ForEach(sections) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(section.title)
                                .font(.headline)
                                .foregroundColor(theme.currentTheme.text)

                            Text(section.body)
                                .font(.body)
                                .foregroundColor(theme.currentTheme.text.opacity(0.85))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(20)
            }
            .background(theme.currentTheme.background.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(theme.currentTheme.accent)
                }
            }
        }
    }
}

enum LegalDocuments {
    static let lastUpdated = "July 7, 2026"

    static let privacyPolicySections: [LegalDocumentSection] = [
        LegalDocumentSection(
            title: "Introduction",
            body: """
            Azkar Fold helps you remember Allah through personal azkar and curated Sunnah remembrances. This Privacy Policy explains how Azkar Fold handles information when you use the app.
            """
        ),
        LegalDocumentSection(
            title: "Information We Collect",
            body: """
            Azkar Fold is designed to work primarily on your device.

            • Azkar you create, counters, progress, theme choices, and related preferences are stored locally on your device.
            • We do not require you to create an account to use the app.
            • The app may check for available updates using Firebase Remote Config. These requests can include standard technical information such as app version and general device or network details needed to deliver update information.
            """
        ),
        LegalDocumentSection(
            title: "How We Use Information",
            body: """
            Locally stored information is used only to provide app features, including saving your azkar, tracking progress, applying themes, and restoring your preferences.

            Update-related requests are used only to determine whether a newer version of the app is available and to present update messaging when appropriate.
            """
        ),
        LegalDocumentSection(
            title: "Sharing of Information",
            body: """
            We do not sell your personal information.

            Information you enter in Azkar Fold remains on your device unless you choose to share it yourself through system sharing features, such as exporting or sharing an image.
            """
        ),
        LegalDocumentSection(
            title: "Data Retention",
            body: """
            Your azkar, settings, and progress remain on your device until you delete them in the app or remove the app from your device.
            """
        ),
        LegalDocumentSection(
            title: "Children's Privacy",
            body: """
            Azkar Fold does not knowingly collect personal information from children. If you believe information has been provided by a child, please use Contact Support in Settings so we can help address the request.
            """
        ),
        LegalDocumentSection(
            title: "Your Choices",
            body: """
            You can review, edit, or delete your custom azkar within the app. You can also change app preferences at any time in Settings.

            You may stop all collection associated with update checks by disabling network access for the app through your device settings, though this may prevent update notifications from appearing.
            """
        ),
        LegalDocumentSection(
            title: "Changes to This Policy",
            body: """
            We may update this Privacy Policy from time to time. When we do, we will update the \"Last updated\" date shown in the app.
            """
        )
    ]

    static let termsOfServiceSections: [LegalDocumentSection] = [
        LegalDocumentSection(
            title: "Agreement",
            body: """
            By downloading or using Azkar Fold, you agree to these Terms of Service. If you do not agree, please do not use the app.
            """
        ),
        LegalDocumentSection(
            title: "Use of the App",
            body: """
            Azkar Fold is provided for personal Islamic remembrance and spiritual benefit. You agree to use the app lawfully and respectfully.

            You are responsible for the azkar and content you create, store, or share using the app.
            """
        ),
        LegalDocumentSection(
            title: "Content and Accuracy",
            body: """
            Sunnah azkar and related content are provided for convenience and educational use. While we aim to present content carefully, Azkar Fold does not guarantee that all material is complete, error-free, or suitable for every scholarly context.

            You should verify important religious matters with qualified sources when needed.
            """
        ),
        LegalDocumentSection(
            title: "Intellectual Property",
            body: """
            The app, its design, branding, and original materials are owned by Azkar Fold and its licensors. You may not copy, modify, distribute, or reverse engineer the app except as permitted by law.
            """
        ),
        LegalDocumentSection(
            title: "User Content",
            body: """
            You retain ownership of the azkar and content you create in the app. By using sharing features, you control what content leaves your device.

            You agree not to use the app to create, store, or share unlawful, harmful, or abusive content.
            """
        ),
        LegalDocumentSection(
            title: "Disclaimer",
            body: """
            Azkar Fold is provided on an \"as is\" and \"as available\" basis without warranties of any kind, whether express or implied, including fitness for a particular purpose, reliability, or uninterrupted availability.
            """
        ),
        LegalDocumentSection(
            title: "Limitation of Liability",
            body: """
            To the fullest extent permitted by law, Azkar Fold and its developers will not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of the app.
            """
        ),
        LegalDocumentSection(
            title: "Changes to the App and Terms",
            body: """
            We may update the app or these Terms from time to time. Continued use of Azkar Fold after changes become effective means you accept the revised Terms.
            """
        )
    ]
}

#Preview {
    LegalDocumentSheet(
        title: "Privacy Policy",
        lastUpdated: LegalDocuments.lastUpdated,
        sections: LegalDocuments.privacyPolicySections
    )
    .environmentObject(ThemeManager.shared)
}
