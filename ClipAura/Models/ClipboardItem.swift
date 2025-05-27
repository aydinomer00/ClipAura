//
//  ClipboardItem.swift
//  ClipAura
//
//  Created by Ömer Murat Aydın on 25.05.2025.
//

import Foundation
import SwiftUI
import AppKit

struct ClipboardItem: Identifiable, Codable {
    let id: UUID
    let content: String
    let timestamp: Date
    let type: ClipboardType
    let imageData: Data?
    let imageName: String?

    init(content: String, type: ClipboardType, imageData: Data? = nil, imageName: String? = nil) {
        self.id = UUID()
        self.content = content
        self.timestamp = Date()
        self.type = type
        self.imageData = imageData
        self.imageName = imageName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        type = try container.decode(ClipboardType.self, forKey: .type)
        imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        imageName = try container.decodeIfPresent(String.self, forKey: .imageName)
    }

    private enum CodingKeys: String, CodingKey {
        case id, content, timestamp, type, imageData, imageName
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }

    var preview: String {
        if type == .image {
            return imageName ?? "Image"
        }

        if content.count > 50 {
            return String(content.prefix(50)) + "..."
        }
        return content
    }

    var image: NSImage? {
        guard let imageData = imageData else { return nil }
        return NSImage(data: imageData)
    }

    var imageSize: String? {
        guard let imageData = imageData else { return nil }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(imageData.count))
    }

    var imageDimensions: String? {
        guard let image = image else { return nil }
        let size = image.size
        return "\(Int(size.width)) × \(Int(size.height))"
    }
}

enum ClipboardType: String, Codable, CaseIterable {
    case text = "text"
    case code = "code"
    case url = "url"
    case email = "email"
    case image = "image"

    var icon: String {
        switch self {
        case .text: return "doc.text"
        case .code: return "curlybraces"
        case .url: return "link"
        case .email: return "envelope"
        case .image: return "photo"
        }
    }

    var color: Color {
        switch self {
        case .text: return .blue
        case .code: return .green
        case .url: return .orange
        case .email: return .purple
        case .image: return .pink
        }
    }
}
