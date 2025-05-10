//
//  LaunchScreenView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct LaunchScreenView: View {
    // Animation state management
    @State private var animationState = AnimationState()
    @State private var showMainView = false
    
    // Animation timing controller
    private let timingCurve = Animation.interpolatingSpring(mass: 1.0, stiffness: 100, damping: 10)
    
    var body: some View {
        ZStack {
            // Base layer
            Color.appBackground
                .ignoresSafeArea()
            
            // Enhanced pattern background with depth layers
            backgroundLayers
            
            // Content layers with staggered animations
            contentLayers
        }
        .onAppear(perform: triggerAnimationSequence)
        .onChange(of: animationState.finalAnimationComplete) { complete in
            if complete {
                transitionToMainApp()
            }
        }
    }
    
    // MARK: - View Components
    
    private var backgroundLayers: some View {
        ZStack {
            // Deep background layer with slow movement
            patternLayer(scale: 1.2, opacity: 0.3, offsetY: -10, blurRadius: 15, movementRange: 8)
                .scaleEffect(animationState.backgroundScale)
                .opacity(animationState.backgroundOpacity)
            
            // Mid layer with medium movement
            patternLayer(scale: 1.1, opacity: 0.4, offsetY: 0, blurRadius: 5, movementRange: 5)
                .scaleEffect(animationState.midgroundScale)
                .opacity(animationState.midgroundOpacity)
                .rotationEffect(Angle(degrees: animationState.patternRotation * 1.5))
            
            // Foreground pattern with sharper details
            patternLayer(scale: 1.0, opacity: 0.5, offsetY: 5, blurRadius: 0, movementRange: 3)
                .scaleEffect(animationState.foregroundScale)
                .opacity(animationState.foregroundOpacity)
                .rotationEffect(Angle(degrees: animationState.patternRotation))
                
            // Glow overlay that pulses
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.appPrimary.opacity(animationState.glowIntensity * 0.2))
                .blur(radius: 30)
                .blendMode(.screen)
                .ignoresSafeArea()
        }
    }
    
    private func patternLayer(scale: CGFloat, opacity: Double, offsetY: CGFloat, blurRadius: CGFloat, movementRange: CGFloat) -> some View {
        Image("launch_pattern")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .foregroundColor(Color.appPrimary)
            .scaleEffect(scale)
            .blur(radius: blurRadius)
            .offset(y: offsetY + (animationState.patternMovement ? movementRange : -movementRange))
            .opacity(opacity)
            .overlay(
                // Dynamic wave effect overlay
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.appPrimary.opacity(0.1))
                    .scaleEffect(1.2)
                    .offset(x: animationState.patternWave, y: 0)
                    .blendMode(.overlay)
                    .opacity(opacity * 0.7)
            )
    }
    
    private var contentLayers: some View {
        VStack(spacing: 30) {
            // Logo container with enhanced neo-brutalism styling
            ZStack {
                // Shadow element with slight offset for depth
                Rectangle()
                    .fill(Color.black.opacity(0.6))
                    .frame(width: 120, height: 120)
                    .offset(x: 6, y: 6)
                    .opacity(animationState.logoOpacity * 0.8)
                
                // Main container with crisp edges
                Rectangle()
                    .fill(Color.appBackground)
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(animationState.logoRotation))
                    .scaleEffect(animationState.logoPulse ? 1.05 : 1.0)
                    .opacity(animationState.logoOpacity)
                
                // Logo icon with refined animation
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.appPrimary)
                    .scaleEffect(animationState.logoScale)
                    .opacity(animationState.logoIconOpacity)
                    .rotationEffect(.degrees(animationState.logoIconRotation))
                
                // Subtle accent lines for design flair
                ForEach(0..<4) { index in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.appPrimary.opacity(0.7))
                        .frame(width: 40, height: 2)
                        .offset(y: 50)
                        .rotationEffect(.degrees(Double(index) * 90))
                        .scaleEffect(animationState.accentLinesScale)
                        .opacity(animationState.accentLinesOpacity)
                }
            }
            .shadow(color: .black.opacity(animationState.logoOpacity * 0.2), radius: 0, x: 2, y: 2)
            
            VStack(spacing: 12) {
                // App title with refined animation
                Text("Azkar Fold")
                    .font(.system(size: 42, weight: .black))
                    .foregroundColor(.appPrimary)
                    .opacity(animationState.titleOpacity)
                    .offset(y: animationState.titleOffset)
                    .shadow(color: .black.opacity(0.2), radius: 0, x: 2, y: 2)
                    .overlay(
                        // Advanced shimmer effect
                        shimmerOverlay(text: "Azkar Fold", fontSize: 42)
                    )
                
                // Subtitle with staggered animation
                Text("Your Daily Islamic Remembrance")
                    .font(.headline)
                    .foregroundColor(.appPrimary.opacity(0.8))
                    .opacity(animationState.subtitleOpacity)
                    .offset(y: animationState.subtitleOffset)
                    .overlay(
                        // Subtle shimmer for subtitle
                        shimmerOverlay(text: "Your Daily Islamic Remembrance", fontSize: 17)
                            .opacity(0.7)
                    )
                
                // Progress indicator that appears last
                ProgressView()
                    .scaleEffect(0.8)
                    .opacity(animationState.progressIndicatorOpacity)
                    .padding(.top, 20)
            }
        }
        .padding()
    }
    
    private func shimmerOverlay(text: String, fontSize: CGFloat) -> some View {
        Text(text)
            .font(.system(size: fontSize, weight: .black))
            .foregroundColor(Color.white.opacity(0.7))
            .mask(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .white.opacity(0.8), .clear]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: animationState.shimmerWidth)
                .offset(x: animationState.shimmerOffset)
            )
    }
    
    // MARK: - Animation Sequence
    
    private func triggerAnimationSequence() {
        // Background elements animation (0.0s - 0.8s)
        withAnimation(timingCurve.speed(0.7).delay(0.1)) {
            animationState.backgroundOpacity = 1.0
            animationState.backgroundScale = 1.05
        }
        
        withAnimation(timingCurve.speed(0.8).delay(0.3)) {
            animationState.midgroundOpacity = 1.0
            animationState.midgroundScale = 1.02
        }
        
        withAnimation(timingCurve.speed(0.9).delay(0.5)) {
            animationState.foregroundOpacity = 1.0
            animationState.foregroundScale = 1.0
        }
        
        // Logo container animation (0.8s - 1.5s)
        withAnimation(.easeOut(duration: 0.6).delay(0.8)) {
            animationState.logoOpacity = 1.0
            animationState.logoRotation = -3
        }
        
        // Logo icon reveal (1.2s - 1.8s)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.2)) {
            animationState.logoScale = 1.0
            animationState.logoIconOpacity = 1.0
            animationState.logoIconRotation = 360
        }
        
        // Accent lines animation (1.5s - 2.0s)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.5)) {
            animationState.accentLinesScale = 1.0
            animationState.accentLinesOpacity = 1.0
        }
        
        // Title animation (1.8s - 2.3s)
        withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(1.8)) {
            animationState.titleOpacity = 1.0
            animationState.titleOffset = 0
        }
        
        // Subtitle animation (2.0s - 2.5s)
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(2.0)) {
            animationState.subtitleOpacity = 1.0
            animationState.subtitleOffset = 0
        }
        
        // Progress indicator (2.5s - 3.0s)
        withAnimation(.easeIn(duration: 0.6).delay(2.5)) {
            animationState.progressIndicatorOpacity = 1.0
        }
        
        // Continuous animations
        setupContinuousAnimations()
        
        // Final transition preparation
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            animationState.finalAnimationComplete = true
        }
    }
    
    private func setupContinuousAnimations() {
        // Pattern movement animation
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(0.8)) {
            animationState.patternMovement = true
        }
        
        // Pattern rotation
        withAnimation(.easeInOut(duration: 12.0).repeatForever(autoreverses: true).delay(1.0)) {
            animationState.patternRotation = 5
        }
        
        // Wave effect animation
        withAnimation(.easeInOut(duration: 8.0).repeatForever(autoreverses: false).delay(1.2)) {
            animationState.patternWave = 150
        }
        
        // Glow pulsing effect
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(1.5)) {
            animationState.glowIntensity = 1.0
        }
        
        // Logo pulse animation
        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true).delay(1.8)) {
            animationState.logoPulse = true
        }
        
        // Shimmer effect animation (with seamless loop)
        animateShimmerEffect()
    }
    
    private func animateShimmerEffect() {
        // Create a seamless shimmer animation
        withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
            animationState.shimmerOffset = 300
        }
    }
    
    private func transitionToMainApp() {
        withAnimation(.easeInOut(duration: 0.7)) {
            showMainView = true
        }
    }
}


