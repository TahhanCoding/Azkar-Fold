//
//  SettingsTabView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct EmptyZekrView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 80))
                .foregroundColor(.purple.opacity(0.7))
            
            Text("No custom Azkar created yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Tap the + button to create your first Zekr")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                coordinator.navigate(to: .createZekr)
            }) {
                Text("Create Zekr")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.purple)
                    .cornerRadius(8)
            }
            .padding(.top, 10)
        }
        .padding()
    }
}
