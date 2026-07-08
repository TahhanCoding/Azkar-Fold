//
//  CoreMotionManager.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import Foundation
import CoreMotion
import Combine

/// A reusable CoreMotion manager that provides device tilt data for 3D effects
class CoreMotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    
    @Published var tiltPitch: Double = 0.0
    @Published var tiltRoll: Double = 0.0
    @Published var isActive: Bool = false
    
    // Configurable properties
    var maxTiltAngle: Double = 0.175 // ~10 degrees in radians
    var motionSensitivity: Double = 0.5
    var updateInterval: TimeInterval = 0.1 // 10Hz for smooth 60fps experience
    
    /// Start motion updates with optional configuration
    func startMotionUpdates(
        sensitivity: Double? = nil,
        maxAngle: Double? = nil,
        interval: TimeInterval? = nil
    ) {
        guard motionManager.isDeviceMotionAvailable else {
            AzkarDebugLog.log("CoreMotionManager: Device motion not available")
            return
        }
        
        // Apply optional configuration
        if let sensitivity = sensitivity { motionSensitivity = sensitivity }
        if let maxAngle = maxAngle { maxTiltAngle = maxAngle }
        if let interval = interval { updateInterval = interval }
        
        motionManager.deviceMotionUpdateInterval = updateInterval
        
        // Stop any existing updates before starting new ones to avoid conflicts
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
        
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion, error == nil else {
                // Silently handle errors - CoreMotion may log system warnings that are harmless
                // Only log actual errors that prevent functionality
                if let error = error as NSError?,
                   error.domain != "NSCocoaErrorDomain" || error.code != 257 {
                    // Only log non-permission errors (257 is the permission error code)
                    AzkarDebugLog.log("CoreMotionManager error: \(error.localizedDescription)")
                }
                return
            }
            
            let pitch = motion.attitude.pitch * self.motionSensitivity
            let roll = motion.attitude.roll * self.motionSensitivity
            
            // Clamp the values to prevent excessive rotation
            self.tiltPitch = max(-self.maxTiltAngle, min(self.maxTiltAngle, pitch))
            self.tiltRoll = max(-self.maxTiltAngle, min(self.maxTiltAngle, roll))
            
            if !self.isActive {
                self.isActive = true
            }
        }
    }
    
    /// Stop motion updates and reset values
    func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
        tiltPitch = 0.0
        tiltRoll = 0.0
        isActive = false
    }
    
    /// Reset tilt values to zero (useful for recalibration)
    func resetTiltValues() {
        tiltPitch = 0.0
        tiltRoll = 0.0
    }
    
    deinit {
        stopMotionUpdates()
    }
}

//MARK: - Configuration Struct
struct MotionConfig {
    let sensitivity: Double
    let maxAngle: Double
    let updateInterval: TimeInterval
    
    static let `default` = MotionConfig(
        sensitivity: 0.5,
        maxAngle: 0.175,
        updateInterval: 0.1
    )
    
    static let subtle = MotionConfig(
        sensitivity: 0.3,
        maxAngle: 0.1,
        updateInterval: 0.1
    )
    
    static let dramatic = MotionConfig(
        sensitivity: 0.8,
        maxAngle: 0.3,
        updateInterval: 0.05
    )
}

