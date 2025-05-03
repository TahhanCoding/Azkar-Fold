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
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(zekr.text)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .environment(\.layoutDirection, .rightToLeft)
                
                Text("Last updated: \(formattedDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .environment(\.layoutDirection, .rightToLeft)
            }
            .environment(\.layoutDirection, .rightToLeft)

            Spacer()
            
            Text("\(zekr.counter)")
                .font(.title)
                .fontWeight(.black)
                .foregroundColor(.purple)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.purple.opacity(0.1))
                )
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
