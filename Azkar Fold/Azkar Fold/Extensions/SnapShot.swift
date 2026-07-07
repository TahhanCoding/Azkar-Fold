//
//  SnapShot.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 08/07/2025.
//

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var completion: UIActivityViewController.CompletionWithItemsHandler?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.completionWithItemsHandler = completion
        configurePopover(for: controller)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}

    private func configurePopover(for controller: UIActivityViewController) {
        guard let popover = controller.popoverPresentationController,
              let sourceView = topViewController()?.view else { return }
        popover.sourceView = sourceView
        popover.sourceRect = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
        popover.permittedArrowDirections = []
    }
}

struct ExportableZekrCard: View {
    let text: String
    let theme: ThemeManager
    let patternManager: PatternManager

    var body: some View {
        VStack(spacing: 20) {
            Text(text)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(theme.currentTheme.text)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)

            Text("azkarfold.com")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(theme.currentTheme.text.opacity(0.6))
        }
        .padding(.vertical, 32)
        .frame(width: 350)
        .background(
            ZStack {
                theme.currentTheme.background

                if patternManager.currentPattern != "none" {
                    Image(patternManager.currentPattern)
                        .resizable(resizingMode: .tile)
                        .opacity(0.35)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

@MainActor
func renderZekrImage(text: String, theme: ThemeManager, patternManager: PatternManager) -> UIImage? {
    let exportView = ExportableZekrCard(
        text: text,
        theme: theme,
        patternManager: patternManager
    )

    let renderer = ImageRenderer(content: exportView)
    renderer.scale = UIScreen.main.scale

    guard let image = renderer.uiImage else { return nil }
    return image
}

@MainActor
func presentShareSheet(
    activityItems: [Any],
    completion: UIActivityViewController.CompletionWithItemsHandler? = nil
) {
    guard let presenter = topViewController() else { return }

    let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    controller.completionWithItemsHandler = completion

    if let popover = controller.popoverPresentationController {
        popover.sourceView = presenter.view
        popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 0, height: 0)
        popover.permittedArrowDirections = []
    }

    presenter.present(controller, animated: true)
}

private func topViewController(base: UIViewController? = nil) -> UIViewController? {
    let root = base ?? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }?
            .rootViewController
    }()

    if let navigation = root as? UINavigationController {
        return topViewController(base: navigation.visibleViewController)
    }
    if let tab = root as? UITabBarController {
        return topViewController(base: tab.selectedViewController)
    }
    if let presented = root?.presentedViewController {
        return topViewController(base: presented)
    }
    return root
}
