//
//  FirebaseUpdateService.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import Foundation
import FirebaseRemoteConfig

class FirebaseUpdateService {
    static let shared = FirebaseUpdateService()
    
    private let remoteConfig = RemoteConfig.remoteConfig()
    
    // Remote Config Keys
    private let kMinimumAppVersion = "min_version"
    private let kLatestAppVersion = "latest_version"
    private let kWhatIsNew = "what_is_new"
    
    private init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0 // For development, set to higher value for production
        remoteConfig.configSettings = settings
        
        // Set default values
        let defaults: [String: NSObject] = [
            kMinimumAppVersion: "1.0.0" as NSObject,
            kLatestAppVersion: "1.0.0" as NSObject,
            kWhatIsNew: "" as NSObject
        ]
        remoteConfig.setDefaults(defaults)
    }
    
    func checkForUpdates() async throws -> UpdateStatus {
        do {
            // Force fetch fresh values (bypass cache for debugging/testing)
            // In production, consider a reasonable interval like 3600 (1 hour) or 43200 (12 hours)
            let fetchStatus = try await remoteConfig.fetch(withExpirationDuration: 0)
            print("Remote Config fetch status: \(fetchStatus)")
            
            // Activate the fetched values
            let activationChanged = try await remoteConfig.activate()
            print("Remote Config activation changed: \(activationChanged)")
            
            return evaluateUpdateStatus()
        } catch {
            print("Error fetching remote config: \(error.localizedDescription)")
            // Return current status on error (don't block user)
            return .upToDate
        }
    }
    
    private func evaluateUpdateStatus() -> UpdateStatus {
        let minVersion = remoteConfig[kMinimumAppVersion].stringValue ?? "1.0.0"
        let latestVersion = remoteConfig[kLatestAppVersion].stringValue ?? "1.0.0"
        
        guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return .upToDate
        }
        
        print("Version Check: Current: \(currentVersion), Min: \(minVersion), Latest: \(latestVersion)")
        
        // Force Update Logic:
        // If current version is less than minimum required version, force update.
        if isVersion(currentVersion, lessThan: minVersion) {
            print("Result: Force Update Required")
            return .forceUpdate(requiredVersion: minVersion, currentVersion: currentVersion)
        }
        
        // Optional Update Logic:
        // If current version is less than latest version (but >= min version), optional update.
        if isVersion(currentVersion, lessThan: latestVersion) {
            print("Result: Optional Update Available")
            return .optionalUpdate(availableVersion: latestVersion, currentVersion: currentVersion)
        }
        
        print("Result: App is Up to Date")
        return .upToDate
    }
    
    func getAppStoreURL() -> URL? {
        // Fallback or construct if ID is available (implementation specific)
        // For now returning nil if not configured
        return nil
    }
    
    func getWhatIsNew() -> String {
        return remoteConfig[kWhatIsNew].stringValue ?? ""
    }
    
    // MARK: - Version Comparison Helper
    
    private func isVersion(_ version1: String, lessThan version2: String) -> Bool {
        let v1Components = version1.split(separator: ".").compactMap { Int($0) }
        let v2Components = version2.split(separator: ".").compactMap { Int($0) }
        
        let maxLength = max(v1Components.count, v2Components.count)
        
        for i in 0..<maxLength {
            let v1Value = i < v1Components.count ? v1Components[i] : 0
            let v2Value = i < v2Components.count ? v2Components[i] : 0
            
            if v1Value < v2Value {
                return true
            } else if v1Value > v2Value {
                return false
            }
        }
        
        // If we reach here, versions are equal
        return false
    }
}

