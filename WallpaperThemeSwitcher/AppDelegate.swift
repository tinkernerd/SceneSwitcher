//
//  AppDelegate.swift
//  WallpaperThemeSwitcher
//
//  Created by Nick Stull on 4/13/25.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var currentTheme: WallpaperTheme?
    var settingsWindow: NSWindow?
    var previewWindow: NSWindow?
    var rotationTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupMenu()
    }

    func setupMenu() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "photo.on.rectangle", accessibilityDescription: "Wallpaper Switcher")
        }

        let menu = NSMenu()
        statusItem.menu = menu

        // First: Next wallpaper
        let nextItem = NSMenuItem(title: "Next Wallpaper", action: #selector(self.nextWallpaper), keyEquivalent: "n")
        nextItem.target = self
        menu.addItem(nextItem)

        menu.addItem(NSMenuItem.separator())
        
        // Preview (top level)
        let previewItem = NSMenuItem(title: "Preview", action: #selector(self.showPreview), keyEquivalent: "p")
        previewItem.target = self
        menu.addItem(previewItem)

        // Settings with submenu
        let settingsMenu = NSMenu(title: "Settings")

        let preferencesItem = NSMenuItem(title: "Preferences...", action: #selector(self.showSettings), keyEquivalent: ",")
        preferencesItem.target = self
        settingsMenu.addItem(preferencesItem)

        let checkUpdates = NSMenuItem(title: "Check for Updates", action: #selector(self.checkForUpdates), keyEquivalent: "")
        checkUpdates.target = self
        settingsMenu.addItem(checkUpdates)

        let uninstall = NSMenuItem(title: "Uninstall", action: #selector(self.uninstallApp), keyEquivalent: "")
        uninstall.target = self
        settingsMenu.addItem(uninstall)

        let settingsParent = NSMenuItem(title: "Settings", action: nil, keyEquivalent: "")
        menu.setSubmenu(settingsMenu, for: settingsParent)
        menu.addItem(settingsParent)


        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(self.quit), keyEquivalent: "q")
        menu.addItem(quitItem)

        refreshThemes()
    }
    func formatThemeName(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    func refreshThemes() {
        ThemeLoader.loadThemes { flatThemes, groupedThemes in
            guard let menu = self.statusItem.menu else { return }

            // Remove all existing theme menu items
            menu.items.removeAll()

            // Prepare recent themes
            let recent = UserDefaults.standard.stringArray(forKey: "recentThemes") ?? []
            let allThemes = flatThemes + groupedThemes.flatMap { $0.themes }
            let recentThemes = recent.compactMap { name in allThemes.first(where: { $0.name == name }) }

            // Add recent section
            if !recentThemes.isEmpty {
                let titleItem = NSMenuItem(title: "Recent", action: nil, keyEquivalent: "")
                titleItem.isEnabled = false
                menu.addItem(titleItem)

                for theme in recentThemes {
                    let displayName = self.formatThemeName(theme.name)
                    let item = NSMenuItem(title: displayName, action: #selector(self.setTheme(_:)), keyEquivalent: "")
                    item.representedObject = theme
                    item.target = self
                    menu.addItem(item)
                }

                menu.addItem(NSMenuItem.separator())
            }

            // Build Themes submenu
            let themesMenu = NSMenu(title: "Themes")

            // Sort alphabetically
            let sortedFlat = flatThemes.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            for theme in sortedFlat {
                let displayName = self.formatThemeName(theme.name)
                let item = NSMenuItem(title: displayName, action: #selector(self.setTheme(_:)), keyEquivalent: "")
                item.representedObject = theme
                item.target = self
                themesMenu.addItem(item)
            }

            let sortedGroups = groupedThemes.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            for group in sortedGroups {
                let groupItem = NSMenuItem()
                let submenu = NSMenu(title: group.name)

                let sortedSubs = group.themes.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
                for subTheme in sortedSubs {
                    let displayName = self.formatThemeName(subTheme.name)
                    let subItem = NSMenuItem(title: displayName, action: #selector(self.setTheme(_:)), keyEquivalent: "")
                    subItem.representedObject = subTheme
                    subItem.target = self
                    submenu.addItem(subItem)
                }

                groupItem.title = self.formatThemeName(group.name)
                themesMenu.setSubmenu(submenu, for: groupItem)
                themesMenu.addItem(groupItem)
            }

            // Add Themes submenu to main menu
            let themesParent = NSMenuItem(title: "Themes", action: nil, keyEquivalent: "")
            menu.setSubmenu(themesMenu, for: themesParent)
            menu.addItem(themesParent)

            // Add system items
            menu.addItem(NSMenuItem.separator())

            let nextItem = NSMenuItem(title: "Next Wallpaper", action: #selector(self.nextWallpaper), keyEquivalent: "n")
            nextItem.target = self
            menu.addItem(nextItem)

            menu.addItem(NSMenuItem.separator())

            // Settings Menu
            let settingsMenu = NSMenu(title: "Settings")
            let preferencesItem = NSMenuItem(title: "Preferences...", action: #selector(self.showSettings), keyEquivalent: ",")
            preferencesItem.target = self
            settingsMenu.addItem(preferencesItem)
            let checkUpdates = NSMenuItem(title: "Check for Updates", action: #selector(self.checkForUpdates), keyEquivalent: "")
            checkUpdates.target = self
            settingsMenu.addItem(checkUpdates)
            let uninstall = NSMenuItem(title: "Uninstall", action: #selector(self.uninstallApp), keyEquivalent: "")
            uninstall.target = self
            settingsMenu.addItem(uninstall)

            let settingsParent = NSMenuItem(title: "Settings", action: nil, keyEquivalent: "")
            menu.setSubmenu(settingsMenu, for: settingsParent)
            menu.addItem(settingsParent)

            // Preview
            let previewItem = NSMenuItem(title: "Preview", action: #selector(self.showPreview), keyEquivalent: "p")
            previewItem.target = self
            menu.addItem(previewItem)

            menu.addItem(NSMenuItem.separator())

            menu.addItem(NSMenuItem(title: "Quit", action: #selector(self.quit), keyEquivalent: "q"))

            // Reapply last used
            if let lastUsed = UserDefaults.standard.string(forKey: "lastUsedTheme"),
               let matchedTheme = allThemes.first(where: { $0.name == lastUsed }) {
                self.currentTheme = matchedTheme
                WallpaperManager.applyTheme(matchedTheme)
                self.startWallpaperRotationTimer()
            }
        }
    }


    @objc func setTheme(_ sender: NSMenuItem) {
        guard let theme = sender.representedObject as? WallpaperTheme else { return }
        currentTheme = theme
        UserDefaults.standard.set(theme.name, forKey: "lastUsedTheme")

        // Track recent themes
        var recent = UserDefaults.standard.stringArray(forKey: "recentThemes") ?? []
        recent.removeAll(where: { $0 == theme.name }) // remove duplicates
        recent.insert(theme.name, at: 0) // insert at top
        if recent.count > 3 { recent = Array(recent.prefix(3)) }
        UserDefaults.standard.set(recent, forKey: "recentThemes")

        WallpaperManager.applyTheme(theme)
        startWallpaperRotationTimer()
        self.refreshThemes() // 👈 This redraws the menu including "Recent"

    }

    @objc func nextWallpaper() {
        guard let theme = currentTheme else { return }
        WallpaperManager.applyTheme(theme)
    }

    func startWallpaperRotationTimer() {
        rotationTimer?.invalidate()

        guard currentTheme != nil else { return }

        let interval = UserDefaults.standard.integer(forKey: "rotationInterval")
        let rotationPaused = UserDefaults.standard.bool(forKey: "rotationPaused")
        let disableOnBattery = UserDefaults.standard.bool(forKey: "disableOnBattery")

        if rotationPaused {
            print("⏸ Wallpaper rotation is paused.")
            return
        }

        if disableOnBattery, ProcessInfo.processInfo.isLowPowerModeEnabled {
            print("🔋 Skipping rotation (Low Power Mode enabled).")
            return
        }

        guard interval > 0 else {
            print("⚠️ Invalid interval: \(interval)")
            return
        }

        print("🔁 Starting wallpaper rotation every \(interval) minute(s)")

        rotationTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval * 60), repeats: true) { [weak self] _ in
            guard let self = self, let activeTheme = self.currentTheme else { return }

            if disableOnBattery, ProcessInfo.processInfo.isLowPowerModeEnabled {
                print("🔋 Skipping scheduled rotation (Low Power Mode)")
                return
            }

            if rotationPaused {
                print("⏸ Scheduled rotation skipped (Paused)")
                return
            }

            WallpaperManager.applyTheme(activeTheme)
        }
    }


    @objc func showSettings() {
        if settingsWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.title = "Preferences"
            window.isReleasedWhenClosed = false
            window.minSize = NSSize(width: 500, height: 400)
            window.delegate = self
            window.contentView = NSHostingView(rootView: SettingsView())
            settingsWindow = window
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func showPreview() {
        if previewWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 560), // 👈 increased height
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.title = "Preview"
            window.isReleasedWhenClosed = false
            window.delegate = self
            window.contentView = NSHostingView(rootView: PreviewView())
            previewWindow = window
        }

        previewWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func checkForUpdates() {
        if let url = URL(string: "https://github.com/tinkernerd/MacWallpaperThemeSwitcher/releases") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc func uninstallApp() {
        let alert = NSAlert()
        alert.messageText = "Uninstall Wallpaper Theme Switcher?"
        alert.informativeText = "This will quit the app. You can remove it manually from the Applications folder."
        alert.addButton(withTitle: "Quit App")
        alert.addButton(withTitle: "Cancel")
        if alert.runModal() == .alertFirstButtonReturn {
            NSApplication.shared.terminate(nil)
        }
    }

    @objc func quit() {
        let showWarning = UserDefaults.standard.bool(forKey: "quitWarningEnabled")

        if showWarning {
            let alert = NSAlert()
            alert.messageText = "Are you sure you want to quit?"
            alert.informativeText = "You can disable this warning in Preferences."
            alert.addButton(withTitle: "Quit")
            alert.addButton(withTitle: "Cancel")

            if alert.runModal() != .alertFirstButtonReturn {
                return // User hit Cancel
            }
        }

        rotationTimer?.invalidate()
        NSApplication.shared.terminate(nil)
    }

}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            if window == settingsWindow {
                settingsWindow = nil
                refreshThemes() // 👈 Refresh menu when Preferences window is closed
            } else if window == previewWindow {
                previewWindow = nil
            }
        }
    }
}
