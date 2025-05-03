//
//  AzkarListView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 02/05/2025.
//

import SwiftUI

struct AzkarListView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    @EnvironmentObject var zekrStore: ZekrStore
    
    var body: some View {
        VStack {
            if zekrStore.zekrs.isEmpty {
                EmptyZekrView()
            } else {
                List {
                    ForEach(zekrStore.zekrs) { zekr in
                        ZekrRowView(zekr: zekr)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                coordinator.navigate(to: .azkarDetail(id: zekr.id))
                            }
                    }
                    .onDelete(perform: zekrStore.deleteZekr)
                }
            }
        }
        .navigationTitle("Azkar List")
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

#Preview {
    NavigationView {
        AzkarListView()
            .environmentObject(NavigationCoordinator())
            .environmentObject(ZekrStore())
    }
}