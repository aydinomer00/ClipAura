//
//  SettingsView.swift
//  ClipAura
//
//  Created by Ömer Murat Aydın on 25.05.2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = Settings()
    @State private var selectedTab: SettingsTab = .general
    @State private var showingClearAlert = false
    @State private var showingResetAlert = false
    @State private var searchText = ""

    var body: some View {
        HSplitView {
            ModernSidebar(selectedTab: $selectedTab, searchText: $searchText)
                .frame(minWidth: 220, idealWidth: 250, maxWidth: 280)

            ModernContentView(
                selectedTab: selectedTab,
                settings: settings,
                showingClearAlert: $showingClearAlert,
                showingResetAlert: $showingResetAlert,
                searchText: searchText
            )
            .frame(minWidth: 450)
        }
        .frame(minWidth: 700, idealWidth: 800, maxWidth: 900,
               minHeight: 500, idealHeight: 600, maxHeight: 700)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
        .alert("Clear All History", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                withAnimation(.spring(response: 0.3)) {
                    clearAllHistory()
                }
            }
        } message: {
            Text("This will permanently delete all clipboard history. This action cannot be undone.")
        }
        .alert("Reset to Defaults", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                withAnimation(.spring(response: 0.3)) {
                    resetSettings()
                }
            }
        } message: {
            Text("All settings will be restored to their default values.")
        }
    }

    private func clearAllHistory() {
        UserDefaults.standard.removeObject(forKey: "SavedClipboardItems")
        NotificationCenter.default.post(name: .clearAllClipboardItems, object: nil)
    }

    private func resetSettings() {
        settings.maxItems = 100
        settings.launchAtStartup = false
        settings.selectedHotkey = .cmdShiftV
    }
}

enum SettingsTab: String, CaseIterable {
    case general = "General"
    case hotkeys = "Shortcuts"
    case advanced = "Advanced"
    case about = "About"

    var icon: String {
        switch self {
        case .general: return "slider.horizontal.3"
        case .hotkeys: return "command.square"
        case .advanced: return "gearshape.2"
        case .about: return "info.circle"
        }
    }

    var accentColor: Color {
        switch self {
        case .general: return .blue
        case .hotkeys: return .purple
        case .advanced: return .orange
        case .about: return .green
        }
    }
}

struct ModernSidebar: View {
    @Binding var selectedTab: SettingsTab
    @Binding var searchText: String
    @State private var hoveredTab: SettingsTab?

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(
                                colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 40, height: 40)

                        Image(systemName: "doc.on.clipboard.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("ClipAura")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Settings")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))

                    TextField("Search settings", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .padding(.horizontal, 16)
            }
            .padding(.top, 20)
            .padding(.bottom, 16)

            VStack(spacing: 2) {
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    SidebarItem(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        isHovered: hoveredTab == tab
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            selectedTab = tab
                        }
                    }
                    .onHover { hovering in
                        withAnimation(.easeOut(duration: 0.1)) {
                            hoveredTab = hovering ? tab : nil
                        }
                    }
                }
            }
            .padding(.horizontal, 10)

            Spacer()

            VStack(spacing: 12) {
                Divider()
                    .padding(.horizontal, 16)

                HStack {
                    Text("Version 1.0.0")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)

                    Spacer()

                    Button(action: {
                        NSWorkspace.shared.open(URL(string: "https://github.com/aydinomer00")!)
                    }) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(VisualEffectView(material: .sidebar, blendingMode: .behindWindow))
    }
}

struct SidebarItem: View {
    let tab: SettingsTab
    let isSelected: Bool
    let isHovered: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: tab.icon)
                .font(.system(size: 16, weight: isSelected ? .medium : .regular))
                .foregroundColor(isSelected ? .white : (isHovered ? tab.accentColor : .secondary))
                .frame(width: 20)

            Text(tab.rawValue)
                .font(.system(size: 13, weight: isSelected ? .medium : .regular))
                .foregroundColor(isSelected ? .white : .primary)

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? tab.accentColor : (isHovered ? Color(NSColor.controlBackgroundColor) : Color.clear))
        )
        .animation(.easeOut(duration: 0.2), value: isSelected)
        .animation(.easeOut(duration: 0.1), value: isHovered)
    }
}

