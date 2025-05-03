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
    @State private var animateCounter = false
    
    var zekr: Zekr? {
        zekrStore.zekrs.first(where: { $0.id == zekrId })
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Upper half - Zekr text
                VStack {
                    if let zekr = zekr {
                        Text(zekr.text)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        Text("Zekr not found")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                }
                .frame(height: geometry.size.height / 2)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.purple.opacity(0.1))
                )
                
                // Lower half - Counter
                VStack {
                    if let zekr = zekr {
                        Text("\(zekr.counter)")
                            .font(.system(size: 80, weight: .black, design: .rounded))
                            .foregroundColor(.purple)
                            .scaleEffect(animateCounter ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animateCounter)
                    }
                    
                    Text("Tap to count")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 5)
                }
                .frame(height: geometry.size.height / 2)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    if let zekr = zekr {
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
            .background(
                Image("islamic_pattern")
                    .resizable(resizingMode: .tile)
                    .opacity(0.05)
            )
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}
