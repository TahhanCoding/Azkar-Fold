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
                .foregroundColor(.blue) // Vibrant color
                .fontWeight(.bold) // Bold typography
            
            Button("Go to Azkar List") {
                coordinator.navigate(to: .azkarList)
            }
            .buttonStyle(.borderedProminent)
            .foregroundColor(.red) // Vibrant color
            
            Button("Go to Settings") {
                coordinator.navigate(to: .settings)
            }
            .buttonStyle(.borderedProminent)
            .foregroundColor(.green) // Vibrant color
        }
        .navigationTitle("Home")
        .background(Color.gray.opacity(0.1)) // Raw aesthetic
    }
}

struct AzkarListView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Azkar List")
                .font(.largeTitle)
                .foregroundColor(.blue) // Vibrant color
                .fontWeight(.bold) // Bold typography
            
            Button("View Morning Azkar") {
                coordinator.navigate(to: .azkarDetail(id: "morning"))
            }
            .buttonStyle(.borderedProminent)
            .foregroundColor(.red) // Vibrant color
        }
        .navigationTitle("Azkar List")
        .background(Color.gray.opacity(0.1)) // Raw aesthetic
    }
}

struct AzkarDetailView: View {
    let id: String
    
    var body: some View {
        VStack {
            Text("Azkar Detail: \(id)")
                .font(.largeTitle)
                .foregroundColor(.blue) // Vibrant color
                .fontWeight(.bold) // Bold typography
        }
        .navigationTitle("Azkar Detail")
        .background(Color.gray.opacity(0.1)) // Raw aesthetic
    }
}

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings View")
                .font(.largeTitle)
                .foregroundColor(.blue) // Vibrant color
                .fontWeight(.bold) // Bold typography
        }
        .navigationTitle("Settings")
        .background(Color.gray.opacity(0.1)) // Raw aesthetic
    }
}

struct AboutView: View {
    var body: some View {
        VStack {
            Text("About View")
                .font(.largeTitle)
                .foregroundColor(.blue) // Vibrant color
                .fontWeight(.bold) // Bold typography
        }
        .navigationTitle("About")
        .background(Color.gray.opacity(0.1)) // Raw aesthetic
    }
}
