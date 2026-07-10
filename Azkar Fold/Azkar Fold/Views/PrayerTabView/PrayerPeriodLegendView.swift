//
//  PrayerPeriodLegendView.swift
//  Azkar Fold
//

import SwiftUI

struct PrayerPeriodLegendView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var appLanguage: AppLanguageManager
    let activePeriod: PrayerPeriod

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(PrayerPeriod.allCases.enumerated()), id: \.element.id) { index, period in
                periodRow(period)
                if index < PrayerPeriod.allCases.count - 1 {
                    Divider()
                        .background(theme.currentTheme.text.opacity(0.12))
                        .padding(.leading, 52)
                }
            }
        }
        .padding(.vertical, 6)
        .background(theme.currentTheme.cardBackground.opacity(0.92))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(theme.currentTheme.text.opacity(0.06), lineWidth: 1)
        )
    }

    private func periodRow(_ period: PrayerPeriod) -> some View {
        let isActive = period == activePeriod
        let tint = period.semanticColor.opacity(isActive ? 1 : 0.75)

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(tint.opacity(isActive ? 0.22 : 0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: period.systemImage)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isActive ? tint : theme.currentTheme.text.opacity(0.45))
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(appLanguage.text(period.nameKey))
                        .font(.subheadline.weight(isActive ? .semibold : .regular))
                        .foregroundColor(
                            isActive
                                ? theme.currentTheme.text
                                : theme.currentTheme.text.opacity(0.7)
                        )

                    if !period.isFard {
                        Text(appLanguage.text("prayer.period.between"))
                            .font(.caption2.weight(.medium))
                            .foregroundColor(theme.currentTheme.text.opacity(0.45))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(theme.currentTheme.text.opacity(0.06))
                            .cornerRadius(6)
                    }
                }

                Text("\(formatTime(period.startTimeString)) – \(formatTime(period.endTimeString))")
                    .font(.caption)
                    .foregroundColor(theme.currentTheme.text.opacity(0.45))
                    .monospacedDigit()
            }

            Spacer(minLength: 8)

            Text(formatTime(period.startTimeString))
                .font(.subheadline.weight(isActive ? .bold : .medium))
                .foregroundColor(
                    isActive
                        ? theme.currentTheme.primary
                        : theme.currentTheme.text.opacity(0.55)
                )
                .monospacedDigit()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            isActive
                ? theme.currentTheme.primary.opacity(0.08)
                : Color.clear
        )
    }

    private func formatTime(_ hhmm: String) -> String {
        let parts = hhmm.split(separator: ":")
        guard parts.count == 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]) else {
            return hhmm
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = MakkahPrayerTimesSnapshot.timeZone
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        guard let date = calendar.date(from: components) else { return hhmm }
        return date.formatted(
            Date.FormatStyle(date: .omitted, time: .shortened)
                .locale(appLanguage.locale)
        )
    }
}
