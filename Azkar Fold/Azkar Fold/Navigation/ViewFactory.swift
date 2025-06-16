//
//  ViewFactory.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct ViewFactory {
    
    @ViewBuilder
    static func viewFor(route: Route) -> some View {
        switch route {
        case .home:
            HomeView()
        case .azkarDetail(let id):
            ZekrView(zekrId: id)
        case .createZekr:
            CreateZekrView()
        case .azkaryTab:
            AzkaryTabView()
        case .sunnahTab:
            SunnahTabView()
        case .settingsTab:
            SettingsTabView()
        }
    }
}
