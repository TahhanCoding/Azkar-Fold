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
                            Image(systemName: "trash")
                                .foregroundColor(theme.currentTheme.buttonText)
                        )
                        .shadow(color: theme.currentTheme.text.opacity(0.25), radius: 3, x: 3, y: 3)
                        .opacity(abs(offset) / deleteButtonWidth)
                }
                .offset(x: offset > -deleteButtonWidth ? offset + deleteButtonWidth : 0)
                .offset(x: -10)
            }
            
            // Main content
            HStack(spacing: 15) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(zekr.text)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(theme.currentTheme.text)
                        .lineLimit(1)
                        .multilineTextAlignment(.trailing)
                        .environment(\.layoutDirection, .rightToLeft)
                    
                    Text("Last updated: \(formattedDate)")
                        .font(.caption)
                        .foregroundColor(theme.currentTheme.text)
                        .environment(\.layoutDirection, .rightToLeft)
                }
                .environment(\.layoutDirection, .rightToLeft)
                
                Text("\(zekr.counter)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(theme.currentTheme.text)
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
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let translation = value.translation.width
                        if translation < 0 {
                            withAnimation {
                                offset = max(-deleteButtonWidth, translation)
                            }
                        }
                    }
                    .onEnded { value in
                        withAnimation {
                            if value.translation.width < -deleteButtonWidth/2 {
                                offset = -deleteButtonWidth
                            } else {
                                offset = 0
                            }
                        }
                    }
            )
            .onTapGesture(perform: onTap)
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