struct ModernContentView: View {
    let selectedTab: SettingsTab
    @ObservedObject var settings: Settings
    @Binding var showingClearAlert: Bool
    @Binding var showingResetAlert: Bool
    let searchText: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ContentHeader(tab: selectedTab)
                    .padding(.horizontal, 32)
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                Group {
                    switch selectedTab {
                    case .general:
                        GeneralSettings(settings: settings)
                    case .hotkeys:
                        HotkeySettings(settings: settings)
                    case .advanced:
                        AdvancedSettings(
                            showingClearAlert: $showingClearAlert,
                            showingResetAlert: $showingResetAlert
                        )
                    case .about:
                        AboutSettings()
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
                .animation(.spring(response: 0.4), value: selectedTab)
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - Content Header
struct ContentHeader: View {
    let tab: SettingsTab

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(tab.accentColor.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: tab.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(tab.accentColor)
                }

                Text(tab.rawValue)
                    .font(.system(size: 28, weight: .bold))
            }

            Text(headerDescription)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }

    var headerDescription: String {
        switch tab {
        case .general:
            return "Configure general application behavior and preferences"
        case .hotkeys:
            return "Customize keyboard shortcuts for quick access"
        case .advanced:
            return "Advanced options and maintenance tools"
        case .about:
            return "Information about ClipAura and its features"
        }
    }
}

// MARK: - General Settings
struct GeneralSettings: View {
    @ObservedObject var settings: Settings

    var body: some View {
        VStack(spacing: 24) {
            ModernSection(title: "Storage", icon: "internaldrive") {
                VStack(alignment: .leading, spacing: 20) {
                    // Maximum Items
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Maximum Items")
                                .font(.system(size: 14, weight: .medium))

                            Spacer()

                            Text("\(settings.maxItems)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.accentColor)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.accentColor.opacity(0.1))
                                )
                        }

                        VStack(spacing: 8) {
                            Slider(
                                value: Binding(
                                    get: { Double(settings.maxItems) },
                                    set: { settings.maxItems = Int($0) }
                                ),
                                in: 10...500,
                                step: 10
                            )
                            .accentColor(.accentColor)

                            HStack {
                                Text("10")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("500")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }

                        Text("Number of clipboard items to store before removing oldest entries")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }

            ModernSection(title: "System", icon: "gear") {
                VStack(spacing: 16) {
                    ModernToggleRow(
                        title: "Launch at Startup",
                        description: "Start ClipAura automatically when you log in",
                        isOn: $settings.launchAtStartup,
                        icon: "power"
                    )

                    Divider()
                        .padding(.horizontal, -16)

                    ModernToggleRow(
                        title: "Show in Menu Bar",
                        description: "Display ClipAura icon in the menu bar",
                        isOn: .constant(true),
                        icon: "menubar.rectangle"
                    )
                }
            }
        }
    }
}

// MARK: - Hotkey Settings
struct HotkeySettings: View {
    @ObservedObject var settings: Settings
    @State private var isRecording = false

    var body: some View {
        VStack(spacing: 24) {
            ModernSection(title: "Keyboard Shortcuts", icon: "keyboard") {
                VStack(spacing: 16) {
                    // Main Hotkey
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Show ClipAura")
                                .font(.system(size: 14, weight: .medium))
                            Text("Open the clipboard history window")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        HotkeyRecorder(
                            selectedHotkey: $settings.selectedHotkey,
                            isRecording: $isRecording
                        )
                    }

                    Divider()
                        .padding(.horizontal, -16)

                    // Additional Shortcuts (disabled for now)
                    VStack(spacing: 12) {
                        DisabledShortcutRow(
                            title: "Clear History",
                            description: "Remove all clipboard items",
                            shortcut: "⌘⇧⌫"
                        )

                        DisabledShortcutRow(
                            title: "Toggle Favorites",
                            description: "Show only favorite items",
                            shortcut: "⌘⇧F"
                        )
                    }
                    .opacity(0.5)
                }
            }

            // Info Card
            InfoCard(
                icon: "exclamationmark.triangle",
                title: "Accessibility Permission Required",
                description: "ClipAura needs accessibility access to register global keyboard shortcuts. Grant permission in System Settings > Privacy & Security > Accessibility.",
                style: .warning
            )
        }
    }
}

// MARK: - Advanced Settings
struct AdvancedSettings: View {
    @Binding var showingClearAlert: Bool
    @Binding var showingResetAlert: Bool

