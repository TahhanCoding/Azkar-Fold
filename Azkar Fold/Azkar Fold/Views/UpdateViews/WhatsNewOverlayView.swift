//
//  WhatsNewOverlayView.swift
//  Azkar Fold
//
//  Created by Ahmed AlTahhan on 18/07/2026.
//  Copyright © 2026 Ahmed AlTahhan. All rights reserved.
//

import SwiftUI

struct WhatsNewOverlayView: View {
    let changes: [String]
    let onDismiss: () -> Void

    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var appLanguage: AppLanguageManager

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image("ShareAppIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: .black.opacity(0.12), radius: 8, y: 4)

                VStack(spacing: 8) {
                    Text(appLanguage.text("whats_new.title"))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(themeManager.currentTheme.text)
                        .multilineTextAlignment(.center)

                    Text(appLanguage.text("whats_new.subtitle", AppConfiguration.marketingVersion))
                        .font(.subheadline)
                        .foregroundStyle(themeManager.currentTheme.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(changes.enumerated()), id: \.offset) { _, change in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.body)
                                .foregroundStyle(themeManager.currentTheme.primary)
                            Text(change)
                                .font(.subheadline)
                                .foregroundStyle(themeManager.currentTheme.text.opacity(0.85))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)

                Button(action: onDismiss) {
                    Text(appLanguage.text("whats_new.continue"))
                        .font(.headline)
                        .foregroundStyle(themeManager.currentTheme.buttonText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(themeManager.currentTheme.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.top, 8)
            }
            .padding(24)
            .background(themeManager.currentTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(radius: 16)
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    WhatsNewOverlayView(
        changes: [
            "New Prayer Times tab with a daily prayer clock",
            "Show, hide, and rearrange tabs in Settings",
            "Prayer Clock widget for the Home Screen",
            "Share a zekr as an image with an App Store QR code"
        ],
        onDismiss: {}
    )
    .environmentObject(ThemeManager.shared)
    .environmentObject(AppLanguageManager.shared)
}
