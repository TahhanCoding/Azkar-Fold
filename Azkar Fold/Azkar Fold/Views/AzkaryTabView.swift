//
//  SettingsTabView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct AzkaryTabView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    @EnvironmentObject var zekrStore: ZekrStore
    
    var body: some View {
        NavigationView {
            VStack {
                if zekrStore.zekrs.isEmpty {
                    EmptyZekrView()
                        .background(
                               Image("islamic_pattern")
                                   .resizable(resizingMode: .tile)
                                   .opacity(0.55)
                                   .mask(
                                       RadialGradient(
                                           gradient: Gradient(colors: [.white, .clear]),
                                           center: .center,
                                           startRadius: 50,
                                           endRadius: 300
                                       )
                                   )
                           )
                } else {
                    List {
                        ForEach(zekrStore.zekrs) { zekr in
                            ZekrRowView(zekr: zekr)
                                .onTapGesture {
                                    coordinator.navigate(to: .azkarDetail(id: zekr.id))
                                }
                        }
                        .onDelete(perform: zekrStore.deleteZekr)
                        .background(
                            Image("islamic_pattern")
                                .resizable(resizingMode: .tile)
                                .opacity(0.55)
                        )
                    }
                }
            }
            .navigationTitle("My Azkar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        coordinator.navigate(to: .createZekr)
                    }) {
                        Text("Create")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.purple)
                    }
                }
            }
        }
    }
}
