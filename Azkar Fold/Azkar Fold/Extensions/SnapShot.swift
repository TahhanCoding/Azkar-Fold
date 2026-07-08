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

private enum ZekrExportFontCalculator {
    static let appFontSize: CGFloat = 28
    static let minimumFontSize: CGFloat = 12

    static let outerHorizontalPadding: CGFloat = 21
    static let textHorizontalPadding: CGFloat = 16
    static let textVerticalPadding: CGFloat = 12
    static let cardHorizontalPadding: CGFloat = 18
    static let cardVerticalPadding: CGFloat = 12

    static func exportFontSize(for text: String, isSimpleMode: Bool) -> CGFloat {
        let width = textWidth(for: UIScreen.main.bounds.width)
        let maxHeight = maxTextHeight(isSimpleMode: isSimpleMode)

        guard !text.isEmpty, width > 0, maxHeight > 0 else { return appFontSize }

        if measuredTextHeight(text, fontSize: appFontSize, width: width) <= maxHeight {
            return appFontSize
        }

        var low = minimumFontSize
        var high = appFontSize
        var bestFit = minimumFontSize

        while high - low > 0.25 {
            let mid = (low + high) / 2
            if measuredTextHeight(text, fontSize: mid, width: width) <= maxHeight {
                bestFit = mid
                low = mid
            } else {
                high = mid
            }
        }

        return floor(bestFit * 2) / 2
    }

    static func maxCardHeight(isSimpleMode: Bool) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        return isSimpleMode ? screenHeight * 0.75 : screenHeight * 0.65
    }

    private static func textWidth(for screenWidth: CGFloat) -> CGFloat {
        screenWidth
            - (outerHorizontalPadding * 2)
            - (cardHorizontalPadding * 2)
            - (textHorizontalPadding * 2)
    }

    private static func maxTextHeight(isSimpleMode: Bool) -> CGFloat {
        maxCardHeight(isSimpleMode: isSimpleMode)
            - (cardVerticalPadding * 2)
            - (textVerticalPadding * 2)
    }

    private static func measuredTextHeight(_ text: String, fontSize: CGFloat, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        let bounds = (text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return ceil(bounds.height)
    }
}

struct ExportableZekrCard: View {
    let text: String
    let isCompleted: Bool
    let isSimpleMode: Bool
    let appearance: ZekrShareAppearance

    static let cornerRadius: CGFloat = 33
    static let outerHorizontalPadding: CGFloat = 21

    private let textHorizontalPadding: CGFloat = 16
    private let textVerticalPadding: CGFloat = 12
    private let cardHorizontalPadding: CGFloat = 18
    private let cardVerticalPadding: CGFloat = 12

    private var maxCardHeight: CGFloat {
        ZekrExportFontCalculator.maxCardHeight(isSimpleMode: isSimpleMode)
    }

    private var exportFontSize: CGFloat {
        ZekrExportFontCalculator.exportFontSize(for: text, isSimpleMode: isSimpleMode)
    }

    var body: some View {
        VStack(spacing: 12) {
            cardShell {
                zekrLabel
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: maxCardHeight, alignment: .top)
            .fixedSize(horizontal: false, vertical: true)

            Text(AppConfiguration.repositoryDisplayLabel)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(appearance.text.opacity(0.6))
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, Self.outerHorizontalPadding)
        .padding(.vertical, 24)
    }

    private var zekrLabel: some View {
        Text(text)
            .font(.system(size: exportFontSize, weight: .bold))
            .foregroundColor(appearance.text)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, textHorizontalPadding)
            .padding(.vertical, textVerticalPadding)
    }

    @ViewBuilder
    private func cardShell<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, cardHorizontalPadding)
            .padding(.vertical, cardVerticalPadding)
            .frame(maxWidth: .infinity, alignment: .top)
            .background(
                ZekrCardBackground(
                    background: appearance.background,
                    patternName: appearance.patternName,
                    isCompleted: isCompleted,
                    cornerRadius: Self.cornerRadius
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous))
    }
}

struct ExportableZekrShareCanvas: View {
    let text: String
    let isCompleted: Bool
    let isSimpleMode: Bool
    let appearance: ZekrShareAppearance

