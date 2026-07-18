//
//  WhatsNewManager.swift
//  Azkar Fold
//
//  Created by Ahmed AlTahhan on 18/07/2026.
//  Copyright © 2026 Ahmed AlTahhan. All rights reserved.
//

import SwiftUI
import Combine

/// One-time post-install / post-update overlay for the current marketing version.
final class WhatsNewManager: ObservableObject {
    static let shared = WhatsNewManager()

    @Published var isPresented = false

    private let storageKey = "whatsNew.lastSeenVersion"

    private init() {}

    @MainActor
    func evaluate(forceUpdateShowing: Bool) {
        guard !forceUpdateShowing else {
            isPresented = false
            return
        }

        let current = AppConfiguration.marketingVersion
        let lastSeen = UserDefaults.standard.string(forKey: storageKey)
        guard lastSeen != current else {
            isPresented = false
            return
        }

        isPresented = true
    }

    func dismiss() {
        UserDefaults.standard.set(AppConfiguration.marketingVersion, forKey: storageKey)
        isPresented = false
        FirebaseTelemetry.logEvent(FirebaseTelemetry.Event.whatsNewDismiss)
    }
}
