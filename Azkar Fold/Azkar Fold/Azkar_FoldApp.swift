//
//  Azkar_FoldApp.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 02/05/2025.
//

import SwiftUI
import Combine
import FirebaseCore

@main
struct Azkar_FoldApp: App {
    @StateObject private var appLanguage = AppLanguageManager.shared
    @State private var showLaunchScreen = true
    
    init() {
        FirebaseApp.configure()
        AzkarFont.registerIfNeeded()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .opacity(showLaunchScreen ? 0 : 1)
                
                if showLaunchScreen {
                    LaunchScreenView()
                        .environmentObject(ThemeManager.shared)
                        .environmentObject(PatternManager.shared)
                        .environmentObject(appLanguage)
                        .environment(\.locale, appLanguage.locale)
                        .environment(\.layoutDirection, appLanguage.layoutDirection)
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
            .onChange(of: showLaunchScreen) { newValue in
                if !newValue {
                    // Trigger update check when launch screen dismisses
                    Task {
                        await UpdateManager.shared.checkForUpdates()
                    }
                }
            }
            .onOpenURL { url in
                AppDeepLink.handle(url)
            }
        }
    }
}
