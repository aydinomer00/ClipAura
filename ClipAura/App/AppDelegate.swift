//
//  AppDelegate.swift
//  ClipAura
//
//  Created by Ömer Murat Aydın on 25.05.2025.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem?
    var popover: NSPopover?
    var settingsWindow: NSWindow?
    var settings = Settings()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupMenuBarItem()
        setupPopover()
        checkAccessibilityPermission()
    }

    func setupMenuBarItem() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusBarItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "ClipAura")
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.action = #selector(statusBarButtonClicked(_:))
            button.target = self
        }
    }

    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!

        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            togglePopover()
        }
    }

    func showContextMenu() {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Open ClipAura", action: #selector(togglePopover), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())

        let isTrusted = AXIsProcessTrusted()
        if isTrusted {
            let activeItem = NSMenuItem(title: "\(settings.selectedHotkey.displayName): Active ✅", action: nil, keyEquivalent: "")
            activeItem.isEnabled = false
            menu.addItem(activeItem)
        } else {
            let accessItem = NSMenuItem(title: "\(settings.selectedHotkey.displayName): Grant Permission", action: #selector(requestAccessibilityPermission), keyEquivalent: "")
            accessItem.target = self
            menu.addItem(accessItem)
        }

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit ClipAura", action: #selector(quitApp), keyEquivalent: "q"))

        if let button = statusBarItem?.button {
            menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.height), in: button)
        }
    }

    func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 500)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: MainView())
    }

    func checkAccessibilityPermission() {
        if AXIsProcessTrusted() {
            setupGlobalHotkey()
        }
    }

    @objc func requestAccessibilityPermission() {
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let options = [checkOptPrompt: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary?)

        if accessEnabled {
            setupGlobalHotkey()
            showAccessibilitySuccessAlert()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.openAccessibilityPreferences()
            }
        }
    }

    func setupGlobalHotkey() {
        NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { event in
            let currentHotkey = self.settings.selectedHotkey
            if event.modifierFlags.contains(currentHotkey.modifierFlags) &&
               event.keyCode == currentHotkey.keyCode {
                DispatchQueue.main.async {
                    self.togglePopover()
                }
            }
        }
    }

    func openAccessibilityPreferences() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = """
        For ClipAura to use the \(settings.selectedHotkey.displayName) shortcut:
        
        1. System Preferences will open
        2. Go to Privacy & Security > Accessibility
        3. Find ClipAura and enable it
        4. Restart the application
        """
        alert.addButton(withTitle: "Open System Preferences")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .informational

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }
    func showAccessibilitySuccessAlert() {
        let alert = NSAlert()
        alert.messageText = "Success!"
        alert.informativeText = "\(settings.selectedHotkey.displayName) shortcut is now active. You can open and close ClipAura using this key combination."
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .informational
        alert.runModal()
    }

    @objc func togglePopover() {
        if let button = statusBarItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

    @objc func openSettings() {
        if settingsWindow == nil {
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
                styleMask: [.titled, .closable, .resizable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            settingsWindow?.title = "ClipAura Settings"
            settingsWindow?.contentViewController = NSHostingController(rootView: SettingsView())
            settingsWindow?.center()
            settingsWindow?.minSize = NSSize(width: 500, height: 400)
            settingsWindow?.maxSize = NSSize(width: 800, height: 700)
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
