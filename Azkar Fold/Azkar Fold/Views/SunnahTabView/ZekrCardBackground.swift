//
//  ZekrCardBackground.swift
//  HRSD
//
//  Created by Ahmed AlTahhan on 08/07/2026.
//  Copyright © 2026 Future Workshops. All rights reserved.
//

import SwiftUI

struct ZekrShareAppearance {
    let background: Color
    let text: Color
    let patternName: String

    init(theme: ThemeManager, patternManager: PatternManager) {
        background = theme.currentTheme.background
        text = theme.currentTheme.text
        patternName = patternManager.currentPattern
    }
}

struct ZekrCardBackground: View {
    let background: Color
    let patternName: String
    let isCompleted: Bool
    var cornerRadius: CGFloat = 33

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(background.opacity(isCompleted ? 0.65 : 0.45))
            .overlay {
                if patternName != "none" {
                    Image(patternName)
                        .resizable(resizingMode: .tile)
                        .opacity(0.35)
                }
            }
    }
}
