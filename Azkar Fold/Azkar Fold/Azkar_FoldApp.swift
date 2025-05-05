//
//  Azkar_FoldApp.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 02/05/2025.
//

import SwiftUI
import Combine

@main
struct Azkar_FoldApp: App {
    @State private var showLaunchScreen = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .opacity(showLaunchScreen ? 0 : 1)
                
                if showLaunchScreen {
                    LaunchScreenView()
                        .transition(.opacity)
                        .onAppear {
                            // Dismiss launch screen after animations complete
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                withAnimation(.easeInOut(duration: 0.7)) {
                                    showLaunchScreen = false
                                }
                            }
                        }
                }
            }
        }
    }
}
