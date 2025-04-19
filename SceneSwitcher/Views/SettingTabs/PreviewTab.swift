//
//  PreviewView.swift
//  WallpaperThemeSwitcher
//
//  Created by Nick Stull on 4/14/25.
//

import SwiftUI

struct PreviewTab: View {
    @State private var currentWallpaper: URL? = WallpaperManager.currentWallpaper()
    @State private var currentThemeName: String = UserDefaults.standard.string(forKey: "lastUsedTheme") ?? "None"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Wallpaper Preview")
                .font(.title2)
                .bold()

            Divider()

            Text("Current Theme:")
                .bold()

            if let themePath = WallpaperManager.currentThemePath() {
                let rawComponents = themePath.path
                    .replacingOccurrences(of: ThemeLoader.currentDirectory.path + "/", with: "")
                    .components(separatedBy: "/")

                let formattedName = rawComponents
                    .map { formatThemeName($0) }
                    .joined(separator: " / ")

                Button(action: {
                    NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: themePath.path)
                }) {
                    Label(formattedName, systemImage: "folder")
                }
                .buttonStyle(LinkButtonStyle())
                .onHover { inside in
                    if inside { NSCursor.pointingHand.push() }
                    else { NSCursor.pop() }
                }
            } else {
                Text("No Theme Loaded")
                    .italic()
                    .foregroundColor(.secondary)
            }

            Divider()

            Text("Current Wallpaper:")
                .bold()

            if let wallpaper = currentWallpaper {
                Button(action: {
                    NSWorkspace.shared.open(wallpaper)
                }) {
                    Label(wallpaper.lastPathComponent, systemImage: "photo")
                }
                .buttonStyle(LinkButtonStyle())
                .onHover { inside in
                    if inside { NSCursor.pointingHand.push() }
                    else { NSCursor.pop() }
                }

                if let nsImage = NSImage(contentsOf: wallpaper) {
                    Button(action: {
                        NSWorkspace.shared.open(wallpaper)
                    }) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .cornerRadius(8)
                            .shadow(radius: 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onHover { inside in
                        if inside { NSCursor.pointingHand.push() }
                        else { NSCursor.pop() }
                    }
                }
            } else {
                Text("No wallpaper currently set.")
                    .italic()
            }

            Spacer()
        }
        .padding()
        .onAppear {
            currentWallpaper = WallpaperManager.currentWallpaper()
            currentThemeName = UserDefaults.standard.string(forKey: "lastUsedTheme") ?? "None"
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
}
