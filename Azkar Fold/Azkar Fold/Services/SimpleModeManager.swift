//
//  SimpleModeManager.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI
import Combine

/// A reusable manager for handling simple mode functionality
class SimpleModeManager: ObservableObject {
    @Published var isSimpleMode: Bool
    @Published var autoAdvanceEnabled: Bool = true
    @Published var autoAdvanceDelay: TimeInterval = 0.5
    
    private var autoAdvanceTimer: Timer?
    
    init(initialMode: Bool = false) {
        self.isSimpleMode = initialMode
    }
    
    /// Toggle simple mode with animation
    func toggleSimpleMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isSimpleMode.toggle()
        }
    }
    
    /// Enable simple mode with animation
    func enableSimpleMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isSimpleMode = true
        }
    }
    
    /// Disable simple mode with animation
    func disableSimpleMode() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isSimpleMode = false
        }
    }
    
    /// Set simple mode directly without animation (for initialization)
    func setSimpleMode(_ enabled: Bool, animated: Bool = false) {
        if animated {
            withAnimation(.easeInOut(duration: 0.3)) {
                isSimpleMode = enabled
            }
        } else {
            isSimpleMode = enabled
        }
    }
    
    /// Schedule auto advance action
    func scheduleAutoAdvance(action: @escaping () -> Void) {
        guard autoAdvanceEnabled else { return }
        
        // Cancel any existing timer
        autoAdvanceTimer?.invalidate()
        
        // Schedule new timer
        autoAdvanceTimer = Timer.scheduledTimer(withTimeInterval: autoAdvanceDelay, repeats: false) { _ in
            DispatchQueue.main.async {
                action()
            }
        }
    }
    
    /// Cancel scheduled auto advance
    func cancelAutoAdvance() {
        autoAdvanceTimer?.invalidate()
        autoAdvanceTimer = nil
    }
    
    deinit {
        cancelAutoAdvance()
    }
}

//MARK: - Simple Mode Configuration
struct SimpleModeConfig {
    
    let autoAdvanceDelay: TimeInterval
    let longPressMinimumDuration: Double
    let animationDuration: Double
    
    static let `default` = SimpleModeConfig(
        autoAdvanceEnabled: true,
        autoAdvanceDelay: 0.5,
        longPressMinimumDuration: 0.8,
        animationDuration: 0.3
    )
    
    static let quick = SimpleModeConfig(
        autoAdvanceEnabled: true,
        autoAdvanceDelay: 0.2,
        longPressMinimumDuration: 0.5,
        animationDuration: 0.2
    )
    
    static let slow = SimpleModeConfig(
        autoAdvanceEnabled: true,
        autoAdvanceDelay: 1.0,
        longPressMinimumDuration: 1.2,
        animationDuration: 0.5
    )
    
    static let manual = SimpleModeConfig(
        autoAdvanceEnabled: false,
        autoAdvanceDelay: 0.0,
        longPressMinimumDuration: 0.8,
        animationDuration: 0.3
    )
    
    // Initializer matching the usage in static properties
    init(autoAdvanceEnabled: Bool, autoAdvanceDelay: TimeInterval, longPressMinimumDuration: Double, animationDuration: Double) {
        self.autoAdvanceDelay = autoAdvanceDelay
        self.longPressMinimumDuration = longPressMinimumDuration
        self.animationDuration = animationDuration
    }
}

//MARK: - Simple Mode View Modifier
struct SimpleModeModifier: ViewModifier {
    let isSimpleMode: Bool
    let onToggle: () -> Void
    let longPressDuration: Double
    
    func body(content: Content) -> some View {
        content
            .onLongPressGesture(minimumDuration: longPressDuration) {
                onToggle()
            }
    }
}

//MARK: - View Extension for Simple Mode
extension View {
    func addSimpleModeToggle(
        isSimpleMode: Bool,
        longPressDuration: Double = 0.8,
        onToggle: @escaping () -> Void
    ) -> some View {
        self.modifier(SimpleModeModifier(
            isSimpleMode: isSimpleMode,
            onToggle: onToggle,
            longPressDuration: longPressDuration
        ))
    }
}

