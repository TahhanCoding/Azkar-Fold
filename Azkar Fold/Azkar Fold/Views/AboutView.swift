//
//  AboutView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 02/05/2025.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // App logo/icon
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.purple)
                    .padding(.top, 30)
                
                // App name and version
                Text("Azkar Fold")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.purple)
                
                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // App description
                VStack(alignment: .leading, spacing: 15) {
                    descriptionSection(
                        title: "About This App",
                        content: "Azkar Fold is an Islamic app designed to help Muslims maintain their daily remembrances (Azkar). The app allows you to create and track your custom Azkar with a simple counter interface."
                    )
                    
                    descriptionSection(
                        title: "Features",
                        content: "• Create custom Azkar\n• Track count for each Zekr\n• Beautiful Neo-Brutalism design with Islamic textures\n• Simple and intuitive interface"
                    )
                    
                    descriptionSection(
                        title: "Developer",
                        content: "Created by Ahmed Shaban\nContact: example@email.com"
                    )
                }
                .padding(.horizontal, 25)
                .padding(.top, 10)
                
                // Neo-brutalism style buttons
                Button(action: {
                    // Action to rate the app
                }) {
                    neoBrutalismButton(title: "Rate This App", icon: "star.fill")
                }
                .padding(.top, 20)
                
                Button(action: {
                    // Action to share the app
                }) {
                    neoBrutalismButton(title: "Share With Friends", icon: "square.and.arrow.up")
                }
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("About")
        .background(
            Image("islamic_pattern")
                .resizable(resizingMode: .tile)
                .opacity(0.05)
        )
    }
    
    // Helper function for description sections
    private func descriptionSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.purple)
            
            Text(content)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // Neo-brutalism style button
    private func neoBrutalismButton(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.headline)
            Text(title)
                .font(.headline)
        }
        .foregroundColor(.white)
        .frame(width: 250, height: 50)
        .background(
            Rectangle()
                .fill(Color.purple)
                .shadow(color: .black.opacity(0.3), radius: 0, x: 4, y: 4)
        )
    }
}

#Preview {
    NavigationView {
        AboutView()
    }
}