    var body: some View {
        VStack(spacing: 24) {
            ModernSection(title: "Data Management", icon: "externaldrive") {
                VStack(spacing: 16) {
                    ModernButton(
                        title: "Clear Clipboard History",
                        description: "Remove all stored clipboard items",
                        icon: "trash",
                        style: .destructive
                    ) {
                        showingClearAlert = true
                    }

                    ModernButton(
                        title: "Reset All Settings",
                        description: "Restore settings to default values",
                        icon: "arrow.counterclockwise",
                        style: .secondary
                    ) {
                        showingResetAlert = true
                    }
                }
            }

            ModernSection(title: "Performance", icon: "speedometer") {
                VStack(spacing: 16) {
                    InfoRow(
                        title: "Clipboard Check Interval",
                        value: "0.5 seconds",
                        icon: "clock"
                    )

                    InfoRow(
                        title: "Memory Usage",
                        value: "< 50 MB",
                        icon: "memorychip",
                        valueColor: .green
                    )

                    InfoRow(
                        title: "CPU Usage",
                        value: "< 1%",
                        icon: "cpu",
                        valueColor: .green
                    )
                }
            }
        }
    }
}

// MARK: - About Settings
struct AboutSettings: View {
    var body: some View {
        VStack(spacing: 24) {
            // App Info Card
            ModernSection {
                VStack(spacing: 20) {
                    // App Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(
                                colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 80, height: 80)
                            .shadow(color: Color.accentColor.opacity(0.3), radius: 10, y: 5)

                        Image(systemName: "doc.on.clipboard.fill")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundColor(.white)
                    }

                    VStack(spacing: 8) {
                        Text("ClipAura")
                            .font(.system(size: 24, weight: .bold))

                        Text("Version 1.0.0 (Build 100)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)

                        Text("© 2025 Ömer Murat Aydın")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    // Action Buttons
                    HStack(spacing: 12) {
                        Link(destination: URL(string: "https://github.com/aydinomer00")!) {
                            Label("GitHub", systemImage: "link")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .buttonStyle(.bordered)

                        Link(destination: URL(string: "https://linkedin.com/in/omermurataydin")!) {
                            Label("LinkedIn", systemImage: "person.crop.square")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            // Features
            ModernSection(title: "Features", icon: "star") {
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(
                        icon: "keyboard",
                        title: "Global Shortcuts",
                        description: "Access clipboard history from anywhere"
                    )

                    FeatureRow(
                        icon: "magnifyingglass",
                        title: "Smart Search",
                        description: "Find items quickly with intelligent filtering"
                    )

                    FeatureRow(
                        icon: "paintbrush",
                        title: "Syntax Highlighting",
                        description: "Beautiful code formatting support"
                    )

                    FeatureRow(
                        icon: "lock.shield",
                        title: "Privacy First",
                        description: "Your data stays on your device"
                    )
                }
            }
        }
    }
}

// MARK: - Reusable Components

struct ModernSection<Content: View>: View {
    let title: String?
    let icon: String?
    let content: Content

    init(title: String? = nil, icon: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let title = title {
                HStack(spacing: 8) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }

                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                }
            }

            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .padding(16)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(10)
        }
    }
}

struct ModernToggleRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    let icon: String?

    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .frame(width: 24)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .scaleEffect(0.8)
        }
    }
}

struct ModernButton: View {
    let title: String
    let description: String
    let icon: String
    let style: ButtonStyle
    let action: () -> Void

    enum ButtonStyle {
        case primary, secondary, destructive

        var backgroundColor: Color {
            switch self {
            case .primary: return .accentColor
            case .secondary: return Color(NSColor.controlBackgroundColor)
            case .destructive: return .red
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary, .destructive: return .white
            case .secondary: return .primary
            }
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                    Text(description)
                        .font(.system(size: 12))
                        .opacity(0.8)
                }

                Spacer()
            }
            .foregroundColor(style.foregroundColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(style.backgroundColor)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    let icon: String
    let valueColor: Color?

    init(title: String, value: String, icon: String, valueColor: Color? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.valueColor = valueColor
    }

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 14))

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(valueColor ?? .secondary)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.accentColor)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

struct HotkeyRecorder: View {
    @Binding var selectedHotkey: HotkeyOption
    @Binding var isRecording: Bool

    var body: some View {
        Menu {
            ForEach(HotkeyOption.allCases, id: \.self) { option in
                Button(action: {
                    selectedHotkey = option
                }) {
                    HStack {
                        Text(option.displayName)
                        if selectedHotkey == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selectedHotkey.displayName)
                    .font(.system(size: 13, weight: .medium))
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
            )
        }
        .menuStyle(.borderlessButton)
    }
}

struct DisabledShortcutRow: View {
    let title: String
    let description: String
    let shortcut: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(shortcut)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(4)
        }
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let description: String
    let style: Style

    enum Style {
        case info, warning, success

        var color: Color {
            switch self {
            case .info: return .blue
            case .warning: return .orange
            case .success: return .green
            }
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(style.color)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(style.color)

                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(16)
        .background(style.color.opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(style.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Visual Effect View
struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

// MARK: - Extensions
extension Notification.Name {
    static let clearAllClipboardItems = Notification.Name("clearAllClipboardItems")
}

// MARK: - Preview
#Preview {
    SettingsView()
        .frame(width: 800, height: 600)
}
