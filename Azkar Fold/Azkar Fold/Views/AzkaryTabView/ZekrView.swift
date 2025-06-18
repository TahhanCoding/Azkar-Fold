//
//  SettingsTabView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct ZekrView: View {
    let zekrId: UUID
    @EnvironmentObject var zekrStore: ZekrStore
    @Environment(\.dismiss) private var dismiss
    @State private var animateCounter = false
    @State private var showingResetAlert = false
    @State private var showingDeleteAlert = false
    @State private var isEditMode = false
    @State private var editedText = ""
    
    var zekr: Zekr? {
        zekrStore.zekrs.first(where: { $0.id == zekrId })
    }
    
    @Namespace private var nameSpace

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Upper half - Zekr text or TextField
                VStack {
                    if let zekr = zekr {
                        if isEditMode {
                            TextEditor(text: $editedText)
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(12)
                                .padding()
                        } else {
                            Text(zekr.text)
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    } else {
                        Text("Zekr not found")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                }
                .frame(height: geometry.size.height / 2)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 33)
                        .fill(Color.themePrimary.opacity(0.1))
                        .overlay(
                            Image("islamic_pattern")
                                .resizable(resizingMode: .tile)
                                .opacity(0.35)
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
                            .foregroundColor(.gray)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.gray, lineWidth: 2)
                            )
                            .matchedGeometryEffect(id: "secButton", in: nameSpace)

                            
                            Button("Save") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    saveEdit()
                                }
                            }
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.themePrimary)
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
                                .foregroundColor(.themePrimary)
                                .scaleEffect(animateCounter ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animateCounter)
                                .matchedGeometryEffect(id: "mainBuuton", in: nameSpace)
                        }
                        
                        Text("Tap to count")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
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
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: -2)
                )
            }
            .navigationTitle("Zekr Counter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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
                            .foregroundColor(.themePrimary)
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
