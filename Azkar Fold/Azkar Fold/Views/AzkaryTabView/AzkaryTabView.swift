//
//  AzkaryTabView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 03/05/2025.
//

import SwiftUI

struct AzkaryTabView: View {
    @EnvironmentObject var coordinator: NavigationCoordinator
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var appLanguage: AppLanguageManager
    @EnvironmentObject var zekrStore: ZekrStore
    @State private var showingDeleteAlert = false
    @State private var indexSetToDelete: IndexSet?
    
    
    var body: some View {
        VStack(spacing: 0) {
            headerView

            if zekrStore.zekrs.isEmpty {
                EmptyZekrView()
            } else {
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
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text(appLanguage.text("azkary.delete_confirm_title")),
                        message: Text(appLanguage.text("azkary.delete_confirm_message")),
                        primaryButton: .destructive(Text(appLanguage.text("common.delete")).foregroundColor(.red)) {
                            if let indexSet = indexSetToDelete {
                                zekrStore.deleteZekr(at: indexSet)
                            }
                            indexSetToDelete = nil
                        },
                        secondaryButton: .cancel(Text(appLanguage.text("common.cancel")).foregroundColor(theme.currentTheme.text)) {
                            indexSetToDelete = nil
                        }
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundView())
    }

    private var headerView: some View {
        HStack {
            Text(appLanguage.text("azkary.title"))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(theme.currentTheme.text)

            Spacer()

            Button {
                coordinator.navigate(to: .createZekr)
            } label: {
                Text(appLanguage.text("azkary.create"))
                    .font(.headline)
                    .foregroundColor(theme.currentTheme.primary)
            }
            .accessibilityLabel(appLanguage.text("azkary.create_title"))
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}
