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
                    VStack {
                        Text("Azkary")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        ScrollView {
                            VStack {
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
                            .padding(.horizontal, 10)
                            .padding(.top, 18)
                        }
                        Spacer()
                    }
                    .background(
                        Color.appBackground.ignoresSafeArea(.all)
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        coordinator.navigate(to: .createZekr)
                    }) {
                        Text("Create")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.appPrimary)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}
