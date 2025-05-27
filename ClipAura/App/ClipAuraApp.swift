//
//  ClipAuraApp.swift
//  ClipAura
//
//  Created by Ömer Murat Aydın on 25.05.2025.
//

import SwiftUI

@main
struct ClipAuraApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            EmptyView()
                .frame(width: 0, height: 0)
                .hidden()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
  
