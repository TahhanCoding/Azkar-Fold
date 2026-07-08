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

    private let kMinimumAppVersion = "min_version"
    private let kLatestAppVersion = "latest_version"
    private let kWhatIsNew = "what_is_new"

    private init() {
        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0
        #else
        settings.minimumFetchInterval = 43_200
        #endif
        remoteConfig.configSettings = settings

        let defaults: [String: NSObject] = [
            kMinimumAppVersion: AppConfiguration.marketingVersion as NSObject,
            kLatestAppVersion: AppConfiguration.marketingVersion as NSObject,
            kWhatIsNew: "" as NSObject
        ]
        remoteConfig.setDefaults(defaults)
    }

    func checkForUpdates() async throws -> UpdateStatus {
        do {
            #if DEBUG
            let expiration: TimeInterval = 0
            #else
            let expiration: TimeInterval = 3_600
            #endif

            let fetchStatus = try await remoteConfig.fetch(withExpirationDuration: expiration)
            AzkarDebugLog.log("Remote Config fetch status: \(fetchStatus)")

            let activationChanged = try await remoteConfig.activate()
            AzkarDebugLog.log("Remote Config activation changed: \(activationChanged)")

            return evaluateUpdateStatus()
        } catch {
            AzkarDebugLog.log("Error fetching remote config: \(error.localizedDescription)")
            return .upToDate
        }
    }

    private func evaluateUpdateStatus() -> UpdateStatus {
        let minVersion = remoteConfig[kMinimumAppVersion].stringValue ?? AppConfiguration.marketingVersion
        let latestVersion = remoteConfig[kLatestAppVersion].stringValue ?? AppConfiguration.marketingVersion

        let currentVersion = AppConfiguration.marketingVersion

        AzkarDebugLog.log("Version Check: Current: \(currentVersion), Min: \(minVersion), Latest: \(latestVersion)")

        if isVersion(currentVersion, lessThan: minVersion) {
            AzkarDebugLog.log("Result: Force Update Required")
            return .forceUpdate(requiredVersion: minVersion, currentVersion: currentVersion)
        }

        if isVersion(currentVersion, lessThan: latestVersion) {
            AzkarDebugLog.log("Result: Optional Update Available")
            return .optionalUpdate(availableVersion: latestVersion, currentVersion: currentVersion)
        }

        AzkarDebugLog.log("Result: App is Up to Date")
        return .upToDate
    }

    func getAppStoreURL() -> URL? {
        AppConfiguration.appStoreURL
    }

    func getWhatIsNew() -> String {
        remoteConfig[kWhatIsNew].stringValue ?? ""
    }

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

        return false
    }
}
