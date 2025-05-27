//
//  ClipboardManager.swift
//  ClipAura
//
//  Created by Ömer Murat Aydın on 25.05.2025.
//

import Foundation
import AppKit

class ClipboardManager: ObservableObject {
    @Published var items: [ClipboardItem] = []
    private var changeCount: Int = 0
    private var timer: Timer?

    private var settings = Settings()
    private let userDefaults = UserDefaults.standard
    private let itemsKey = "SavedClipboardItems"

    init() {
        loadSavedItems()
        startMonitoring()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearAllHistory),
            name: .clearAllClipboardItems,
            object: nil
        )
    }

    private func loadSavedItems() {
        if let data = userDefaults.data(forKey: itemsKey),
           let savedItems = try? JSONDecoder().decode([ClipboardItem].self, from: data) {
            items = savedItems
        }
    }

    private func saveItems() {
        if let data = try? JSONEncoder().encode(items) {
            userDefaults.set(data, forKey: itemsKey)
        }
    }

    func startMonitoring() {
        changeCount = NSPasteboard.general.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.checkClipboard()
        }
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general

        if pasteboard.changeCount != changeCount {
            changeCount = pasteboard.changeCount

            if let imageData = getImageFromPasteboard(pasteboard) {
                let imageName = generateImageName()
                let newItem = ClipboardItem(
                    content: imageName,
                    type: .image,
                    imageData: imageData,
                    imageName: imageName
                )

                addNewItem(newItem)
                return
            }

            if let string = pasteboard.string(forType: .string),
               !string.isEmpty,
               !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

                if items.first?.content != string {
                    let type = detectContentType(string)
                    let newItem = ClipboardItem(
                        content: string,
                        type: type
                    )

                    addNewItem(newItem)
                }
            }
        }
    }

    private func getImageFromPasteboard(_ pasteboard: NSPasteboard) -> Data? {
        let imageTypes: [NSPasteboard.PasteboardType] = [
            .tiff,
            .png,
            .pdf,
            NSPasteboard.PasteboardType("public.jpeg"),
            NSPasteboard.PasteboardType("public.heic")
        ]

        for type in imageTypes {
            if let data = pasteboard.data(forType: type) {
                if NSImage(data: data) != nil {
                    return data
                }
            }
        }

        return nil
    }

    private func generateImageName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMdd_HHmmss"
        return "Image_\(formatter.string(from: Date()))"
    }

    private func addNewItem(_ newItem: ClipboardItem) {
        DispatchQueue.main.async {
            self.items.insert(newItem, at: 0)

            if self.items.count > self.settings.maxItems {
                self.items = Array(self.items.prefix(self.settings.maxItems))
            }

            self.saveItems()
        }
    }

    private func detectContentType(_ content: String) -> ClipboardType {
        if content.hasPrefix("http://") || content.hasPrefix("https://") || content.hasPrefix("ftp://") {
            return .url
        }

        if content.contains("@") && content.contains(".") && !content.contains(" ") && content.count < 100 {
            return .email
        }

        let codeIndicators = ["{", "}", "function", "class", "import", "var ", "let ", "const ", "def ", "public ", "private ", "<!DOCTYPE", "<html", "<?php", "#!/bin"]
        if codeIndicators.contains(where: content.contains) {
            return .code
        }

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

    func copyToClipboard(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        if item.type == .image, let imageData = item.imageData {
            pasteboard.setData(imageData, forType: .tiff)
        } else {
            pasteboard.setString(item.content, forType: .string)
        }
    }

    func deleteItem(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
        saveItems()
    }

    func clearAll() {
        items.removeAll()
        saveItems()
    }

    @objc func clearAllHistory() {
        items.removeAll()
        saveItems()
    }

    func exportHistory() -> String {
        let exportData = items.map { item in
            var itemInfo = """
            [\(item.timestamp)] [\(item.type.rawValue.uppercased())]
            """

            if item.type == .image {
                itemInfo += """
                
                Image: \(item.imageName ?? "Unknown")
                Size: \(item.imageSize ?? "Unknown")
                Dimensions: \(item.imageDimensions ?? "Unknown")
                """
            } else {
                itemInfo += """
                
                \(item.content)
                """
            }

            return itemInfo + "\n---\n"
        }.joined(separator: "\n")

        return exportData
    }

    func items(ofType type: ClipboardType) -> [ClipboardItem] {
        return items.filter { $0.type == type }
    }

    func searchItems(query: String) -> [ClipboardItem] {
        if query.isEmpty {
            return items
        }
        return items.filter { item in
            if item.type == .image {
                return item.imageName?.localizedCaseInsensitiveContains(query) ?? false
            } else {
                return item.content.localizedCaseInsensitiveContains(query)
            }
        }
    }

    var totalImageSize: Int64 {
        let totalSize = items.compactMap { $0.imageData?.count }.reduce(0, +)
        return Int64(totalSize)
    }

    var imageCount: Int {
        return items.filter { $0.type == .image }.count
    }

    var totalImageSizeFormatted: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalImageSize)
    }

    deinit {
        timer?.invalidate()
        saveItems()
        NotificationCenter.default.removeObserver(self)
    }
}
