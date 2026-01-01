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
            // Fetch and activate
            let status = try await remoteConfig.fetchAndActivate()
            print("Remote Config fetched: \(status)")
            
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
        
        // Force Update Logic:
        // If current version is less than minimum required version, force update.
        if isVersion(currentVersion, lessThan: minVersion) {
            return .forceUpdate(requiredVersion: minVersion, currentVersion: currentVersion)
        }
        
        // Optional Update Logic:
        // If current version is less than latest version (but >= min version), optional update.
        if isVersion(currentVersion, lessThan: latestVersion) {
            return .optionalUpdate(availableVersion: latestVersion, currentVersion: currentVersion)
        }
        
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
        return version1.compare(version2, options: .numeric) == .orderedAscending
    }
}

