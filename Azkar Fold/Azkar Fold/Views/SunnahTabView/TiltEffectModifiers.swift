//
//  TiltEffectModifiers.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

//MARK: - Basic 3D Tilt Effect Modifier
struct TiltEffect3D: ViewModifier {
    @EnvironmentObject var motionManager: CoreMotionManager
    let animationResponse: Double
    let dampingFraction: Double
    
    init(
        animationResponse: Double = 0.3,
        dampingFraction: Double = 0.8
    ) {
        self.animationResponse = animationResponse
        self.dampingFraction = dampingFraction
    }
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                Angle(radians: motionManager.tiltPitch),
                axis: (x: 1.0, y: 0.0, z: 0.0)
            )
            .rotation3DEffect(
                Angle(radians: -motionManager.tiltRoll),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            .animation(.spring(response: animationResponse, dampingFraction: dampingFraction), value: motionManager.tiltPitch)
            .animation(.spring(response: animationResponse, dampingFraction: dampingFraction), value: motionManager.tiltRoll)
    }
}

//MARK: - Enhanced 3D Tilt Effect with Perspective
struct EnhancedTiltEffect3D: ViewModifier {
    @EnvironmentObject var motionManager: CoreMotionManager
    let perspectiveIntensity: Double
    let shadowIntensity: Double
    let animationResponse: Double
    let dampingFraction: Double
    
    init(
        perspectiveIntensity: Double = 0.001,
        shadowIntensity: Double = 0.3,
        animationResponse: Double = 0.3,
        dampingFraction: Double = 0.8
    ) {
        self.perspectiveIntensity = perspectiveIntensity
        self.shadowIntensity = shadowIntensity
        self.animationResponse = animationResponse
        self.dampingFraction = dampingFraction
    }
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                Angle(radians: motionManager.tiltPitch),
                axis: (x: 1.0, y: 0.0, z: 0.0),
                perspective: perspectiveIntensity
            )
            .rotation3DEffect(
                Angle(radians: -motionManager.tiltRoll),
                axis: (x: 0.0, y: 1.0, z: 0.0),
                perspective: perspectiveIntensity
            )
            .shadow(
                color: .black.opacity(shadowIntensity * abs(motionManager.tiltRoll + motionManager.tiltPitch)),
                radius: 8,
                x: CGFloat(motionManager.tiltRoll * 10),
                y: CGFloat(motionManager.tiltPitch * 10)
            )
            .animation(.spring(response: animationResponse, dampingFraction: dampingFraction), value: motionManager.tiltPitch)
            .animation(.spring(response: animationResponse, dampingFraction: dampingFraction), value: motionManager.tiltRoll)
    }
}

//MARK: - Floating Card Tilt Effect
struct FloatingCardTiltEffect: ViewModifier {
    @EnvironmentObject var motionManager: CoreMotionManager
    let floatIntensity: Double
    let animationResponse: Double
    let dampingFraction: Double
    
    init(
        floatIntensity: Double = 5.0,
        animationResponse: Double = 0.4,
        dampingFraction: Double = 0.9
    ) {
        self.floatIntensity = floatIntensity
        self.animationResponse = animationResponse
        self.dampingFraction = dampingFraction
    }
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                Angle(radians: motionManager.tiltPitch),
                axis: (x: 1.0, y: 0.0, z: 0.0)
            )
            .rotation3DEffect(
                Angle(radians: -motionManager.tiltRoll),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            .offset(
                x: CGFloat(-motionManager.tiltRoll * floatIntensity),
                y: CGFloat(-motionManager.tiltPitch * floatIntensity)
            )
            .scaleEffect(1.0 + (abs(motionManager.tiltPitch) + abs(motionManager.tiltRoll)) * 0.05)
            .animation(.spring(response: animationResponse, dampingFraction: dampingFraction), value: motionManager.tiltPitch)
            .animation(.spring(response: animationResponse, dampingFraction: dampingFraction), value: motionManager.tiltRoll)
    }
}

//MARK: - View Extensions for Easy Usage
extension View {
    /// Apply basic 3D tilt effect
    func add3DTiltEffect(
        animationResponse: Double = 0.3,
        dampingFraction: Double = 0.8
    ) -> some View {
        self.modifier(TiltEffect3D(
            animationResponse: animationResponse,
            dampingFraction: dampingFraction
        ))
    }
    
    /// Apply enhanced 3D tilt effect with perspective and shadow
    func addEnhanced3DTiltEffect(
        perspectiveIntensity: Double = 0.001,
        shadowIntensity: Double = 0.3,
        animationResponse: Double = 0.3,
        dampingFraction: Double = 0.8
    ) -> some View {
        self.modifier(EnhancedTiltEffect3D(
            perspectiveIntensity: perspectiveIntensity,
            shadowIntensity: shadowIntensity,
            animationResponse: animationResponse,
            dampingFraction: dampingFraction
        ))
    }
    
    /// Apply floating card tilt effect
    func addFloatingCardTiltEffect(
        floatIntensity: Double = 5.0,
        animationResponse: Double = 0.4,
        dampingFraction: Double = 0.9
    ) -> some View {
        self.modifier(FloatingCardTiltEffect(
            floatIntensity: floatIntensity,
            animationResponse: animationResponse,
            dampingFraction: dampingFraction
        ))
    }
}

//MARK: - Tilt Effect Presets
enum TiltEffectPreset {
    case subtle
    case normal
    case dramatic
    case floating
    
    var animationResponse: Double {
        switch self {
        case .subtle: return 0.5
        case .normal: return 0.3
        case .dramatic: return 0.2
        case .floating: return 0.4
        }
    }
    
    var dampingFraction: Double {
        switch self {
        case .subtle: return 0.9
        case .normal: return 0.8
        case .dramatic: return 0.7
        case .floating: return 0.9
        }
    }
}

//MARK: - Preset-based View Extension
extension View {
    func addTiltEffect(
        preset: TiltEffectPreset = .normal
    ) -> some View {
        switch preset {
        case .subtle:
            return AnyView(self.add3DTiltEffect(
                animationResponse: preset.animationResponse,
                dampingFraction: preset.dampingFraction
            ))
        case .normal:
            return AnyView(self.add3DTiltEffect(
                animationResponse: preset.animationResponse,
                dampingFraction: preset.dampingFraction
            ))
        case .dramatic:
            return AnyView(self.addEnhanced3DTiltEffect(
                animationResponse: preset.animationResponse,
                dampingFraction: preset.dampingFraction
            ))
        case .floating:
            return AnyView(self.addFloatingCardTiltEffect(
                animationResponse: preset.animationResponse,
                dampingFraction: preset.dampingFraction
            ))
        }
    }
}

