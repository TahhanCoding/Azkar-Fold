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
    let cardHeightMode: SunnahSettingsStore.CardHeightMode
    let isSimpleMode: Bool
    let theme: ThemeManager
    let patternManager: PatternManager
    let onTap: () -> Void
    
    // Optional snapshot functionality
    let showWatermark: Bool
    let index: Int
    let currentIndex: Int
    let takeSnapshot: Bool
    
    init(
        text: String,
        isCompleted: Bool,
        cardHeightMode: SunnahSettingsStore.CardHeightMode,
        isSimpleMode: Bool,
        theme: ThemeManager,
        patternManager: PatternManager,
        onTap: @escaping () -> Void,
        showWatermark: Bool = false,
        index: Int = 0,
        currentIndex: Int = 0,
        takeSnapshot: Bool = false
    ) {
        self.text = text
        self.isCompleted = isCompleted
        self.cardHeightMode = cardHeightMode
        self.isSimpleMode = isSimpleMode
        self.theme = theme
        self.patternManager = patternManager
        self.onTap = onTap
        self.showWatermark = showWatermark
        self.index = index
        self.currentIndex = currentIndex
        self.takeSnapshot = takeSnapshot
    }
    
    private func calculateCardHeight() -> CGFloat {
        if cardHeightMode == .fixed {
            return isSimpleMode
                ? UIScreen.main.bounds.height * 0.7
                : UIScreen.main.bounds.height * 0.5
        } else {
            // Adaptive mode - return a small base height
            return 130
        }
    }
    
    private func calculateMaxHeight() -> CGFloat? {
        if cardHeightMode == .adaptive {
            return isSimpleMode
                ? UIScreen.main.bounds.height * 0.75
                : UIScreen.main.bounds.height * 0.65
        }
        return nil
    }
    
    var body: some View {
        let cardHeight = calculateCardHeight()
        let maxHeight = calculateMaxHeight()
        
        // Card background
        let cardBackground = RoundedRectangle(cornerRadius: 33)
            .fill(isCompleted ? theme.currentTheme.background.opacity(0.65) : theme.currentTheme.background.opacity(0.45))
            .overlay(
                Group {
                    if patternManager.currentPattern != "none" {
                        Image(patternManager.currentPattern)
                            .resizable(resizingMode: .tile)
                            .opacity(0.35)
                    }
                }
            )
        
        // Text content - always centered
        let textView = Text(text)
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(theme.currentTheme.text)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            .font(.system(size: 80))
            .padding(.vertical, 12)
            .id(text) // Use text as identifier
            .frame(maxWidth: .infinity)
        
        Group {
            if cardHeightMode == .fixed {
                // Fixed height: Card has exact height, text centered with constraints
                VStack {
                    Spacer()
                    textView
                        .minimumScaleFactor(0.3)
                        .lineLimit(15)
                    Spacer()
                }
                .frame(height: cardHeight)
                .padding(.horizontal, 18)
                .frame(maxWidth: .infinity)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 33))
                .padding(.horizontal, 21)
            } else {
                // Adaptive height: Card sizes to content with max constraint
                VStack {
                    textView
                }
                .fixedSize(horizontal: false, vertical: true) // Shrink to fit content
                .frame(minHeight: cardHeight)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 33))
                .padding(.horizontal, 21)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSimpleMode)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: cardHeightMode)
        .onTapGesture {
            onTap()
        }
        .overlay(
            Group {
                if showWatermark && index == currentIndex && takeSnapshot {
                    VStack {
                        Spacer()
                        Text("azkarfold.com")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(theme.currentTheme.text.opacity(0.7))
                            .padding(.bottom, 16)
                    }
                }
            }
        )
    }
}

// MARK: - Preview
#Preview("Fixed Height - Full Mode") {
    SunnahZekrTextCard(
        text: "سُبْحَانَ اللَّهِ",
        isCompleted: false,
        cardHeightMode: .fixed,
        isSimpleMode: false,
        theme: ThemeManager.shared,
        patternManager: PatternManager.shared,
        onTap: { print("Tapped") }
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}

#Preview("Fixed Height - Simple Mode") {
    SunnahZekrTextCard(
        text: "سُبْحَانَ اللَّهِ",
        isCompleted: false,
        cardHeightMode: .fixed,
        isSimpleMode: true,
        theme: ThemeManager.shared,
        patternManager: PatternManager.shared,
        onTap: { print("Tapped") }
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}

#Preview("Adaptive Height - Short Text") {
    SunnahZekrTextCard(
        text: "سُبْحَانَ اللَّهِ",
        isCompleted: false,
        cardHeightMode: .adaptive,
        isSimpleMode: false,
        theme: ThemeManager.shared,
        patternManager: PatternManager.shared,
        onTap: { print("Tapped") }
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}

#Preview("Adaptive Height - Long Text") {
    SunnahZekrTextCard(
        text: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ. اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ.",
        isCompleted: true,
        cardHeightMode: .adaptive,
        isSimpleMode: false,
        theme: ThemeManager.shared,
        patternManager: PatternManager.shared,
        onTap: { print("Tapped") }
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}

#Preview("Completed State") {
    SunnahZekrTextCard(
        text: " اللهم اغفر لي",
        isCompleted: true,
        cardHeightMode: .fixed,
        isSimpleMode: false,
        theme: ThemeManager.shared,
        patternManager: PatternManager.shared,
        onTap: { print("Tapped") }
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}

