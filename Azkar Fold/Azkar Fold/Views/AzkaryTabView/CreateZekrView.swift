//
//  CreateZekrView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 02/05/2025.
//

import SwiftUI

struct CreateZekrView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    @EnvironmentObject var zekrStore: ZekrStore
    @Environment(\.presentationMode) var presentationMode
    @State private var zekrText = ""
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create New Zekr")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.themePrimary)
                .padding(.top)
            
            // Neo-brutalism style text field
            TextField("سبحان الله وبحمده", text: $zekrText)
                .font(.headline)
                .padding()
                .environment(\.layoutDirection, .rightToLeft)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.2), radius: 0, x: 4, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.themePrimary, lineWidth: 2)
                        )
                )
                .padding(.horizontal)
            
            
            // Modified button action
            Button(action: {
                if !zekrText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    zekrStore.addZekr(text: zekrText) {
                        presentationMode.wrappedValue.dismiss()
                    }
                } else {
                    showAlert = true
                }
            }) {
                Text("Create Zekr")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        Rectangle()
                            .fill(Color.themePrimary)
                            .shadow(color: .black.opacity(0.3), radius: 0, x: 4, y: 4)
                    )
                    .padding(.horizontal)
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Create Zekr")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            Image("islamic_pattern")
                .resizable(resizingMode: .tile)
                .opacity(0.05)
        )
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Empty Zekr"),
                message: Text("Please enter some text for your Zekr."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
