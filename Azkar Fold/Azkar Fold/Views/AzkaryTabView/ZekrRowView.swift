//
//  SettingsTabView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct ZekrRowView: View {
    let zekr: Zekr
    
    var body: some View {
        HStack(spacing: 15) {
            Spacer()

            
            VStack(alignment: .leading, spacing: 4) {
                Text(zekr.text)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .multilineTextAlignment(.trailing)
                    .environment(\.layoutDirection, .rightToLeft)
                
                Text("Last updated: \(formattedDate)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .environment(\.layoutDirection, .rightToLeft)
            }
            .environment(\.layoutDirection, .rightToLeft)

            
            Text("\(zekr.counter)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.appPrimary)
                .frame(minWidth: 44, minHeight: 44)
                .padding(5)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                )
                .padding(.trailing, 5)
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appPrimary.opacity(0.9))
                .shadow(color: Color.black.opacity(0.25), radius: 3, x: 3, y: 3)
        )
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: zekr.lastUpdated)
    }
}
