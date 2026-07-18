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
    @StateObject private var whatsNewManager = WhatsNewManager.shared
    @StateObject private var appLanguage = AppLanguageManager.shared

    var body: some View {
        ZStack {
        NavigationStack(path: $coordinator.path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    ViewFactory.viewFor(route: route)
                    }
            }
            
            // Overlays
            if whatsNewManager.isPresented && !updateManager.showForceUpdate {
                WhatsNewOverlayView(
                    changes: [
                        appLanguage.text("whats_new.feature.prayer_tab"),
                        appLanguage.text("whats_new.feature.tab_settings"),
                        appLanguage.text("whats_new.feature.prayer_widget"),
                        appLanguage.text("whats_new.feature.share_qr")
                    ],
                    onDismiss: whatsNewManager.dismiss
                )
                .zIndex(90)
            }

            if updateManager.showOptionalUpdate && !whatsNewManager.isPresented {
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
        .environmentObject(whatsNewManager)
        .environmentObject(appLanguage)
        .environment(\.locale, appLanguage.locale)
        .environment(\.layoutDirection, appLanguage.layoutDirection)
        .id(appLanguage.refreshID)
    }
}

#Preview {
    RootView()
}
