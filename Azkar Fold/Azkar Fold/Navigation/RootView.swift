//
//  RootView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 02/05/2025.
//

import SwiftUI

struct RootView: View {
    @StateObject private var coordinator = NavigationCoordinator()
    @StateObject private var zekrStore = ZekrStore()
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var patternManager = PatternManager.shared
    @StateObject private var progressStore = SunnahProgressStore()
    @StateObject private var coreMotionManager = CoreMotionManager()
    @StateObject private var updateManager = UpdateManager.shared

    var body: some View {
        ZStack {
            NavigationStack(path: $coordinator.path) {
                HomeView()
                    .navigationDestination(for: Route.self) { route in
                        ViewFactory.viewFor(route: route)
                    }
            }
            
            // Overlays
            if updateManager.showOptionalUpdate {
                OptionalUpdateAlertView(updateManager: updateManager)
                    .zIndex(100)
            }
            
            if updateManager.showForceUpdate {
                ForceUpdateModalView(updateManager: updateManager)
                    .zIndex(200) // Higher zIndex to ensure it's on top
            }
        }
        .environmentObject(coordinator)
        .environmentObject(zekrStore)
        .environmentObject(themeManager)
        .environmentObject(patternManager)
        .environmentObject(progressStore)
        .environmentObject(coreMotionManager)
        .environmentObject(updateManager)
    }
}

#Preview {
    RootView()
}
