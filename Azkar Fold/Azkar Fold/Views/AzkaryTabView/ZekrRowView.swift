//
//  ZekrRowView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct ZekrRowView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var appLanguage: AppLanguageManager
    let zekr: Zekr
    let onDelete: () -> Void
    let onTap: () -> Void

    @State private var offset: CGFloat = 0
    @State private var deleteButtonWidth: CGFloat = 75
    @State private var ignoreNextTap = false
    @Binding var isAlertPresented: Bool

    private var revealOffset: CGFloat { -deleteButtonWidth }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = appLanguage.locale
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: zekr.lastUpdated)
    }

    var body: some View {
        ZStack {
            HStack {
                Spacer()
                deleteButton
                    .offset(x: -10)
            }
            .zIndex(offset != 0 ? 2 : 0)
            .allowsHitTesting(offset != 0)
            .opacity(offset != 0 ? 1 : 0)

            cardContent
                .offset(x: offset)
                .zIndex(1)
                .contentShape(Rectangle())
                .onTapGesture {
                    handleCardTap()
                }
                .onLongPressGesture(minimumDuration: 0.5) {
                    revealDeleteButton()
                }
        }
        .environment(\.layoutDirection, .leftToRight)
        .onChange(of: isAlertPresented) { newValue in
            if !newValue {
                withAnimation {
                    offset = 0
                }
            }
        }
    }

    private func handleCardTap() {
        guard !ignoreNextTap else { return }

        if offset != 0 {
            withAnimation {
                offset = 0
            }
        } else {
            onTap()
        }
    }

    private func revealDeleteButton() {
        withAnimation {
            offset = revealOffset
        }
        ignoreNextTap = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            ignoreNextTap = false
        }
    }

    private var cardContent: some View {
        HStack(spacing: 15) {
            Spacer()

            VStack(alignment: .center, spacing: 4) {
                Text(zekr.text)
                    .azkarContentFont(size: AzkarFont.listSize)
                    .foregroundColor(theme.currentTheme.buttonText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .minimumScaleFactor(0.7)
                    .lineLimit(6)
                    .environment(\.layoutDirection, .rightToLeft)

                Text(appLanguage.text("azkary.last_updated", formattedDate))
                    .font(.caption)
                    .foregroundColor(theme.currentTheme.buttonText.opacity(0.35))
            }

            Text("\(zekr.counter)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(theme.currentTheme.primary)
                .frame(minWidth: 44, minHeight: 44)
                .padding(5)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(theme.currentTheme.cardBackground)
                )
                .padding(.trailing, 5)
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.currentTheme.primary.opacity(0.9))
                .shadow(color: theme.currentTheme.text.opacity(0.25), radius: 3, x: 3, y: 3)
        )
    }

    private var deleteButton: some View {
        Button(action: onDelete) {
            Circle()
                .fill(theme.currentTheme.primary)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "scissors")
                        .foregroundColor(theme.currentTheme.buttonText)
                )
                .shadow(color: theme.currentTheme.text.opacity(0.25), radius: 3, x: 3, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(appLanguage.text("common.delete"))
    }
}
