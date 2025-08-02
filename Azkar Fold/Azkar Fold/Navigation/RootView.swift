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
    @StateObject private var purchaseManager = PurchaseManager()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    ViewFactory.viewFor(route: route)
                }
        }
        .environmentObject(coordinator)
        .environmentObject(zekrStore)
        .environmentObject(themeManager)
        .environmentObject(patternManager)
        .environmentObject(progressStore)
        .environmentObject(purchaseManager)
        
        // this should be related to if user not premium and trying to access premium
        .task {
            await purchaseManager.loadProducts()
        }
    }
}

#Preview {
    RootView()
}
