//
//  TimedCoachMarkView.swift
//  HRSD
//
//  Created by Ahmed AlTahhan on 08/07/2026.
//  Copyright © 2026 Future Workshops. All rights reserved.
//

import SwiftUI

struct TimedCoachMarkView: View {
    let titleKey: String.LocalizationValue
    let messageKey: String.LocalizationValue
    @Binding var isPresented: Bool
    var duration: TimeInterval = 7
    var onDismiss: (() -> Void)? = nil

    @EnvironmentObject private var appLanguage: AppLanguageManager
    @State private var dismissTask: Task<Void, Never>?

    var body: some View {
        VStack {
            Text(appLanguage.text(titleKey))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 8)

            Text(appLanguage.text(messageKey))
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.7))
        )
        .padding(.horizontal, 20)
        .transition(.opacity.combined(with: .scale))
        .onTapGesture {
            dismiss(animated: true)
        }
        .onAppear {
            dismissTask?.cancel()
            dismissTask = Task {
                try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    dismiss(animated: true)
                }
            }
        }
        .onDisappear {
            dismissTask?.cancel()
            dismissTask = nil
        }
    }

    private func dismiss(animated: Bool) {
        dismissTask?.cancel()
        dismissTask = nil

        if animated {
            withAnimation(.easeInOut(duration: 0.5)) {
                isPresented = false
            }
        } else {
            isPresented = false
        }

        onDismiss?()
    }
}
