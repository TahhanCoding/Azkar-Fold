//
//  ContentView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 02/05/2025.
//

import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    
    var body: some View {
        // Redirect to the main HomeView with tab navigation
        HomeView()
    }
}

#Preview {
    ContentView()
        .environmentObject(NavigationCoordinator())
}
