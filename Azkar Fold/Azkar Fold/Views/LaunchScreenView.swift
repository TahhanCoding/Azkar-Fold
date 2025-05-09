//
//  LaunchScreenView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

// Launch screen with flowing animations in neo-brutalism style
struct LaunchScreenView: View {
    // Animation states
    @State private var isLogoAnimated = false
    @State private var isTextAnimated = false
    @State private var isPatternAnimated = false
    @State private var showMainView = false
    
    // For the flowing effect
    @State private var patternOpacity = 0.0
    @State private var patternScale = 0.8
    @State private var rotation = 0.0
    @State private var pulsate = false
    
    // Enhanced fluid animations
    @State private var patternMovement = false
    @State private var patternWave = 0.0
    @State private var glowIntensity = 0.0
    @State private var textShimmer = false
    
    var body: some View {
        ZStack {
            // Background color
            Color.white.opacity(0.97)
                .ignoresSafeArea()
            
            // Islamic pattern background with enhanced fluid animations
            Image("launch_pattern")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .foregroundColor(Color.appPrimary)
                .scaleEffect(isPatternAnimated ? 1.1 : patternScale)
                .rotationEffect(Angle(degrees: isPatternAnimated ? 5 : 0))
                .offset(y: patternMovement ? 5 : -5)
                .opacity(patternOpacity)
                .blur(radius: isPatternAnimated ? 0 : 10)
                .overlay(
                    // Subtle wave effect overlay
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.appPrimary.opacity(0.1))
                        .scaleEffect(1.2)
                        .offset(x: patternWave, y: 0)
                        .blendMode(.overlay)
                        .opacity(patternOpacity * 0.7)
                )
                .overlay(
                    // Glow effect
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.appPrimary.opacity(glowIntensity))
                        .blur(radius: 20)
                        .blendMode(.screen)
                )
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // App logo with animation
                ZStack {
                    // Neo-brutalism style background square
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .shadow(color: .black.opacity(0.5), radius: 0, x: 6, y: 6)
                        .rotationEffect(.degrees(rotation))
                        .scaleEffect(pulsate ? 1.05 : 1.0)
                    
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.appPrimary)
                        .scaleEffect(isLogoAnimated ? 1.0 : 0.5)
                        .opacity(isLogoAnimated ? 1.0 : 0.0)
                }
                
                // App name with enhanced animation
                Text("Azkar Fold")
                    .font(.system(size: 42, weight: .black))
                    .foregroundColor(.appPrimary)
                    .opacity(isTextAnimated ? 1.0 : 0.0)
                    .offset(y: isTextAnimated ? 0 : 20)
                    .shadow(color: .black.opacity(0.2), radius: 0, x: 2, y: 2) // Neo-brutalism shadow
                    .overlay(
                        // Text shimmer effect
                        Text("Azkar Fold")
                            .font(.system(size: 42, weight: .black))
                            .foregroundColor(Color.white.opacity(textShimmer ? 0.0 : 0.3))
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .white, .clear]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .offset(x: textShimmer ? 150 : -150)
                            )
                    )
                
                // Subtitle with animation
                Text("Your Daily Islamic Remembrance")
                    .font(.headline)
                    .foregroundColor(.appPrimary.opacity(0.8))
                    .opacity(isTextAnimated ? 0.8 : 0.0)
                    .offset(y: isTextAnimated ? 0 : 30)
            }
            .padding()
        }
        .onAppear {
            // Start animations in sequence with improved timing
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                patternOpacity = 0.4
                patternScale = 1.0
            }
            
            // Subtle rotation animation for neo-brutalism effect
            withAnimation(.easeInOut(duration: 0.7).delay(0.3)) {
                rotation = -3
            }
            
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.5)) {
                isLogoAnimated = true
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(1.0)) {
                isTextAnimated = true
            }
            
            // Enhanced pattern animations
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(0.8)) {
                patternMovement = true
            }
            
            // Wave effect animation
            withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: false)) {
                patternWave = 100
            }
            
            // Glow pulsing effect
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(1.2)) {
                glowIntensity = 0.15
            }
            
            // Text shimmer effect
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: false).delay(1.5)) {
                textShimmer = true
            }
            
            // Continuous subtle animations
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(1.5)) {
                isPatternAnimated = true
                pulsate = true
            }
            
            // Transition to main app after animations
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 0.7)) {
                    showMainView = true
                }
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
