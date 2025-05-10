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
        HStack(spacing: 12) {
            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text(zekr.text)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.appPrimary)
                    .lineLimit(1)
                    .environment(\.layoutDirection, .rightToLeft)
                
                Text("Last updated: \(formattedDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .environment(\.layoutDirection, .rightToLeft)
            }
            .environment(\.layoutDirection, .rightToLeft)

            
            Text("\(zekr.counter)")
                .font(.title)
                .fontWeight(.black)
                .foregroundColor(.appPrimary)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.appPrimary.opacity(0.1))
                )
                .padding(.trailing, 12)
            
        }
        .padding(.vertical, 8)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: zekr.lastUpdated)
    }
}
