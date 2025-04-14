//
//  WallpaperManager.swift
//  WallpaperThemeSwitcher
//
//  Created by Nick Stull on 4/13/25.
//

import AppKit

class WallpaperManager {
    static func applyTheme(_ theme: WallpaperTheme) {
        let screens = NSScreen.screens
        let images = theme.imageURLs.shuffled()

        guard !images.isEmpty else { return }

        for (index, screen) in screens.enumerated() {
            let image = images[index % images.count]
            do {
                try NSWorkspace.shared.setDesktopImageURL(image, for: screen, options: [:])
            } catch {
                print("Error setting wallpaper: \(error)")
            }
        }
    }

    static func currentWallpaper() -> URL? {
        guard let screen = NSScreen.main else { return nil }
        return NSWorkspace.shared.desktopImageURL(for: screen)
    }
    static func currentThemePath() -> URL? {
        let themeName = UserDefaults.standard.string(forKey: "lastUsedTheme")
        let basePath = ThemeLoader.currentDirectory

        // Look for direct match first
        let directPath = basePath.appendingPathComponent(themeName ?? "")
        if FileManager.default.fileExists(atPath: directPath.path) {
            return directPath
        }

        // Check nested folders
        if let subfolders = try? FileManager.default.contentsOfDirectory(at: basePath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
            for folder in subfolders where folder.hasDirectoryPath {
                let nested = folder.appendingPathComponent(themeName ?? "")
                if FileManager.default.fileExists(atPath: nested.path) {
                    return nested
                }
            }
        }

        return nil
    }
}
