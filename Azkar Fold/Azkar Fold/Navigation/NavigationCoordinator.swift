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
    case azkarDetail(id: String)
    case settings
    case about
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
            AzkarDetailView(id: id)
        case .settings:
            SettingsView()
        case .about:
            AboutView()
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Home View")
                .font(.largeTitle)
            
            Button("Go to Azkar List") {
                coordinator.navigate(to: .azkarList)
            }
            .buttonStyle(.borderedProminent)
            
            Button("Go to Settings") {
                coordinator.navigate(to: .settings)
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Home")
    }
}

struct AzkarListView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Azkar List")
                .font(.largeTitle)
            
            Button("View Morning Azkar") {
                coordinator.navigate(to: .azkarDetail(id: "morning"))
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Azkar List")
    }
}

struct AzkarDetailView: View {
    let id: String
    
    var body: some View {
        VStack {
            Text("Azkar Detail: \(id)")
                .font(.largeTitle)
        }
        .navigationTitle("Azkar Detail")
    }
}

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings View")
                .font(.largeTitle)
        }
        .navigationTitle("Settings")
    }
}

struct AboutView: View {
    var body: some View {
        VStack {
            Text("About View")
                .font(.largeTitle)
        }
        .navigationTitle("About")
    }
}
