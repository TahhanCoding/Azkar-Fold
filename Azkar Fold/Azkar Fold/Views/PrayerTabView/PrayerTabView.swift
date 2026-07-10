//
//  PrayerTabView.swift
//  Azkar Fold
//

import SwiftUI

struct PrayerTabView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var appLanguage: AppLanguageManager

    var body: some View {
        VStack(spacing: 0) {
            headerView

            Spacer()

            Text(appLanguage.text("prayer.coming_soon"))
                .font(.body)
                .foregroundColor(theme.currentTheme.text.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundView())
    }

    private var headerView: some View {
        HStack {
            Text(appLanguage.text("tab.prayer"))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(theme.currentTheme.primary)

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

#Preview {
    PrayerTabView()
        .environmentObject(ThemeManager.shared)
        .environmentObject(AppLanguageManager.shared)
}
