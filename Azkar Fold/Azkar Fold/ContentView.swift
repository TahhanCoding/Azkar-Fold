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
        VStack {
            Text("Welcome to Azkar Fold")
                .font(.largeTitle)
                .padding()
            
            Button("Start Navigation") {
                coordinator.navigate(to: .azkarList)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(NavigationCoordinator())
}
