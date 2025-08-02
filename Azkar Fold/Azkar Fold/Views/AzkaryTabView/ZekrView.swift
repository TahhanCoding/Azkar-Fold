//
//  SettingsTabView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct ZekrView: View {
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var patternManager: PatternManager
    let zekrId: UUID
    @EnvironmentObject var zekrStore: ZekrStore
    @Environment(\.dismiss) private var dismiss
    @State private var animateCounter = false
    @State private var showingResetAlert = false
    @State private var showingDeleteAlert = false
    @State private var isEditMode = false
    @State private var editedText = ""
    @State private var isDimmed = false
    @State private var showDimHint = false
    @AppStorage("hasSeenDimHint") private var hasSeenDimHint = false
    
    var zekr: Zekr? {
        zekrStore.zekrs.first(where: { $0.id == zekrId })
    }
    
    @Namespace private var nameSpace

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    // Upper half - Zekr text or TextField
                    ZStack {
                        VStack {
                            if let zekr = zekr {
                                if isEditMode {
                                    TextEditor(text: $editedText)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                        .background(theme.currentTheme.cardBackground.opacity(0.8))
                                        .cornerRadius(12)
                                        .padding()
                                } else {
                                    Text(zekr.text)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(theme.currentTheme.text)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                }
                            } else {
                                Text("Zekr not found")
                                        .font(.title)
                                        .foregroundColor(theme.currentTheme.text)
                            }
                        }
                        
                        // Lamp button in top trailing corner of card
                        if !isEditMode {
                            VStack {
                                HStack {
                                    Spacer()
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            isDimmed.toggle()
                                            if isDimmed && !hasSeenDimHint {
                                                showDimHint = true
                                                hasSeenDimHint = true
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "lamp.desk.fill")
                                            .foregroundColor(.white)
                                            .padding(5)
                                            .background(
                                                Color.black.opacity(0.3)
                                            )
                                            .clipShape(Circle())
                                            .font(.caption)
                                            .padding(12)
                                    }
                                    .disabled(isEditMode)
                                    .zIndex(1)
                                }
                                Spacer()
                            }
                            .padding(.trailing, 35)
                            .padding(.top, 35)
                        }
                    }
                    .frame(height: geometry.size.height / 2)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 33)
                            .fill(theme.currentTheme.background.opacity(0.65))
                            .overlay(
                                Group {
                                    if patternManager.currentPattern != "none" {
                                        Image(patternManager.currentPattern)
                                            .resizable(resizingMode: .tile)
                                            .opacity(0.35)
                                    }
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 33))
                            .padding(.horizontal, 21)
                            .padding(.vertical, 21)
                    )

                    
                    // Lower half - Counter or Edit buttons
                    VStack {
                        if isEditMode {
                            // Edit mode buttons
                            HStack(spacing: 30) {
                                Button("Cancel") {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        cancelEdit()
                                    }
                                }
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(theme.currentTheme.text)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(theme.currentTheme.background, lineWidth: 2)
                                )
                                .matchedGeometryEffect(id: "secButton", in: nameSpace)

                                
                                Button("Save") {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        saveEdit()
                                    }
                                }
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(theme.currentTheme.buttonText)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(theme.currentTheme.primary)
                                )
                                .disabled(editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                .opacity(editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
                                .matchedGeometryEffect(id: "mainBuuton", in: nameSpace)

                            }
                        } else {
                            // View mode counter
                            if let zekr = zekr {
                                Text("\(zekr.counter)")
                                    .font(.system(size: 80, weight: .black, design: .rounded))
                                    .foregroundColor(theme.currentTheme.text)
                                    .matchedGeometryEffect(id: "mainBuuton", in: nameSpace)
                            }
                            
                            Text("Tap to count")
                                .font(.subheadline)
                                .foregroundColor(theme.currentTheme.text)
                                .padding(.top, 5)
                                .matchedGeometryEffect(id: "secButton", in: nameSpace)

                        }
                    }
                    .frame(height: geometry.size.height / 2)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !isEditMode, let zekr = zekr {
                            zekrStore.updateCounter(for: zekr.id)
                            animateCounter = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                animateCounter = false
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 0)
                            .fill(theme.currentTheme.background)
                            .shadow(color: theme.currentTheme.text.opacity(0.1), radius: 2, x: 0, y: -2)
                    )
                }
                
                // Dimming overlay
                if isDimmed {
                    Color.white
                    BackgroundView().blur(radius: 5)
                    Color.black
                        .opacity(0.9)
                        .ignoresSafeArea(.all)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if !isEditMode, let zekr = zekr {
                                zekrStore.updateCounter(for: zekr.id)
                                animateCounter = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    animateCounter = false
                                }
                            }
                        }
                        .onLongPressGesture(minimumDuration: 0.5) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isDimmed = false
                                showDimHint = false
                            }
                        }
                        .transition(.opacity)
                    
                    // Counter display on dimmed overlay
                    if let zekr = zekr, isDimmed {
                        VStack {
                            Spacer()
                            Text("\(zekr.counter)")
                                .font(.system(size: 80, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .matchedGeometryEffect(id: "mainBuuton", in: nameSpace)
                            Spacer()
                        }
                        .allowsHitTesting(false)
                    }
                    
                    // One-time hint
                    if showDimHint {
                        VStack {
                            Text("Dim mode activated")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.bottom, 8)
                            
                            Text("Screen is dimmed for comfortable counting in dark environments. Tap anywhere to count, long press to exit.")
                                .font(.body)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.7))
                        )
                        .padding(.horizontal, 20)
                        .transition(.opacity.combined(with: .scale))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showDimHint = false
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Zekr Counter")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(isDimmed)
            .background(
                RoundedRectangle(cornerRadius: 33)
                    .fill(theme.currentTheme.background.opacity(0.35))
                    .ignoresSafeArea(.all)
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // Menu button
                    Menu {
                        Button("Edit") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                startEdit()
                            }
                        }
                        
                        Button("Reset") {
                                showingResetAlert = true
                        }
                        
                        Button("Delete", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(theme.currentTheme.primary)
                    }
                    .disabled(isEditMode)
                }
            }
            .alert("Reset Counter", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    if let zekr = zekr {
                        zekrStore.resetCounter(for: zekr.id)
                    }
                }
            } message: {
                Text("Are you sure you want to reset the counter to 0?")
                    .foregroundColor(theme.currentTheme.text)
            }
            .alert("Delete Zekr", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let zekr = zekr {
                        zekrStore.deleteZekr(withId: zekr.id)
                        dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to delete this zekr? This action cannot be undone.")
                    .foregroundColor(theme.currentTheme.text)
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    // MARK: - Edit Mode Functions
    private func startEdit() {
        guard let zekr = zekr else { return }
        editedText = zekr.text
        isEditMode = true
    }
    
    private func cancelEdit() {
        editedText = ""
        isEditMode = false
    }
    
    private func saveEdit() {
        guard let zekr = zekr else { return }
        let trimmedText = editedText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty {
            zekrStore.updateZekrText(for: zekr.id, newText: trimmedText)
        }
        isEditMode = false
        editedText = ""
    }
}

