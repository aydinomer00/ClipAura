//
//  ClipboardManagerTests.swift
//  ClipAura
//
//  Created by Ömer Murat Aydın on 26.05.2025.
//

import XCTest
@testable import ClipAura

class ClipboardManagerTests: XCTestCase {

    var clipboardManager: ClipboardManager!

    override func setUp() {
        super.setUp()
        // Clean UserDefaults
        UserDefaults.standard.removeObject(forKey: "SavedClipboardItems")

        clipboardManager = ClipboardManager()
    }

    override func tearDown() {
        clipboardManager = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialState() {
        // Given & When & Then
        XCTAssertTrue(clipboardManager.items.isEmpty)
        XCTAssertEqual(clipboardManager.imageCount, 0)
        XCTAssertEqual(clipboardManager.totalImageSize, 0)
    }

    // MARK: - Content Type Detection Tests

    func testDetectContentType_URL() {
        // Given
        let urlContent = "https://www.apple.com"

        // When
        let detectedType = clipboardManager.detectContentType(urlContent)

        // Then
        XCTAssertEqual(detectedType, .url)
    }

    func testDetectContentType_Email() {
        // Given
        let emailContent = "test@example.com"

        // When
        let detectedType = clipboardManager.detectContentType(emailContent)

        // Then
        XCTAssertEqual(detectedType, .email)
    }

    func testDetectContentType_Code() {
        // Given
        let codeContent = """
        function hello() {
            console.log("Hello World");
        }
        """

        // When
        let detectedType = clipboardManager.detectContentType(codeContent)

        // Then
        XCTAssertEqual(detectedType, .code)
    }

    func testDetectContentType_Text() {
        // Given
        let textContent = "This is just a regular text content"

        // When
        let detectedType = clipboardManager.detectContentType(textContent)

        // Then
        XCTAssertEqual(detectedType, .text)
    }

    func testDetectContentType_SwiftCode() {
        // Given
        let swiftCode = """
        import Foundation
        
        class TestClass {
            var property: String = "test"
        }
        """

        // When
        let detectedType = clipboardManager.detectContentType(swiftCode)

        // Then
        XCTAssertEqual(detectedType, .code)
    }

    func testDetectContentType_HTML() {
        // Given
        let htmlContent = """
        <!DOCTYPE html>
        <html>
        <head><title>Test</title></head>
        <body>Hello World</body>
        </html>
        """

        // When
        let detectedType = clipboardManager.detectContentType(htmlContent)

        // Then
        XCTAssertEqual(detectedType, .code)
    }

    // MARK: - Item Management Tests

    func testAddNewItem() {
        // Given
        let content = "Test content"
        let type = ClipboardType.text
        let newItem = ClipboardItem(content: content, type: type)

        // When
        clipboardManager.addNewItem(newItem)

        // Then
        XCTAssertEqual(clipboardManager.items.count, 1)
        XCTAssertEqual(clipboardManager.items.first?.content, content)
        XCTAssertEqual(clipboardManager.items.first?.type, type)
    }

    func testDeleteItem() {
        // Given
        let item = ClipboardItem(content: "Test", type: .text)
        clipboardManager.addNewItem(item)
        XCTAssertEqual(clipboardManager.items.count, 1)

        // When
        clipboardManager.deleteItem(item)

        // Then
        XCTAssertTrue(clipboardManager.items.isEmpty)
    }

    func testClearAll() {
        // Given
        let item1 = ClipboardItem(content: "Test 1", type: .text)
        let item2 = ClipboardItem(content: "Test 2", type: .text)
        clipboardManager.addNewItem(item1)
        clipboardManager.addNewItem(item2)
        XCTAssertEqual(clipboardManager.items.count, 2)

        // When
        clipboardManager.clearAll()

        // Then
        XCTAssertTrue(clipboardManager.items.isEmpty)
    }

    // MARK: - Filtering Tests

    func testItemsOfType() {
        // Given
        let textItem = ClipboardItem(content: "Text", type: .text)
        let codeItem = ClipboardItem(content: "code", type: .code)
        let urlItem = ClipboardItem(content: "https://apple.com", type: .url)

        clipboardManager.addNewItem(textItem)
        clipboardManager.addNewItem(codeItem)
        clipboardManager.addNewItem(urlItem)

        // When
        let textItems = clipboardManager.items(ofType: .text)
        let codeItems = clipboardManager.items(ofType: .code)
        let imageItems = clipboardManager.items(ofType: .image)

        // Then
        XCTAssertEqual(textItems.count, 1)
        XCTAssertEqual(codeItems.count, 1)
        XCTAssertEqual(imageItems.count, 0)
        XCTAssertEqual(textItems.first?.type, .text)
        XCTAssertEqual(codeItems.first?.type, .code)
    }

    func testSearchItems() {
        // Given
        let item1 = ClipboardItem(content: "Hello World", type: .text)
        let item2 = ClipboardItem(content: "Swift Programming", type: .text)
        let item3 = ClipboardItem(content: "JavaScript Code", type: .code)

        clipboardManager.addNewItem(item1)
        clipboardManager.addNewItem(item2)
        clipboardManager.addNewItem(item3)

        // When
        let worldResults = clipboardManager.searchItems(query: "World")
        let programmingResults = clipboardManager.searchItems(query: "Programming")
        let emptyResults = clipboardManager.searchItems(query: "NotFound")
        let allResults = clipboardManager.searchItems(query: "")

        // Then
        XCTAssertEqual(worldResults.count, 1)
        XCTAssertEqual(programmingResults.count, 1)
        XCTAssertEqual(emptyResults.count, 0)
        XCTAssertEqual(allResults.count, 3)
    }

    func testSearchItemsWithImages() {
        // Given
        let textItem = ClipboardItem(content: "Hello", type: .text)
        let imageItem = ClipboardItem(content: "screenshot", type: .image, imageName: "screenshot.png")

        clipboardManager.addNewItem(textItem)
        clipboardManager.addNewItem(imageItem)

        // When
        let screenshotResults = clipboardManager.searchItems(query: "screenshot")
        let helloResults = clipboardManager.searchItems(query: "Hello")

        // Then
        XCTAssertEqual(screenshotResults.count, 1)
        XCTAssertEqual(helloResults.count, 1)
        XCTAssertEqual(screenshotResults.first?.type, .image)
    }

    // MARK: - Image Statistics Tests

    func testImageCount() {
        // Given
        let textItem = ClipboardItem(content: "Text", type: .text)
        let imageItem1 = ClipboardItem(content: "Image1", type: .image, imageData: Data([1, 2, 3]))
        let imageItem2 = ClipboardItem(content: "Image2", type: .image, imageData: Data([4, 5, 6]))

        // When
        clipboardManager.addNewItem(textItem)
        clipboardManager.addNewItem(imageItem1)
        clipboardManager.addNewItem(imageItem2)

        // Then
        XCTAssertEqual(clipboardManager.imageCount, 2)
    }

    func testTotalImageSize() {
        // Given
        let imageData1 = Data(repeating: 1, count: 100)
        let imageData2 = Data(repeating: 2, count: 200)
        let imageItem1 = ClipboardItem(content: "Image1", type: .image, imageData: imageData1)
        let imageItem2 = ClipboardItem(content: "Image2", type: .image, imageData: imageData2)

        // When
        clipboardManager.addNewItem(imageItem1)
        clipboardManager.addNewItem(imageItem2)

        // Then
        XCTAssertEqual(clipboardManager.totalImageSize, 300)
    }

    // MARK: - Persistence Tests

    func testDataPersistence() {
        // Given
        let item1 = ClipboardItem(content: "Persistent Item 1", type: .text)
        let item2 = ClipboardItem(content: "Persistent Item 2", type: .code)

        // When - Add items and save
        clipboardManager.addNewItem(item1)
        Thread(); 9;        clipboardManager.addNewItem(item2)

        // Create new manager instance to test loading
        let newManager = ClipboardManager()

        // Then
        XCTAssertEqual(newManager.items.count, 2)
        XCTAssertEqual(newManager.items[0].content, "Persistent Item 2") // Most recent first
        XCTAssertEqual(newManager.items[1].content, "Persistent Item 1")
    }

    // MARK: - Export Tests

    func testExportHistory() {
        // Given
        let textItem = ClipboardItem(content: "Hello World", type: .text)
        let imageItem = ClipboardItem(content: "test.png", type: .image, imageName: "test.png")

        clipboardManager.addNewItem(textItem)
        clipboardManager.addNewItem(imageItem)

        // When
        let exportedData = clipboardManager.exportHistory()

        // Then
        XCTAssertTrue(exportedData.contains("Hello World"))
        XCTAssertTrue(exportedData.contains("test.png"))
        XCTAssertTrue(exportedData.contains("[TEXT]"))
        XCTAssertTrue(exportedData.contains("[IMAGE]"))
        XCTAssertTrue(exportedData.contains("---"))
    }

    // MARK: - Settings Integration Tests

    func testMaxItemsLimit() {
        // Given - Set max items to 3
        let settings = Settings()
        settings.maxItems = 3

        // Create new manager with updated settings
        let newManager = ClipboardManager()

        // When - Add 5 items
        for i in 1...5 {
            let item = ClipboardItem(content: "Item \(i)", type: .text)
            newManager.addNewItem(item)
        }

        // Then - Should only keep 3 most recent items
        XCTAssertEqual(newManager.items.count, 3)
        XCTAssertEqual(newManager.items[0].content, "Item 5") // Most recent
        XCTAssertEqual(newManager.items[1].content, "Item 4")
        XCTAssertEqual(newManager.items[2].content, "Item 3")
    }
}

// MARK: - Test Helper Extensions

extension ClipboardManager {
    func addNewItem(_ item: ClipboardItem) {
        items.insert(item, at: 0)
        if items.count > 100 { // Use default limit for testing
            items = Array(items.prefix(100))
        }
    }

    func detectContentType(_ content: String) -> ClipboardType {
        // URL kontrolü
        if content.hasPrefix("http://") || content.hasPrefix("https://") || content.hasPrefix("ftp://") {
            return .url
        }

        // Email kontrolü
        if content.contains("@") && content.contains(".") && !content.contains(" ") && content.count < 100 {
            return .email
        }

        // Kod kontrolü
        let codeIndicators = ["{", "}", "function", "class", "import", "var ", "let ", "const ", "def ", "public ", "private ", "<!DOCTYPE", "<html", "<?php", "#!/bin"]
        if codeIndicators.contains(where: content.contains) {
            return .code
        }

        // Çok satırlı kod kontrolü
        let lines = content.components(separatedBy: .newlines)
        if lines.count > 3 {
            let codeLineIndicators = ["    ", "\t", "//", "/*", "*/", "#include", "import ", "from "]
            let codeLines = lines.filter { line in
                codeLineIndicators.contains { line.contains($0) }
            }
            if codeLines.count >= 2 {
                return .code
            }
        }

        return .text
    }
}
