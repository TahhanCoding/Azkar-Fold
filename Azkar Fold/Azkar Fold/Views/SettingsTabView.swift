//
//  SettingsTabView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct SettingsTabView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings View")
                    .font(.largeTitle)
                    .foregroundColor(.appPrimary) // Neo-brutalism vibrant color
                    .fontWeight(.bold) // Bold typography
            }
            .navigationTitle("Settings")
            .background(
                Image("islamic_pattern")
                    .resizable(resizingMode: .tile)
                    .opacity(0.05)
            )
        }
    }
}
