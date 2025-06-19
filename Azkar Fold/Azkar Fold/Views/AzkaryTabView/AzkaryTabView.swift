//
//  SettingsTabView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct AzkaryTabView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var zekrStore: ZekrStore
    @State private var showingDeleteAlert = false
    @State private var indexSetToDelete: IndexSet?
    
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
                            .foregroundColor(theme.currentTheme.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        List {
                            ForEach(zekrStore.zekrs) { zekr in
                                ZekrRowView(zekr: zekr,
                                            onDelete: {
                                                indexSetToDelete = IndexSet([zekrStore.zekrs.firstIndex(of: zekr)!])
                                                showingDeleteAlert = true
                                            },
                                            onTap: {
                                                coordinator.navigate(to: .azkarDetail(id: zekr.id))
                                            },
                                            isAlertPresented: $showingDeleteAlert)
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets())
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                            }
                        }
                        .listStyle(PlainListStyle())

                        Spacer()
                    }
                    .background(
                        Image("islamic_pattern")
                            .resizable(resizingMode: .tile)
                            .opacity(0.55)
                            .ignoresSafeArea(.all)
                    )
                    .background(
                        theme.currentTheme.background.ignoresSafeArea(.all)
                    )
                    .alert(isPresented: $showingDeleteAlert) {
                        Alert(
                            title: Text("Confirm Deletion"),
                            message: Text("Are you sure you want to delete this Zekr?"),
                            primaryButton: .destructive(Text("Delete").foregroundColor(.red)) {
                                if let indexSet = indexSetToDelete {
                                    zekrStore.deleteZekr(at: indexSet)
                                }
                                indexSetToDelete = nil
                            },
                            secondaryButton: .cancel(Text("Cancel").foregroundColor(theme.currentTheme.text)) {
                                indexSetToDelete = nil
                            }
                        )
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        coordinator.navigate(to: .createZekr)
                    }) {
                        Text("Create")
                            .font(.headline)
                            .foregroundColor(theme.currentTheme.buttonText)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(theme.currentTheme.primary)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}
