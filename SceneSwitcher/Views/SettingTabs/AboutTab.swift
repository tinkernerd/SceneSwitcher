//
//  AboutTab.swift
//  WallpaperThemeSwitcher
//
//  Created by Nick Stull on 4/18/25.
//

import SwiftUI

struct AboutTab: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("About")
                .font(.title2)
                .bold()

            HStack(spacing: 16) {
                Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)
                    .shadow(radius: 2)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Wallpaper Theme Switcher")
                        .font(.headline)

                    Text("Version 0.0.1")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            Button(action: {
                if let url = URL(string: "https://github.com/tinkernerd/MacWallpaperThemeSwitcher") {
                    NSWorkspace.shared.open(url)
                }
            }) {
                Label("GitHub Repository", systemImage: "link")
            }
            .buttonStyle(LinkButtonStyle())

            Button(action: checkForUpdates) {
                Label("Check for Updates", systemImage: "arrow.down.circle")
            }
            .buttonStyle(LinkButtonStyle())


            Spacer()
        }
        .padding(24)
    }
    func checkForUpdates() {
        guard let url = URL(string: "https://api.github.com/repos/tinkernerd/SceneSwitcher/releases/latest") else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                AppLog.error("❌ Failed to fetch release info: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let latestVersion = json["tag_name"] as? String {

                    let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"

                    if latestVersion == "v\(current)" {
                        DispatchQueue.main.async {
                            let alert = NSAlert()
                            alert.messageText = "✅ You're up to date!"
                            alert.informativeText = "Version \(current) is the latest."
                            alert.runModal()
                        }
                    } else if let releaseUrl = URL(string: json["html_url"] as? String ?? "") {
                        DispatchQueue.main.async {
                            NSWorkspace.shared.open(releaseUrl)
                        }
                    }
                }
            } catch {
                AppLog.error("❌ Error parsing release JSON: \(error)")
            }
        }.resume()
    }

}
