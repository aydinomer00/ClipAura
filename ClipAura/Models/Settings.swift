//
//  Settings.swift
//  ClipAura
//
//  Created by Ömer Murat Aydın on 25.05.2025.
//
import Foundation
import SwiftUI
import ServiceManagement

class Settings: ObservableObject {
    @Published var maxItems: Int {
        didSet {
            UserDefaults.standard.set(maxItems, forKey: "maxItems")
        }
    }

    @Published var launchAtStartup: Bool {
        didSet {
            UserDefaults.standard.set(launchAtStartup, forKey: "launchAtStartup")
            configureLaunchAtStartup()
        }
    }

    @Published var selectedHotkey: HotkeyOption {
        didSet {
            UserDefaults.standard.set(selectedHotkey.rawValue, forKey: "selectedHotkey")
        }
    }

    init() {
        self.maxItems = UserDefaults.standard.object(forKey: "maxItems") as? Int ?? 100

        // Gerçek sistem durumunu oku (UserDefaults'tan değil)
        self.launchAtStartup = SMAppService.mainApp.status == .enabled

        let hotkeyRaw = UserDefaults.standard.string(forKey: "selectedHotkey") ?? HotkeyOption.cmdShiftV.rawValue
        self.selectedHotkey = HotkeyOption(rawValue: hotkeyRaw) ?? .cmdShiftV
    }

    private func configureLaunchAtStartup() {
        do {
            if launchAtStartup {
                try SMAppService.mainApp.register()
                print("✅ Launch at startup enabled")
            } else {
                try SMAppService.mainApp.unregister()
                print("❌ Launch at startup disabled")
            }
        } catch {
            print("⚠️ Launch at startup error: \(error.localizedDescription)")
        }
    }
}

enum HotkeyOption: String, CaseIterable {
    case cmdShiftV = "cmd+shift+v"
    case cmdOptionV = "cmd+option+v"
    case ctrlShiftV = "ctrl+shift+v"
    case cmdShiftC = "cmd+shift+c"

    var displayName: String {
        switch self {
        case .cmdShiftV: return "⌘+Shift+V"
        case .cmdOptionV: return "⌘+Option+V"
        case .ctrlShiftV: return "⌃+Shift+V"
        case .cmdShiftC: return "⌘+Shift+C"
        }
    }

    var keyCode: UInt16 {
        switch self {
        case .cmdShiftV: return 9  // V
        case .cmdOptionV: return 9  // V
        case .ctrlShiftV: return 9  // V
        case .cmdShiftC: return 8  // C
        }
    }

    var modifierFlags: NSEvent.ModifierFlags {
        switch self {
        case .cmdShiftV: return [.command, .shift]
        case .cmdOptionV: return [.command, .option]
        case .ctrlShiftV: return [.control, .shift]
        case .cmdShiftC: return [.command, .shift]
        }
    }
}
