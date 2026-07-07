//
//  SunnahZekrTextCard.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct SunnahZekrTextCard: View {
    let text: String
    let isCompleted: Bool
    let isSimpleMode: Bool
    let availableHeight: CGFloat
    let theme: ThemeManager
    let patternManager: PatternManager
    let onTap: () -> Void

    private let textHorizontalPadding: CGFloat = 16
    private let textVerticalPadding: CGFloat = 12
    private let cardHorizontalPadding: CGFloat = 18
    private let cardVerticalPadding: CGFloat = 12
    private let outerHorizontalPadding: CGFloat = 21

    private var maxCardHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        return isSimpleMode ? screenHeight * 0.75 : screenHeight * 0.65
    }

    private var heightBudget: CGFloat {
        min(maxCardHeight, max(availableHeight, 1))
    }

    private var scrollAreaHeight: CGFloat {
        max(heightBudget - cardVerticalPadding * 2, 1)
    }

    var body: some View {
        ViewThatFits(in: .vertical) {
            cardShell {
                zekrLabel
                    .fixedSize(horizontal: false, vertical: true)
            }

            cardShell {
                ScrollView(.vertical, showsIndicators: true) {
                    zekrLabel
                }
                .frame(height: scrollAreaHeight)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: heightBudget)
        .fixedSize(horizontal: false, vertical: true)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSimpleMode)
        .onTapGesture {
            onTap()
        }
    }

    private var zekrLabel: some View {
        Text(text)
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(theme.currentTheme.text)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, textHorizontalPadding)
            .padding(.vertical, textVerticalPadding)
            .id(text)
    }

    @ViewBuilder
    private func cardShell<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, cardHorizontalPadding)
            .padding(.vertical, cardVerticalPadding)
            .frame(maxWidth: .infinity, alignment: .top)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 33))
            .padding(.horizontal, outerHorizontalPadding)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 33)
            .fill(isCompleted ? theme.currentTheme.background.opacity(0.65) : theme.currentTheme.background.opacity(0.45))
            .overlay {
                if patternManager.currentPattern != "none" {
                    Image(patternManager.currentPattern)
                        .resizable(resizingMode: .tile)
                        .opacity(0.35)
                }
            }
    }
}

#Preview("Short Text") {
    SunnahZekrTextCard(
        text: "سُبْحَانَ اللَّهِ",
        isCompleted: false,
        isSimpleMode: false,
        availableHeight: 500,
        theme: ThemeManager.shared,
        patternManager: PatternManager.shared,
        onTap: { print("Tapped") }
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}

#Preview("Long Text") {
    SunnahZekrTextCard(
        text: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ. اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ.",
        isCompleted: true,
        isSimpleMode: false,
        availableHeight: 500,
        theme: ThemeManager.shared,
        patternManager: PatternManager.shared,
        onTap: { print("Tapped") }
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}
