//
//  ClipboardItemTests.swift
//  ClipAura
//
//  Created by Ömer Murat Aydın on 26.05.2025.
//

import XCTest
@testable import ClipAura

class ClipboardItemTests: XCTestCase {

    // MARK: - Text Item Tests

    func testTextItemCreation() {
        // Given
        let content = "Hello, World!"

        // When
        let item = ClipboardItem(content: content, type: .text)

        // Then
        XCTAssertEqual(item.content, content)
        XCTAssertEqual(item.type, .text)
        XCTAssertNil(item.imageData)
        XCTAssertNotNil(item.id)
    }

    func testTextItemPreview() {
        // Given
        let shortText = "Short text"
        let longText = "This is a very long text that should be truncated because it exceeds the preview limit"

        // When
        let shortItem = ClipboardItem(content: shortText, type: .text)
        let longItem = ClipboardItem(content: longText, type: .text)

        // Then
        XCTAssertEqual(shortItem.preview, shortText)
        XCTAssertTrue(longItem.preview.hasSuffix("..."))
        XCTAssertTrue(longItem.preview.count <= 53) // 50 + "..."
    }

    // MARK: - Image Item Tests

    func testImageItemCreation() {
        // Given
        let imageName = "test_image.png"
        let imageData = Data([0x89, 0x50, 0x4E, 0x47]) // PNG header

        // When
        let item = ClipboardItem(content: imageName, type: .image, imageData: imageData, imageName: imageName)

        // Then
        XCTAssertEqual(item.content, imageName)
        XCTAssertEqual(item.type, .image)
        XCTAssertNotNil(item.imageData)
        XCTAssertEqual(item.imageName, imageName)
        XCTAssertEqual(item.preview, imageName)
    }

    func testImageItemSize() {
        // Given
        let imageData = Data(repeating: 0, count: 1024) // 1KB data
        let item = ClipboardItem(content: "test", type: .image, imageData: imageData)

        // When
        let size = item.imageSize

        // Then
        XCTAssertNotNil(size)
        XCTAssertTrue(size!.contains("KB") || size!.contains("bytes"))
    }

    // MARK: - Time Formatting Tests

    func testTimeAgoFormatting() {
        // Given
        let item = ClipboardItem(content: "test", type: .text)

        // When
        let timeAgo = item.timeAgo

        // Then
        XCTAssertTrue(timeAgo.contains("now") || timeAgo.contains("sec") || timeAgo.contains("min"))
    }

    // MARK: - Content Type Tests

    func testContentTypeIcons() {
        // Given & When & Then
        XCTAssertEqual(ClipboardType.text.icon, "doc.text")
        XCTAssertEqual(ClipboardType.code.icon, "curlybraces")
        XCTAssertEqual(ClipboardType.url.icon, "link")
        XCTAssertEqual(ClipboardType.email.icon, "envelope")
        XCTAssertEqual(ClipboardType.image.icon, "photo")
    }

    func testContentTypeColors() {
        // Given & When & Then
        XCTAssertNotNil(ClipboardType.text.color)
        XCTAssertNotNil(ClipboardType.code.color)
        XCTAssertNotNil(ClipboardType.url.color)
        XCTAssertNotNil(ClipboardType.email.color)
        XCTAssertNotNil(ClipboardType.image.color)
    }

    // MARK: - Codable Tests

    func testClipboardItemCodable() throws {
        // Given
        let originalItem = ClipboardItem(content: "Test content", type: .text)

        // When - Encode
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalItem)

        // Then - Decode
        let decoder = JSONDecoder()
        let decodedItem = try decoder.decode(ClipboardItem.self, from: data)

        // Verify
        XCTAssertEqual(originalItem.content, decodedItem.content)
        XCTAssertEqual(originalItem.type, decodedItem.type)
        XCTAssertEqual(originalItem.id, decodedItem.id)
    }

    func testImageItemCodable() throws {
        // Given
        let imageData = Data([0x89, 0x50, 0x4E, 0x47])
        let originalItem = ClipboardItem(content: "image.png", type: .image, imageData: imageData, imageName: "image.png")

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalItem)

        let decoder = JSONDecoder()
        let decodedItem = try decoder.decode(ClipboardItem.self, from: data)

        // Then
        XCTAssertEqual(originalItem.content, decodedItem.content)
        XCTAssertEqual(originalItem.type, decodedItem.type)
        XCTAssertEqual(originalItem.imageData, decodedItem.imageData)
        XCTAssertEqual(originalItem.imageName, decodedItem.imageName)
    }
}
