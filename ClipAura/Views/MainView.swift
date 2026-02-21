//
//  MainView.swift
//  ClipAura
//
//  Created by Ömer Murat Aydın on 25.05.2025.
//

import SwiftUI

struct MainView: View {
    @StateObject private var clipboardManager = ClipboardManager()
    @State private var searchText = ""
    @State private var selectedFilter: ClipboardType? = nil

    var filteredItems: [ClipboardItem] {
        var items = clipboardManager.items

        if let filter = selectedFilter {
            items = items.filter { $0.type == filter }
        }

        if !searchText.isEmpty {
            items = items.filter { item in
                if item.type == .image {
                    return item.imageName?.localizedCaseInsensitiveContains(searchText) ?? false
                } else {
                    return item.content.localizedCaseInsensitiveContains(searchText)
                }
            }
        }

        return items
    }

    var body: some View {
        VStack(spacing: 0) {
            HeaderView(itemCount: clipboardManager.items.count, imageCount: clipboardManager.imageCount)

            FilterBarView(selectedFilter: $selectedFilter, items: clipboardManager.items)

            SearchBarView(searchText: $searchText)

            ClipboardListView(
                items: filteredItems,
                clipboardManager: clipboardManager
            )

            FooterView(clipboardManager: clipboardManager)
        }
        .frame(width: 420, height: 520)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct HeaderView: View {
    let itemCount: Int
    let imageCount: Int

    var body: some View {
        HStack {
            Image(systemName: "doc.on.clipboard")
                .foregroundColor(.accentColor)
            Text("ClipAura")
                .font(.headline)
                .fontWeight(.semibold)

            if itemCount > 0 {
                HStack(spacing: 4) {
                    Text("(\(itemCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if imageCount > 0 {
                        HStack(spacing: 2) {
                            Text("•")
                                .foregroundColor(.secondary)
                            Image(systemName: "photo")
                                .font(.caption)
                                .foregroundColor(.pink)
                            Text("\(imageCount)")
                                .foregroundColor(.pink)
                        }
                        .font(.caption)
                    }

                    Text(")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Button(action: {
                NotificationCenter.default.post(name: .openSettings, object: nil)
            }) {
                Image(systemName: "gear")
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct FilterBarView: View {
    @Binding var selectedFilter: ClipboardType?
    let items: [ClipboardItem]

    private func count(for type: ClipboardType) -> Int {
        items.filter { $0.type == type }.count
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterButton(
                    title: "All",
                    icon: "tray.full",
                    count: items.count,
                    isSelected: selectedFilter == nil,
                    color: .accentColor
                ) {
                    selectedFilter = nil
                }

                ForEach(ClipboardType.allCases, id: \.self) { type in
                    let typeCount = count(for: type)
                    if typeCount > 0 {
                        FilterButton(
                            title: type.rawValue.capitalized,
                            icon: type.icon,
                            count: typeCount,
                            isSelected: selectedFilter == type,
                            color: type.color
                        ) {
                            selectedFilter = selectedFilter == type ? nil : type
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

struct FilterButton: View {
    let title: String
    let icon: String
    let count: Int
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(isSelected ? Color.white.opacity(0.3) : color.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? color : color.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct SearchBarView: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Search clipboard items...", text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.top, 4)
    }
}

struct ClipboardListView: View {
    let items: [ClipboardItem]
    let clipboardManager: ClipboardManager

    var body: some View {
        if items.isEmpty {
            EmptyStateView()
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(items) { item in
                        ClipboardItemRow(item: item, clipboardManager: clipboardManager)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clipboard")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text("No items copied yet")
                .font(.headline)
                .foregroundColor(.secondary)

            VStack(spacing: 4) {
                Text("Copy text, code, links, or images")
                    .font(.caption)
                    .foregroundColor(Color.secondary.opacity(0.7))
                Text("They'll appear here automatically")
                    .font(.caption)
                    .foregroundColor(Color.secondary.opacity(0.7))
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct ClipboardItemRow: View {
    let item: ClipboardItem
    let clipboardManager: ClipboardManager
    @State private var isHovered = false
    @State private var showingFullContent = false
    @State private var showingImageDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if item.type == .image {
                ImageItemView(item: item, isHovered: isHovered, showingImageDetail: $showingImageDetail)
            } else {
                TextItemView(item: item, isHovered: isHovered, showingFullContent: $showingFullContent)
            }

            HStack {
                HStack(spacing: 8) {
                    Image(systemName: item.type.icon)
                        .font(.caption2)
                        .foregroundColor(item.type.color)

                    Text(item.timeAgo)
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    if item.type == .image {
                        if let size = item.imageSize {
                            Text("• \(size)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        if let dimensions = item.imageDimensions {
                            Text("• \(dimensions)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("• \(item.content.count) characters")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if isHovered {
                    HStack(spacing: 6) {
                        if item.type == .image {
                            Button(action: {
                                showingImageDetail = true
                            }) {
                                Image(systemName: "eye")
                                    .font(.caption)
                            }
                            .buttonStyle(.plain)
                            .help("View Image")
                        }

                        Button(action: {
                            clipboardManager.copyToClipboard(item)
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                        .help("Copy")

                        Button(action: {
                            clipboardManager.deleteItem(item)
                        }) {
                            Image(systemName: "trash")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                        .help("Delete")
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        }
        .background(isHovered ? Color(NSColor.controlAccentColor).opacity(0.1) : Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            clipboardManager.copyToClipboard(item)
        }
        .sheet(isPresented: $showingImageDetail) {
            if item.type == .image {
                ImageDetailView(item: item)
            }
        }
    }
}

struct ImageItemView: View {
    let item: ClipboardItem
    let isHovered: Bool
    @Binding var showingImageDetail: Bool

    var body: some View {
        VStack(spacing: 8) {
            if let image = item.image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: 120)
                    .clipped()
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.1))
                    .frame(height: 120)
                    .overlay(
                        VStack(spacing: 4) {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("Image not available")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
            }

            HStack {
                Text(item.imageName ?? "Image")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Spacer()
            }
        }
        .padding(12)
    }
}

struct TextItemView: View {
    let item: ClipboardItem
    let isHovered: Bool
    @Binding var showingFullContent: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.type.icon)
                .foregroundColor(item.type.color)
                .frame(width: 16, height: 16)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(showingFullContent ? item.content : item.preview)
                    .font(.system(.body, design: item.type == .code ? .monospaced : .default))
                    .lineLimit(showingFullContent ? nil : 3)
                    .multilineTextAlignment(.leading)
                    .animation(.easeInOut(duration: 0.2), value: showingFullContent)

                if item.content.count > 50 {
                    Button(showingFullContent ? "Show less" : "Show more") {
                        showingFullContent.toggle()
                    }
                    .font(.caption)
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                }
            }

            Spacer()
        }
        .padding(12)
    }
}

struct ImageDetailView: View {
    let item: ClipboardItem

    var body: some View {
        VStack(spacing: 16) {
            if let image = item.image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 600, maxHeight: 400)
                    .cornerRadius(8)
                    .shadow(radius: 4)
            }

            VStack(spacing: 8) {
                Text(item.imageName ?? "Image")
                    .font(.headline)

                HStack(spacing: 20) {
                    if let dimensions = item.imageDimensions {
                        Label(dimensions, systemImage: "aspectratio")
                            .font(.caption)
                    }

                    if let size = item.imageSize {
                        Label(size, systemImage: "doc")
                            .font(.caption)
                    }

                    Label(item.timeAgo, systemImage: "clock")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
}

struct FooterView: View {
    let clipboardManager: ClipboardManager

    var body: some View {
        HStack {
            Text("⌘+V to paste")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            if clipboardManager.imageCount > 0 {
                Text("\(clipboardManager.imageCount) images")
                    .font(.caption)
                    .foregroundColor(.pink)

                Text("•")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Button("Clear") {
                clipboardManager.clearAll()
            }
            .buttonStyle(.plain)
            .font(.caption)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

#Preview {
    MainView()
}
