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
                } else {
                    VStack(spacing: 0) {
                        Text("Azkary")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(theme.currentTheme.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.bottom, 8)

                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(zekrStore.zekrs) { zekr in
                                    ZekrRowView(
                                        zekr: zekr,
                                        onDelete: {
                                            indexSetToDelete = IndexSet([zekrStore.zekrs.firstIndex(of: zekr)!])
                                            showingDeleteAlert = true
                                        },
                                        onTap: {
                                            coordinator.navigate(to: .azkarDetail(id: zekr.id))
                                        },
                                        isAlertPresented: $showingDeleteAlert
                                    )
                                    .padding(.horizontal, 16)
                                }
                            }
                            .padding(.bottom, 16)
                        }
                    }
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(BackgroundView())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        coordinator.navigate(to: .createZekr)
                    }) {
                        Text("Create")
                    }
                }
            }
        }
    }
}