    var body: some View {
        ZStack {
            appearance.background
                .ignoresSafeArea()

            ExportableZekrCard(
                text: text,
                isCompleted: isCompleted,
                isSimpleMode: isSimpleMode,
                appearance: appearance
            )
        }
    }
}

@MainActor
func renderZekrShareURL(
    text: String,
    isCompleted: Bool,
    isSimpleMode: Bool,
    theme: ThemeManager,
    patternManager: PatternManager
) -> URL? {
    guard let image = renderZekrImage(
        text: text,
        isCompleted: isCompleted,
        isSimpleMode: isSimpleMode,
        theme: theme,
        patternManager: patternManager
    ),
    let pngData = image.pngData() else { return nil }

    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent("azkar-share-\(UUID().uuidString).png")

    do {
        try pngData.write(to: url, options: .atomic)
        return url
    } catch {
        return nil
    }
}

@MainActor
func renderZekrImage(
    text: String,
    isCompleted: Bool,
    isSimpleMode: Bool,
    theme: ThemeManager,
    patternManager: PatternManager
) -> UIImage? {
    let appearance = ZekrShareAppearance(theme: theme, patternManager: patternManager)

    let exportView = ExportableZekrShareCanvas(
        text: text,
        isCompleted: isCompleted,
        isSimpleMode: isSimpleMode,
        appearance: appearance
    )

    return snapshotRoundedSwiftUIView(
        exportView,
        cornerRadius: ExportableZekrCard.cornerRadius
    )
}

@MainActor
private func snapshotRoundedSwiftUIView<V: View>(
    _ view: V,
    cornerRadius: CGFloat
) -> UIImage? {
    let screenWidth = UIScreen.main.bounds.width

    let hostingController = UIHostingController(rootView: view)
    hostingController.view.backgroundColor = .clear
    hostingController.overrideUserInterfaceStyle = .light

    guard let hostedView = hostingController.view else { return nil }

    let proposedSize = CGSize(width: screenWidth, height: CGFloat.greatestFiniteMagnitude)
    let measuredSize: CGSize
    if #available(iOS 16.0, *) {
        measuredSize = hostingController.sizeThatFits(in: proposedSize)
    } else {
        hostedView.frame = CGRect(origin: .zero, size: proposedSize)
        hostedView.layoutIfNeeded()
        measuredSize = hostedView.systemLayoutSizeFitting(
            proposedSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    let size = CGSize(
        width: max(measuredSize.width, 1),
        height: max(measuredSize.height, 1)
    )

    let container = UIView(frame: CGRect(origin: .zero, size: size))
    container.backgroundColor = .clear

    let maskLayer = CAShapeLayer()
    maskLayer.frame = CGRect(origin: .zero, size: size)
    maskLayer.path = UIBezierPath(
        roundedRect: CGRect(origin: .zero, size: size),
        cornerRadius: cornerRadius
    ).cgPath
    container.layer.mask = maskLayer

    hostedView.backgroundColor = .clear
    hostedView.frame = container.bounds
    hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    container.addSubview(hostedView)

    let window = UIWindow(frame: CGRect(origin: .zero, size: size))
    window.screen = UIScreen.main
    window.backgroundColor = .clear
    window.overrideUserInterfaceStyle = .light
    window.isHidden = false

    let rootController = UIViewController()
    rootController.view.backgroundColor = .clear
    rootController.overrideUserInterfaceStyle = .light
    rootController.view.frame = CGRect(origin: .zero, size: size)
    rootController.view.addSubview(container)
    container.frame = rootController.view.bounds
    window.rootViewController = rootController

    window.layoutIfNeeded()
    container.layoutIfNeeded()
    hostedView.layoutIfNeeded()

    let format = UIGraphicsImageRendererFormat()
    format.opaque = true
    format.scale = UIScreen.main.scale
    format.preferredRange = .standard

    let image = UIGraphicsImageRenderer(size: size, format: format).image { _ in
        container.drawHierarchy(in: CGRect(origin: .zero, size: size), afterScreenUpdates: true)
    }

    window.isHidden = true
    window.rootViewController = nil

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
