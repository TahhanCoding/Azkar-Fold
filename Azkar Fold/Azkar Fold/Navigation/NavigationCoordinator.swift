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
