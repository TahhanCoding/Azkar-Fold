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
    
    // Stored properties for UI display
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
            print("Error checking updates: \(error)")
        }
    }
    
    private func handleUpdateStatus(_ status: UpdateStatus) {
        switch status {
        case .forceUpdate(let required, let current):
            self.requiredVersion = required
            self.currentVersion = current
            self.showForceUpdate = true
            self.showOptionalUpdate = false
            
        case .optionalUpdate(let available, let current):
            self.availableVersion = available
            self.currentVersion = current
            self.showForceUpdate = false
            self.showOptionalUpdate = true
            
        case .upToDate:
            self.showForceUpdate = false
            self.showOptionalUpdate = false
        }
    }
    
    func dismissOptionalUpdate() {
        showOptionalUpdate = false
    }
    
    func openAppStore() {
        if let url = updateService.getAppStoreURL() {
            UIApplication.shared.open(url)
        } else {
            // Fallback: Search on App Store or open developer page if known
            // For now, let's log
            print("App Store URL not configured")
        }
    }
}

