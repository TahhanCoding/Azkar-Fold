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
    @StateObject private var progressStore = SunnahProgressStore()

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
        .environmentObject(progressStore)
    }
}

#Preview {
    RootView()
}
