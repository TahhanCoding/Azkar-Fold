//
//  NavigationCoordinator.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 02/05/2025.
//

import SwiftUI

// Define all possible navigation destinations in the app
enum Route: Hashable {
    case home
    case azkarList
    case azkarDetail(id: UUID)
    case createZekr
    case settings
    case about
    
    // Tab views
    case azkaryTab
    case sunnahTab
    case settingsTab
}

// Coordinator class that manages navigation state
@MainActor
class NavigationCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    // Navigate to a specific route
    func navigate(to route: Route) {
        path.append(route)
    }
    
    // Go back one level
    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    // Go back to root
    func goToRoot() {
        path = NavigationPath()
    }
    
    // Handle deep links
    func handleDeepLink(_ url: URL) {
        // Parse URL and navigate accordingly
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
        
        switch components.path {
        case "/azkar":
            navigate(to: .azkarList)
        case "/settings":
            navigate(to: .settings)
        case "/about":
            navigate(to: .about)
        default:
            goToRoot()
        }
    }
}

// Factory to create views based on routes
struct ViewFactory {
    @ViewBuilder
    static func viewFor(route: Route) -> some View {
        switch route {
        case .home:
            HomeView()
        case .azkarList:
            AzkarListView()
        case .azkarDetail(let id):
            ZekrView(zekrId: id)
        case .createZekr:
            CreateZekrView()
        case .settings:
            SettingsView()
        case .about:
            AboutView()
        case .azkaryTab:
            AzkaryTabView()
        case .sunnahTab:
            SunnahTabView()
        case .settingsTab:
            SettingsTabView()
        }
    }
}



