//
//  SettingsTests.swift
//  ClipAura
//
//  Created by Ömer Murat Aydın on 26.05.2025.
//

import XCTest
@testable import ClipAura

class SettingsTests: XCTestCase {

    var settings: Settings!

    override func setUp() {
        super.setUp()
        // Clean UserDefaults for testing
        UserDefaults.standard.removeObject(forKey: "maxItems")
        UserDefaults.standard.removeObject(forKey: "launchAtStartup")
        UserDefaults.standard.removeObject(forKey: "selectedHotkey")

        settings = Settings()
    }

    override func tearDown() {
        settings = nil
        super.tearDown()
    }

    // MARK: - Default Values Tests

    func testDefaultMaxItems() {
        // Given & When & Then
        XCTAssertEqual(settings.maxItems, 100)
    }

    func testDefaultLaunchAtStartup() {
        // Given & When & Then
        XCTAssertFalse(settings.launchAtStartup)
    }

    func testDefaultHotkey() {
        // Given & When & Then
        XCTAssertEqual(settings.selectedHotkey, .cmdShiftV)
    }

    // MARK: - UserDefaults Persistence Tests

    func testMaxItemsPersistence() {
        // Given
        let newMaxItems = 250

        // When
        settings.maxItems = newMaxItems

        // Then
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "maxItems"), newMaxItems)

        // Create new settings instance to test loading
        let newSettings = Settings()
        XCTAssertEqual(newSettings.maxItems, newMaxItems)
    }

    func testLaunchAtStartupPersistence() {
        // Given
        let newValue = true

        // When
        settings.launchAtStartup = newValue

        // Then
        XCTAssertEqual(UserDefaults.standard.bool(forKey: "launchAtStartup"), newValue)

        // Create new settings instance to test loading
        let newSettings = Settings()
        XCTAssertEqual(newSettings.launchAtStartup, newValue)
    }

    func testHotkeyPersistence() {
        // Given
        let newHotkey = HotkeyOption.cmdOptionV

        // When
        settings.selectedHotkey = newHotkey

        // Then
        XCTAssertEqual(UserDefaults.standard.string(forKey: "selectedHotkey"), newHotkey.rawValue)

        // Create new settings instance to test loading
        let newSettings = Settings()
        XCTAssertEqual(newSettings.selectedHotkey, newHotkey)
    }

    // MARK: - Validation Tests

    func testMaxItemsRange() {
        // Test minimum boundary
        settings.maxItems = 5
        XCTAssertEqual(settings.maxItems, 5)

        // Test maximum boundary
        settings.maxItems = 1000
        XCTAssertEqual(settings.maxItems, 1000)

        // Test normal value
        settings.maxItems = 150
        XCTAssertEqual(settings.maxItems, 150)
    }

    // MARK: - HotkeyOption Tests

    func testHotkeyDisplayNames() {
        XCTAssertEqual(HotkeyOption.cmdShiftV.displayName, "⌘+Shift+V")
        XCTAssertEqual(HotkeyOption.cmdOptionV.displayName, "⌘+Option+V")
        XCTAssertEqual(HotkeyOption.ctrlShiftV.displayName, "⌃+Shift+V")
        XCTAssertEqual(HotkeyOption.cmdShiftC.displayName, "⌘+Shift+C")
    }

    func testHotkeyKeyCodes() {
        XCTAssertEqual(HotkeyOption.cmdShiftV.keyCode, 9)  // V
        XCTAssertEqual(HotkeyOption.cmdOptionV.keyCode, 9)  // V
        XCTAssertEqual(HotkeyOption.ctrlShiftV.keyCode, 9)  // V
        XCTAssertEqual(HotkeyOption.cmdShiftC.keyCode, 8)  // C
    }

    func testHotkeyModifierFlags() {
        XCTAssertTrue(HotkeyOption.cmdShiftV.modifierFlags.contains(.command))
        XCTAssertTrue(HotkeyOption.cmdShiftV.modifierFlags.contains(.shift))

        XCTAssertTrue(HotkeyOption.cmdOptionV.modifierFlags.contains(.command))
        XCTAssertTrue(HotkeyOption.cmdOptionV.modifierFlags.contains(.option))

        XCTAssertTrue(HotkeyOption.ctrlShiftV.modifierFlags.contains(.control))
        XCTAssertTrue(HotkeyOption.ctrlShiftV.modifierFlags.contains(.shift))
    }

    func testAllHotkeyOptionsCases() {
        let allCases = HotkeyOption.allCases
        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.cmdShiftV))
        XCTAssertTrue(allCases.contains(.cmdOptionV))
        XCTAssertTrue(allCases.contains(.ctrlShiftV))
        XCTAssertTrue(allCases.contains(.cmdShiftC))
    }

    // MARK: - Settings Reset Tests

    func testSettingsReset() {
        // Given - Change all settings
        settings.maxItems = 500
        settings.launchAtStartup = true
        settings.selectedHotkey = .cmdOptionV

        // When - Reset to defaults (simulating reset functionality)
        settings.maxItems = 100
        settings.launchAtStartup = false
        settings.selectedHotkey = .cmdShiftV

        // Then
        XCTAssertEqual(settings.maxItems, 100)
        XCTAssertFalse(settings.launchAtStartup)
        XCTAssertEqual(settings.selectedHotkey, .cmdShiftV)
    }

    // MARK: - Edge Cases Tests

    func testInvalidHotkeyFromUserDefaults() {
        // Given - Set invalid hotkey in UserDefaults
        UserDefaults.standard.set("invalid_hotkey", forKey: "selectedHotkey")

        // When
        let newSettings = Settings()

        // Then - Should fallback to default
        XCTAssertEqual(newSettings.selectedHotkey, .cmdShiftV)
    }
}
