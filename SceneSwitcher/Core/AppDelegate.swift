//
//  AppDelegate.swift
//  WallpaperThemeSwitcher
//
//  Created by Nick Stull on 4/13/25.
//

import Cocoa
import SwiftUI
import ServiceManagement


class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var currentTheme: WallpaperTheme?
    var settingsWindow: NSWindow?
    var rotationTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        setupMenu()

        if let mainMenu = NSApp.mainMenu {
            let appMenu = mainMenu.items.first?.submenu
            let prefsItem = appMenu?.items.first(where: { $0.title.contains("Preferences") })
            prefsItem?.target = self
            prefsItem?.action = #selector(showSettings)
        }
        func application(_ application: NSApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
            return false
        }

        func application(_ application: NSApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
            return false
        }
        let fm = FileManager.default
        let currentPath = SettingsStore.shared.wallpaperDirectory
        let defaultPath = ThemeLoader.defaultPath
        let isUsingDefault = (currentPath == defaultPath.path)
        let defaultFolderMissing = !fm.fileExists(atPath: defaultPath.path)

        if isUsingDefault && defaultFolderMissing {
            let alert = NSAlert()
            alert.messageText = "Wallpapers Folder Not Found"
            alert.informativeText = """
            The folder \"Pictures/Wallpapers\" doesn't exist. What would you like to do?
            """
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Create Default Folder")
            alert.addButton(withTitle: "Choose Different Folder")
            alert.addButton(withTitle: "Exit App")

            let response = alert.runModal()

            switch response {
            case .alertFirstButtonReturn:
                do {
                    try fm.createDirectory(at: defaultPath, withIntermediateDirectories: true)
                    AppLog.info("📂 Created default Wallpapers folder at: \(defaultPath.path)")
                } catch {
                    AppLog.error("❌ Failed to create folder: \(error)")
                    NSApp.terminate(nil)
                }

            case .alertSecondButtonReturn:
                let panel = NSOpenPanel()
                panel.message = "Choose a folder to use for wallpapers"
                panel.canChooseDirectories = true
                panel.canChooseFiles = false
                panel.allowsMultipleSelection = false

                if panel.runModal() == .OK, let selectedURL = panel.url {
                    SettingsStore.shared.wallpaperDirectory = selectedURL.path
                    AppLog.info("📁 User-selected folder: \(selectedURL.path)")
                } else {
                    NSApp.terminate(nil)
                }

            default:
                NSApp.terminate(nil)
            }
        }
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

        refreshThemes()

        // Add system items
        menu.addItem(NSMenuItem.separator())

        let settingsItem = NSMenuItem(title: "Settings", action: #selector(self.showSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        let uninstall = NSMenuItem(title: "Uninstall", action: #selector(self.uninstallApp), keyEquivalent: "")
        uninstall.target = self
        menu.addItem(uninstall)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(self.quit), keyEquivalent: "q")
        menu.addItem(quitItem)
    }

    func refreshThemes() {
        ThemeLoader.loadThemes { flatThemes, groupedThemes in
            guard let menu = self.statusItem.menu else { return }

            // Remove all existing items first
            menu.items.removeAll()

            // Next wallpaper
            let nextItem = NSMenuItem(title: "Next Wallpaper", action: #selector(self.nextWallpaper), keyEquivalent: "n")
            nextItem.target = self
            menu.addItem(nextItem)
            menu.addItem(NSMenuItem.separator())

            // Recent themes
            let recent = UserDefaults.standard.stringArray(forKey: "recentThemes") ?? []
            let allThemes = flatThemes + groupedThemes.flatMap { $0.themes }
            let recentThemes = recent.compactMap { name in allThemes.first(where: { $0.name == name }) }

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

            // Themes submenu
            let themesMenu = NSMenu(title: "Themes")

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

            let themesParent = NSMenuItem(title: "Themes", action: nil, keyEquivalent: "")
            menu.setSubmenu(themesMenu, for: themesParent)
            menu.addItem(themesParent)

            // Separator
            menu.addItem(NSMenuItem.separator())

            // Settings
            let settingsItem = NSMenuItem(title: "Settings", action: #selector(self.showSettings), keyEquivalent: ",")
            settingsItem.target = self
            menu.addItem(settingsItem)

            // Uninstall
            let uninstall = NSMenuItem(title: "Uninstall", action: #selector(self.uninstallApp), keyEquivalent: "")
            uninstall.target = self
            menu.addItem(uninstall)

            // Separator
            menu.addItem(NSMenuItem.separator())

            // Quit
            let quitItem = NSMenuItem(title: "Quit", action: #selector(self.quit), keyEquivalent: "q")
            menu.addItem(quitItem)

            // Auto-apply last theme
            if let lastUsed = UserDefaults.standard.string(forKey: "lastUsedTheme"),
               let matchedTheme = allThemes.first(where: { $0.name == lastUsed }),
               matchedTheme.name != self.currentTheme?.name {
                self.currentTheme = matchedTheme
                WallpaperManager.applyTheme(matchedTheme)
                self.startWallpaperRotationTimer()
            }
        }
    }

    func formatThemeName(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    @objc func setTheme(_ sender: NSMenuItem) {
        guard let theme = sender.representedObject as? WallpaperTheme else { return }
        currentTheme = theme
        UserDefaults.standard.set(theme.name, forKey: "lastUsedTheme")

        var recent = UserDefaults.standard.stringArray(forKey: "recentThemes") ?? []
        recent.removeAll(where: { $0 == theme.name })
        recent.insert(theme.name, at: 0)
        if recent.count > 3 { recent = Array(recent.prefix(3)) }
        UserDefaults.standard.set(recent, forKey: "recentThemes")

        WallpaperManager.applyTheme(theme)
        startWallpaperRotationTimer()
        self.refreshThemes()
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
                AppLog.info("⏸ Wallpaper rotation is paused.")
                return
            }

            if disableOnBattery, ProcessInfo.processInfo.isLowPowerModeEnabled {
                AppLog.info("🔋 Skipping rotation (Low Power Mode enabled).")
                return
            }

            guard interval > 0 else {
                AppLog.warn("⚠️ Invalid interval: \(interval)")
                return
            }

            AppLog.info("🔁 Starting wallpaper rotation every \(interval) minute(s)")

            rotationTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(interval * 60), repeats: true) { [weak self] _ in
                guard let self = self, let activeTheme = self.currentTheme else { return }

                if disableOnBattery, ProcessInfo.processInfo.isLowPowerModeEnabled {
                    AppLog.info("🔋 Skipping scheduled rotation (Low Power Mode)")
                    return
                }

                if rotationPaused {
                    AppLog.info("⏸ Scheduled rotation skipped (Paused)")
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
                return
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
                refreshThemes()
            }
        }
    }
}