struct AnimationState {
    // Background layers
    var backgroundOpacity: Double = 0.0
    var backgroundScale: CGFloat = 0.9
    var midgroundOpacity: Double = 0.0
    var midgroundScale: CGFloat = 0.92
    var foregroundOpacity: Double = 0.0
    var foregroundScale: CGFloat = 0.95
    
    // Pattern animations
    var patternMovement: Bool = false
    var patternRotation: Double = 0.0
    var patternWave: CGFloat = -50
    var glowIntensity: Double = 0.0
    
    // Logo animations
    var logoOpacity: Double = 0.0
    var logoRotation: Double = 0.0
    var logoScale: CGFloat = 0.5
    var logoIconOpacity: Double = 0.0
    var logoIconRotation: Double = 0.0
    var logoPulse: Bool = false
    
    // Accent elements
    var accentLinesScale: CGFloat = 0.0
    var accentLinesOpacity: Double = 0.0
    
    // Text animations
    var titleOpacity: Double = 0.0
    var titleOffset: CGFloat = 20
    var subtitleOpacity: Double = 0.0
    var subtitleOffset: CGFloat = 30
    
    // Shimmer effect
    var shimmerOffset: CGFloat = -100
    var shimmerWidth: CGFloat = 50
    
    // Progress indicator
    var progressIndicatorOpacity: Double = 0.0
    
    // Animation completion flag
    var finalAnimationComplete: Bool = false
}

#Preview {
    LaunchScreenView()
}
