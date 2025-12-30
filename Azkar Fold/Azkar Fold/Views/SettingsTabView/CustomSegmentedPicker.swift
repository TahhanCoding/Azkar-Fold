//
//  CustomSegmentedPicker.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

protocol DisplayNameProviding {
    var displayName: String { get }
}

extension SunnahSettingsStore.InitialViewMode: DisplayNameProviding {}
extension SunnahSettingsStore.CardHeightMode: DisplayNameProviding {}

struct CustomSegmentedPicker<SelectionValue: Hashable & CaseIterable & Identifiable & DisplayNameProviding>: View where SelectionValue.AllCases: RandomAccessCollection {
    @Binding var selection: SelectionValue
    let theme: ThemeManager
    
    var body: some View {
        GeometryReader { geometry in
            let allCases = Array(SelectionValue.allCases)
            let buttonWidth = geometry.size.width / CGFloat(allCases.count)
            let selectedIndex = allCases.firstIndex(where: { $0.id == selection.id }) ?? 0
            let selectedOffset = CGFloat(selectedIndex) * buttonWidth + 3
            
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.currentTheme.cardBackground)
                
                // Selected indicator that slides
                RoundedRectangle(cornerRadius: 6)
                    .fill(theme.currentTheme.primary)
                    .frame(width: buttonWidth - 6)
                    .offset(x: selectedOffset)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selection.id)
                
                // Buttons
                HStack(spacing: 0) {
                    ForEach(allCases) { option in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selection = option
                            }
                        }) {
                            Text(option.displayName)
                                .font(.system(size: 13, weight: selection == option ? .semibold : .regular))
                                .foregroundColor(
                                    selection == option
                                        ? theme.currentTheme.buttonText
                                        : theme.currentTheme.text
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 6)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .frame(height: 32)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedMode: SunnahSettingsStore.InitialViewMode = .full
        @State private var selectedHeight: SunnahSettingsStore.CardHeightMode = .fixed
        
        var body: some View {
            VStack(spacing: 30) {
                CustomSegmentedPicker(
                    selection: $selectedMode,
                    theme: ThemeManager.shared
                )
                .frame(width: 200)
                
                CustomSegmentedPicker(
                    selection: $selectedHeight,
                    theme: ThemeManager.shared
                )
                .frame(width: 200)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
        }
    }
    
    return PreviewWrapper()
}

