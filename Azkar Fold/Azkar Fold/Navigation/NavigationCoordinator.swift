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

struct HomeView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    var body: some View {
        TabView {
            AzkaryTabView()
                .tabItem {
                    Label("Azkary", systemImage: "heart.fill")
                }
                .tag(0)
            
            SunnahTabView()
                .tabItem {
                    Label("Sunnah", systemImage: "book.fill")
                }
                .tag(1)
            
            SettingsTabView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .accentColor(.purple) // Neo-brutalism vibrant color
    }
}

struct AzkaryTabView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    @StateObject private var zekrStore = ZekrStore()
    
    var body: some View {
        NavigationView {
            VStack {
                if zekrStore.zekrs.isEmpty {
                    EmptyZekrView()
                } else {
                    List {
                        ForEach(zekrStore.zekrs) { zekr in
                            ZekrRowView(zekr: zekr)
                                .onTapGesture {
                                    coordinator.navigate(to: .azkarDetail(id: zekr.id))
                                }
                        }
                        .onDelete(perform: zekrStore.deleteZekr)
                    }
                }
            }
            .navigationTitle("My Azkar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        coordinator.navigate(to: .createZekr)
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.purple)
                    }
                }
            }
            .background(
                Image("islamic_pattern")
                    .resizable(resizingMode: .tile)
                    .opacity(0.05)
            )
        }
        .environmentObject(zekrStore)
    }
}

struct ZekrRowView: View {
    let zekr: Zekr
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(zekr.text)
                    .font(.headline)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                Text("Last updated: \(formattedDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(zekr.counter)")
                .font(.title)
                .fontWeight(.black)
                .foregroundColor(.purple)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.purple.opacity(0.1))
                )
        }
        .padding(.vertical, 8)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: zekr.lastUpdated)
    }
}

struct EmptyZekrView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 80))
                .foregroundColor(.purple.opacity(0.7))
            
            Text("No custom Azkar created yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Tap the + button to create your first Zekr")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                coordinator.navigate(to: .createZekr)
            }) {
                Text("Create Zekr")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.purple)
                    .cornerRadius(8)
            }
            .padding(.top, 10)
        }
        .padding()
    }
}

struct ZekrView: View {
    let zekrId: UUID
    @EnvironmentObject var zekrStore: ZekrStore
    @State private var animateCounter = false
    
    var zekr: Zekr? {
        zekrStore.zekrs.first(where: { $0.id == zekrId })
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Upper half - Zekr text
                VStack {
                    if let zekr = zekr {
                        Text(zekr.text)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        Text("Zekr not found")
                            .font(.title)
                            .foregroundColor(.red)
                    }
                }
                .frame(height: geometry.size.height / 2)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.purple.opacity(0.1))
                )
                
                // Lower half - Counter
                VStack {
                    if let zekr = zekr {
                        Text("\(zekr.counter)")
                            .font(.system(size: 80, weight: .black, design: .rounded))
                            .foregroundColor(.purple)
                            .scaleEffect(animateCounter ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animateCounter)
                    }
                    
                    Text("Tap to count")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 5)
                }
                .frame(height: geometry.size.height / 2)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    if let zekr = zekr {
                        zekrStore.updateCounter(for: zekr.id)
                        animateCounter = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            animateCounter = false
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 0)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: -2)
                )
            }
            .navigationTitle("Zekr Counter")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                Image("islamic_pattern")
                    .resizable(resizingMode: .tile)
                    .opacity(0.05)
            )
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}


struct SettingsTabView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings View")
                    .font(.largeTitle)
                    .foregroundColor(.purple) // Neo-brutalism vibrant color
                    .fontWeight(.bold) // Bold typography
            }
            .navigationTitle("Settings")
            .background(
                Image("islamic_pattern")
                    .resizable(resizingMode: .tile)
                    .opacity(0.05)
            )
        }
    }
}
