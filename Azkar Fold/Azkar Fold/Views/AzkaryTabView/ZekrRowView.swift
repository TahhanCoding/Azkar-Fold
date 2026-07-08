//
//  ZekrRowView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct ZekrRowView: View {
    @EnvironmentObject var theme: ThemeManager
    let zekr: Zekr
    let onDelete: () -> Void
    let onTap: () -> Void

    @State private var offset: CGFloat = 0
    @State private var deleteButtonWidth: CGFloat = 75
    @State private var ignoreNextTap = false
    @Binding var isAlertPresented: Bool

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: zekr.lastUpdated)
    }

    var body: some View {
        ZStack {
            HStack {
                Spacer()

                Button(action: onDelete) {
                    Circle()
                        .fill(theme.currentTheme.primary)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "scissors")
                                .foregroundColor(theme.currentTheme.buttonText)
                        )
                        .shadow(color: theme.currentTheme.text.opacity(0.25), radius: 3, x: 3, y: 3)
                        .opacity(abs(offset) / deleteButtonWidth)
                }
                .offset(x: offset > -deleteButtonWidth ? offset + deleteButtonWidth : 0)
                .offset(x: -10)
            }

            HStack(spacing: 15) {
                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text(zekr.text)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(theme.currentTheme.buttonText)

                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .font(.system(size: 80))
                        .minimumScaleFactor(0.3)
                        .lineLimit(15)


                        .environment(\.layoutDirection, .rightToLeft)

                    Text("Last updated: \(formattedDate)")
                        .font(.caption)
                        .foregroundColor(theme.currentTheme.buttonText.opacity(0.35))
                        .environment(\.layoutDirection, .rightToLeft)
                }
                .environment(\.layoutDirection, .rightToLeft)

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
            .offset(x: offset)
            .contentShape(Rectangle())
            .onTapGesture {
                if ignoreNextTap { return }

                if offset != 0 {
                    withAnimation {
                        offset = 0
                    }
                } else {
                    onTap()
                }
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                withAnimation {
                    offset = -deleteButtonWidth
                }
                ignoreNextTap = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    ignoreNextTap = false
                }
            }
        }
        .onChange(of: isAlertPresented) { newValue in
            if !newValue {
                withAnimation {
                    offset = 0
                }
            }
        }
    }
}
