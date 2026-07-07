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
    @State private var lockedDragAxis: DragAxis?
    @State private var dragStartOffset: CGFloat = 0
    @Binding var isAlertPresented: Bool

    private enum DragAxis {
        case horizontal
        case vertical
    }

    private let axisLockThreshold: CGFloat = 10
    
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
            
            // Main content
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
            .simultaneousGesture(horizontalSwipeGesture)
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

    private var horizontalSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 12, coordinateSpace: .local)
            .onChanged { value in
                let absDx = abs(value.translation.width)
                let absDy = abs(value.translation.height)

                if lockedDragAxis == nil {
                    guard absDx > axisLockThreshold || absDy > axisLockThreshold else { return }

                    if absDx > absDy {
                        lockedDragAxis = .horizontal
                        dragStartOffset = offset
                    } else {
                        lockedDragAxis = .vertical
                        return
                    }
                }

                guard lockedDragAxis == .horizontal else { return }

                offset = min(
                    0,
                    max(-deleteButtonWidth, dragStartOffset + value.translation.width)
                )
            }
            .onEnded { _ in
                defer {
                    lockedDragAxis = nil
                    dragStartOffset = 0
                }

                guard lockedDragAxis == .horizontal else { return }

                withAnimation {
                    if offset < -deleteButtonWidth / 2 {
                        offset = -deleteButtonWidth
                    } else {
                        offset = 0
                    }
                }
            }
    }
}
