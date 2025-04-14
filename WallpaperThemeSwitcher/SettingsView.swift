//
//  SettingsView.swift
//  WallpaperThemeSwitcher
//
//  Created by Nick Stull on 4/13/25.
//

import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @AppStorage("wallpaperDirectory") var wallpaperDirectory: String = ThemeLoader.defaultPath.path
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false
    @AppStorage("rotationInterval") var rotationInterval: Int = 10
    @AppStorage("quitWarningEnabled") var quitWarningEnabled: Bool = true
    @AppStorage("rotationPaused") var rotationPaused: Bool = false
    @AppStorage("disableOnBattery") var disableOnBattery: Bool = false



    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Preferences")
                .font(.title)
                .bold()

            VStack(alignment: .leading, spacing: 12) {
                Text("Wallpaper Folder:")
                    .bold()

                HStack {
                    TextField("Path", text: $wallpaperDirectory)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Browse") {
                        let panel = NSOpenPanel()
                        panel.canChooseDirectories = true
                        panel.canChooseFiles = false
                        panel.allowsMultipleSelection = false
                        panel.directoryURL = URL(fileURLWithPath: wallpaperDirectory)

                        if panel.runModal() == .OK, let selectedPath = panel.url?.path {
                            wallpaperDirectory = selectedPath
                        }
                    }
                }

                Button("Reset to Default") {
                    wallpaperDirectory = ThemeLoader.defaultPath.path
                }
            }
            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) {
                        updateLaunchAtLogin()
                    }
                Toggle("Show Quit Confirmation", isOn: $quitWarningEnabled)
                Text("Roation:")
                    .bold()
                Stepper(value: $rotationInterval, in: 1...120, step: 1) {
                    Text("Rotate Wallpaper Every: \(rotationInterval) minute\(rotationInterval == 1 ? "" : "s")")
                }
                Toggle("Pause Wallpaper Rotation", isOn: $rotationPaused)
                Toggle("Disable Rotation on Battery", isOn: $disableOnBattery)

            }

            Divider()

            HStack(alignment: .top, spacing: 16) {
                Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)
                    .shadow(radius: 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Wallpaper Theme Switcher")
                        .font(.headline)

                    Text("Version 1.0")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button(action: openGitHub) {
                        Label("GitHub Repository", systemImage: "link")
                    }
                    .buttonStyle(LinkButtonStyle())
                }
            }

            Spacer()
        }
        .padding(24)
        .frame(minWidth: 500, minHeight: 380)
    }

    func updateLaunchAtLogin() {
        let loginService = SMAppService.mainApp

        do {
            if launchAtLogin {
                try loginService.register()
                print("✅ App set to launch at login.")
            } else {
                try loginService.unregister()
                print("✅ App removed from login items.")
            }
        } catch {
            print("❌ Failed to update login item: \(error)")
        }
    }

    func openGitHub() {
        if let url = URL(string: "https://github.com/tinkernerd/MacWallpaperThemeSwitcher") {
            NSWorkspace.shared.open(url)
        }
    }
}
