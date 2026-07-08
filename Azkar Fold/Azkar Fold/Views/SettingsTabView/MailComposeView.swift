//
//  MailComposeView.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 07/07/2026.
//

import MessageUI
import SwiftUI
import UIKit

struct MailComposeData: Identifiable {
    let id = UUID()
    let recipients: [String]
    let subject: String
    let body: String
    let attachments: [SupportAttachment]
}

struct MailComposeView: UIViewControllerRepresentable {
    let data: MailComposeData
    let onFinish: (Result<MFMailComposeResult, Error>) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinish: onFinish)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = context.coordinator
        controller.setToRecipients(data.recipients)
        controller.setSubject(data.subject)
        controller.setMessageBody(data.body, isHTML: false)

        for attachment in data.attachments {
            controller.addAttachmentData(
                attachment.data,
                mimeType: attachment.mimeType,
                fileName: attachment.fileName
            )
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onFinish: (Result<MFMailComposeResult, Error>) -> Void

        init(onFinish: @escaping (Result<MFMailComposeResult, Error>) -> Void) {
            self.onFinish = onFinish
        }

        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            if let error {
                onFinish(.failure(error))
            } else {
                onFinish(.success(result))
            }
        }
    }
}

enum SupportMailComposer {
    static let supportEmail = AppConfiguration.supportEmail
    static var subject: String {
        L10n.t("support.subject")
    }

    static var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }

    static func composeBody(message: String, appVersion: String, locale: Locale = AppLanguageManager.shared.locale) -> String {
        let device = UIDevice.current
        let appName = L10n.t("app.name", locale: locale)
        return """
        \(message)

        —

        \(L10n.t("support.mail_body.app", locale: locale, appName))
        \(L10n.t("support.mail_body.version", locale: locale, appVersion))
        \(L10n.t("support.mail_body.ios", locale: locale, device.systemVersion))
        \(L10n.t("support.mail_body.device", locale: locale, device.model))
        """
    }
}
