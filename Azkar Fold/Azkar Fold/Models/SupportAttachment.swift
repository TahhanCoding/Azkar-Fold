//
//  SupportAttachment.swift
//  Azkar Fold
//
//  Created by Ahmed Shaban on 07/07/2026.
//

import Foundation
import UniformTypeIdentifiers

struct SupportAttachment: Identifiable, Equatable {
    let id = UUID()
    let fileName: String
    let mimeType: String
    let data: Data
}

enum SupportAttachmentError: LocalizedError {
    case unreadableFile
    case fileTooLarge(maxMegabytes: Int)
    case failedToLoad

    var errorDescription: String? {
        switch self {
        case .unreadableFile:
            return "The selected file could not be read."
        case .fileTooLarge(let maxMegabytes):
            return "Attachments must be \(maxMegabytes) MB or smaller."
        case .failedToLoad:
            return "The attachment could not be loaded."
        }
    }
}

enum SupportAttachmentLoader {
    static let maxAttachmentBytes = 20 * 1024 * 1024
    static let maxMegabytes = 20

    static func fromURL(_ url: URL) throws -> SupportAttachment {
        let didAccess = url.startAccessingSecurityScopedResource()
        defer {
            if didAccess {
                url.stopAccessingSecurityScopedResource()
            }
        }

        let data = try Data(contentsOf: url)
        try validateSize(data)

        let fileName = url.lastPathComponent
        let mimeType = mimeType(for: url) ?? "application/octet-stream"
        return SupportAttachment(fileName: fileName, mimeType: mimeType, data: data)
    }

    static func make(data: Data, contentType: UTType) throws -> SupportAttachment {
        try validateSize(data)
        let fileName = suggestedFileName(for: contentType)
        let mimeType = contentType.preferredMIMEType ?? "application/octet-stream"
        return SupportAttachment(fileName: fileName, mimeType: mimeType, data: data)
    }

    private static func validateSize(_ data: Data) throws {
        guard data.count <= maxAttachmentBytes else {
            throw SupportAttachmentError.fileTooLarge(maxMegabytes: maxMegabytes)
        }
    }

    private static func suggestedFileName(for contentType: UTType) -> String {
        let id = UUID().uuidString
        if contentType.conforms(to: .movie) || contentType.conforms(to: .video) {
            return "attachment-\(id).mov"
        }
        if contentType.conforms(to: .png) {
            return "attachment-\(id).png"
        }
        if contentType.conforms(to: .image) {
            return "attachment-\(id).jpg"
        }
        if let ext = contentType.preferredFilenameExtension {
            return "attachment-\(id).\(ext)"
        }
        return "attachment-\(id).dat"
    }

    private static func mimeType(for url: URL) -> String? {
        if let type = UTType(filenameExtension: url.pathExtension),
           let mime = type.preferredMIMEType {
            return mime
        }
        return mimeType(forExtension: url.pathExtension)
    }

    private static func mimeType(forExtension ext: String) -> String? {
        UTType(filenameExtension: ext)?.preferredMIMEType
    }
}
