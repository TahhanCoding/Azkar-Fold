//
//  UpdateManager.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI
import Combine

class UpdateManager: ObservableObject {
    static let shared = UpdateManager()

    @Published var updateStatus: UpdateStatus = .upToDate
    @Published var showForceUpdate: Bool = false
    @Published var showOptionalUpdate: Bool = false

    @Published var requiredVersion: String = ""
    @Published var availableVersion: String = ""
    @Published var currentVersion: String = ""
    @Published var whatIsNew: String = ""

    private let updateService = FirebaseUpdateService.shared

    private init() {}

    @MainActor
    func checkForUpdates() async {
        do {
            let status = try await updateService.checkForUpdates()
            self.updateStatus = status
            self.whatIsNew = updateService.getWhatIsNew()
            self.handleUpdateStatus(status)
        } catch {
            AzkarDebugLog.log("Error checking updates: \(error)")
        }
    }

    private func handleUpdateStatus(_ status: UpdateStatus) {
        switch status {
        case .forceUpdate(let required, let current):
            guard AppConfiguration.isAppStoreConfigured else {
                AzkarDebugLog.log("Force update suppressed: App Store ID not configured")
                showForceUpdate = false
                showOptionalUpdate = false
                return
            }
            requiredVersion = required
            currentVersion = current
            showForceUpdate = true
            showOptionalUpdate = false

        case .optionalUpdate(let available, let current):
            availableVersion = available
            currentVersion = current
            showForceUpdate = false
            showOptionalUpdate = true

        case .upToDate:
            showForceUpdate = false
            showOptionalUpdate = false
        }
    }

    func dismissOptionalUpdate() {
        showOptionalUpdate = false
    }

    func openAppStore() {
        if let url = updateService.getAppStoreURL() {
            UIApplication.shared.open(url)
        } else {
            AzkarDebugLog.log("App Store URL not configured — set AppConfiguration.appStoreID")
        }
    }
}
