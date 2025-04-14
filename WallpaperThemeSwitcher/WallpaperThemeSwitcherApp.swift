//
//  WallpaperThemeSwitcherApp.swift
//  WallpaperThemeSwitcher
//
//  Created by Nick Stull on 4/13/25.
//

import SwiftUI

@main
struct WallpaperThemeSwitcherApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView() // No settings window
        }
    }
}
