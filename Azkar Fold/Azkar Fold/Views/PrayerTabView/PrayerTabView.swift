//
//  PrayerTabView.swift
//  Azkar Fold
//

import SwiftUI

struct PrayerTabView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var appLanguage: AppLanguageManager
    @ObservedObject private var prayerSettings = PrayerSettingsStore.shared

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { context in
            let state = PrayerClockState(date: context.date, location: prayerSettings.location)

            ScrollView {
                VStack(spacing: 20) {
                    headerView(for: state)

                    PrayerClockView(state: state)
                        .padding(.top, 4)

                    PrayerPeriodLegendView(state: state)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundView())
    }

    private func headerView(for state: PrayerClockState) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(appLanguage.text("tab.prayer"))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(theme.currentTheme.primary)

            Text(state.subtitle(using: appLanguage))
                .font(.caption)
                .foregroundColor(theme.currentTheme.text.opacity(0.55))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

#Preview {
    PrayerTabView()
        .environmentObject(ThemeManager.shared)
        .environmentObject(AppLanguageManager.shared)
        .environmentObject(PatternManager.shared)
}
