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
    }
}
