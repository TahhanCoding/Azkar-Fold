//
//  PattenManagerView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 11/07/2025.
//

import SwiftUI

struct PattenManagerView: View {
    @EnvironmentObject var patternManager: PatternManager
    
    var body: some View {
        ZStack {
            // Use the current pattern as background
//            Image(patternManager.currentPattern)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .edgesIgnoringSafeArea(.all)
            
            // Pattern selection interface
            VStack {
                Text("Select Pattern")
                    .font(.title)
                    .padding()
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(patternManager.availablePatterns, id: \.self) { pattern in
                            Button(action: {
                                patternManager.setCurrentPattern(pattern)
                            }) {
                                Image(pattern)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(patternManager.currentPattern == pattern ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}
