//
//  BackgroundView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 10/07/2025.
//

import SwiftUI

struct BackgroundView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var patternManager: PatternManager

    var body: some View {
        ZStack {
            theme.currentTheme.background.opacity(0.5).ignoresSafeArea()
            
            Image(patternManager.currentPattern)
                .resizable(resizingMode: .tile)
                .opacity(0.55)
                .ignoresSafeArea(.all)
        }
    }
}
