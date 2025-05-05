//
//  SunnahTabView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 02/05/2025.
//

import SwiftUI

struct SunnahTabView: View {
    var body: some View {
        NavigationView {
            VStack {
                // Placeholder content for Sunnah tab
                Image(systemName: "book.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.azkarPrimary.opacity(0.7))
                    .padding()
                
                Text("Sunnah Content")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.azkarPrimary)
                
                Text("This section will contain Sunnah practices and teachings")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Placeholder for future content
                Text("Coming Soon")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Rectangle()
                            .fill(Color.azkarPrimary)
                            .shadow(color: .black.opacity(0.3), radius: 0, x: 4, y: 4)
                    )
                    .padding(.top, 20)
            }
            .padding()
            .navigationTitle("Sunnah")
            .background(
                Image("islamic_pattern")
                    .resizable(resizingMode: .tile)
                    .opacity(0.05)
            )
        }
    }
}

#Preview {
    SunnahTabView()
}
