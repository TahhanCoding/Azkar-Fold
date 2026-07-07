//
//  SupportContactSheet.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 07/07/2026.
//

import CoreTransferable
import MessageUI
import PhotosUI
import SwiftUI
import UIKit
import UniformTypeIdentifiers

private struct PickedMedia: Transferable {
    let data: Data
    let contentType: UTType

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            PickedMedia(data: data, contentType: .image)
        }
        DataRepresentation(importedContentType: .movie) { data in
            PickedMedia(data: data, contentType: .movie)
        }
        DataRepresentation(importedContentType: .video) { data in
            PickedMedia(data: data, contentType: .video)
        }
    }
}

struct SupportContactSheet: View {
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.dismiss) private var dismiss

    @State private var message = ""
    @State private var attachments: [SupportAttachment] = []
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var isImportingAttachment = false
    @State private var mailComposeData: MailComposeData?
    @State private var showMailUnavailableAlert = false
    @State private var showResultAlert = false
    @State private var resultAlertTitle = ""
    @State private var resultAlertMessage = ""
    @State private var showFileImporter = false

    private var trimmedMessage: String {
        message.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSend: Bool {
        !trimmedMessage.isEmpty && !isImportingAttachment
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Describe your issue or feedback. You can attach images, videos, or files.")
                        .font(.subheadline)
                        .foregroundColor(theme.currentTheme.text.opacity(0.75))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Message")
                            .font(.headline)
                            .foregroundColor(theme.currentTheme.text)

                        TextEditor(text: $message)
                            .foregroundColor(theme.currentTheme.text)
                            .tint(theme.currentTheme.primary)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 160)
                            .padding(8)
                            .background(theme.currentTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(theme.currentTheme.text.opacity(0.15), lineWidth: 1)
                            )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Attachments")
                            .font(.headline)
                            .foregroundColor(theme.currentTheme.text)

                        HStack(spacing: 12) {
                            PhotosPicker(
                                selection: $selectedPhotoItems,
                                maxSelectionCount: 5,
                                matching: .any(of: [.images, .videos])
                            ) {
                                attachmentPickerButton(title: "Photo or Video", icon: "photo.on.rectangle")
                            }
                            .disabled(isImportingAttachment)

                            Button {
                                showFileImporter = true
                            } label: {
                                attachmentPickerButton(title: "File", icon: "paperclip")
                            }
                            .disabled(isImportingAttachment)
                        }

                        if isImportingAttachment {
                            ProgressView("Adding attachment...")
                                .font(.caption)
                                .foregroundColor(theme.currentTheme.text.opacity(0.7))
                        }

                        if attachments.isEmpty {
                            Text("No attachments added.")
                                .font(.caption)
                                .foregroundColor(theme.currentTheme.text.opacity(0.5))
                        } else {
                            ForEach(attachments) { attachment in
                                attachmentRow(attachment)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(theme.currentTheme.background.ignoresSafeArea())
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(theme.currentTheme.accent)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Send") {
                        submitSupportRequest()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(canSend ? theme.currentTheme.accent : theme.currentTheme.text.opacity(0.35))
                    .disabled(!canSend)
                }
            }
            .onChange(of: selectedPhotoItems) { newItems in
                guard !newItems.isEmpty else { return }
                importPhotoItems(newItems)
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.item],
                allowsMultipleSelection: false
            ) { result in
                importFile(result)
            }
            .sheet(item: $mailComposeData) { data in
                MailComposeView(data: data) { result in
                    mailComposeData = nil
                    handleMailResult(result)
                }
            }
            .alert("Mail Unavailable", isPresented: $showMailUnavailableAlert) {
                Button("Copy Message", role: .none) {
                    copyMessageToClipboard()
                }
                Button("OK", role: .cancel) {}
            } message: {
                Text("Set up a Mail account on this device to send support requests from the app.")
            }
            .alert(resultAlertTitle, isPresented: $showResultAlert) {
                Button("OK", role: .cancel) {
                    if resultAlertTitle == "Message Sent" {
                        dismiss()
                    }
                }
            } message: {
                Text(resultAlertMessage)
            }
        }
    }

    private func attachmentPickerButton(title: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
            Text(title)
                .font(.caption)
        }
        .foregroundColor(theme.currentTheme.primary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(theme.currentTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func attachmentRow(_ attachment: SupportAttachment) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconName(for: attachment.mimeType))
                .foregroundColor(theme.currentTheme.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text(attachment.fileName)
                    .font(.subheadline)
                    .foregroundColor(theme.currentTheme.text)
                    .lineLimit(1)

                Text(formattedFileSize(attachment.data.count))
                    .font(.caption)
                    .foregroundColor(theme.currentTheme.text.opacity(0.5))
            }

            Spacer()

            Button {
                attachments.removeAll { $0.id == attachment.id }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(theme.currentTheme.text.opacity(0.4))
            }
        }
        .padding(12)
        .background(theme.currentTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func submitSupportRequest() {
        guard SupportMailComposer.canSendMail else {
            showMailUnavailableAlert = true
            return
        }

        mailComposeData = MailComposeData(
            recipients: [SupportMailComposer.supportEmail],
            subject: SupportMailComposer.subject,
            body: SupportMailComposer.composeBody(message: trimmedMessage, appVersion: appVersion),
            attachments: attachments
        )
    }

    private func handleMailResult(_ result: Result<MFMailComposeResult, Error>) {
        switch result {
        case .success(let mailResult):
            switch mailResult {
            case .sent:
                resultAlertTitle = "Message Sent"
                resultAlertMessage = "Your support request was sent."
                showResultAlert = true
            case .saved:
                resultAlertTitle = "Message Saved"
                resultAlertMessage = "Your message was saved to Drafts in Mail."
                showResultAlert = true
            case .cancelled:
                break
            case .failed:
                resultAlertTitle = "Send Failed"
                resultAlertMessage = "Mail could not send your message. Please try again."
                showResultAlert = true
            @unknown default:
                break
            }
        case .failure:
            resultAlertTitle = "Send Failed"
            resultAlertMessage = "Mail could not send your message. Please try again."
            showResultAlert = true
        }
    }

    private func loadAttachment(from item: PhotosPickerItem) async throws -> SupportAttachment {
        if let media = try await item.loadTransferable(type: PickedMedia.self) {
            return try SupportAttachmentLoader.make(data: media.data, contentType: media.contentType)
        }

        if let url = try await item.loadTransferable(type: URL.self) {
            return try SupportAttachmentLoader.fromURL(url)
        }

        throw SupportAttachmentError.failedToLoad
    }

    private func importPhotoItems(_ items: [PhotosPickerItem]) {
        isImportingAttachment = true

        Task {
            defer {
                Task { @MainActor in
                    isImportingAttachment = false
                    selectedPhotoItems = []
                }
            }

            for item in items {
                do {
                    let attachment = try await loadAttachment(from: item)
                    await MainActor.run {
                        attachments.append(attachment)
                    }
                } catch {
                    await MainActor.run {
                        showError(error)
                    }
                }
            }
        }
    }

    private func importFile(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            isImportingAttachment = true

            Task {
                defer {
                    Task { @MainActor in
                        isImportingAttachment = false
                    }
                }

                do {
                    let attachment = try SupportAttachmentLoader.fromURL(url)
                    await MainActor.run {
                        attachments.append(attachment)
                    }
                } catch {
                    await MainActor.run {
                        showError(error)
                    }
                }
            }
        case .failure:
            showError(SupportAttachmentError.unreadableFile)
        }
    }

    private func showError(_ error: Error) {
        resultAlertTitle = "Attachment Error"
        resultAlertMessage = error.localizedDescription
        showResultAlert = true
    }

    private func copyMessageToClipboard() {
        let fullMessage = SupportMailComposer.composeBody(message: trimmedMessage, appVersion: appVersion)
        UIPasteboard.general.string = fullMessage
        resultAlertTitle = "Copied"
        resultAlertMessage = "Your message was copied. You can paste it into any Mail app."
        showResultAlert = true
    }

    private func iconName(for mimeType: String) -> String {
        if mimeType.hasPrefix("image/") {
            return "photo"
        }
        if mimeType.hasPrefix("video/") {
            return "video"
        }
        return "doc"
    }

    private func formattedFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

#Preview {
    SupportContactSheet()
        .environmentObject(ThemeManager.shared)
}
