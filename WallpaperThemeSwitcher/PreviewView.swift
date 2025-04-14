//
//  PreviewView.swift
//  WallpaperThemeSwitcher
//
//  Created by Nick Stull on 4/14/25.
//

import SwiftUI

struct PreviewView: View {
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
                let basePath = ThemeLoader.currentDirectory
                let relativeComponents = themePath.path
                    .replacingOccurrences(of: basePath.path + "/", with: "")
                    .components(separatedBy: "/")

                HStack(spacing: 4) {
                    if relativeComponents.count == 1 {
                        // 🔹 Only a main theme
                        let mainPath = basePath.appendingPathComponent(relativeComponents[0])

                        Button(action: {
                            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: mainPath.path)
                        }) {
                            Label(relativeComponents[0], systemImage: "folder")
                        }
                        .buttonStyle(LinkButtonStyle())
                        .onHover { inside in
                            if inside { NSCursor.pointingHand.push() }
                            else { NSCursor.pop() }
                        }

                    } else if relativeComponents.count == 2 {
                        // 🔹 Main / Subtheme (two folders)
                        let mainTheme = relativeComponents[0]
                        let subTheme = relativeComponents[1]

                        let mainPath = basePath.appendingPathComponent(mainTheme)
                        let subPath = mainPath.appendingPathComponent(subTheme)

                        Button(action: {
                            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: mainPath.path)
                        }) {
                            Text(mainTheme)
                        }
                        .buttonStyle(LinkButtonStyle())
                        .onHover { inside in
                            if inside { NSCursor.pointingHand.push() }
                            else { NSCursor.pop() }
                        }

                        Text("/")
                            .foregroundColor(.secondary)

                        Button(action: {
                            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: subPath.path)
                        }) {
                            Text(subTheme)
                        }
                        .buttonStyle(LinkButtonStyle())
                        .onHover { inside in
                            if inside { NSCursor.pointingHand.push() }
                            else { NSCursor.pop() }
                        }
                    }
                }
            } else {
                Text("None")
            }

            Divider()

            Text("Current Wallpaper:")
                .bold()

            if let wallpaper = currentWallpaper {
                Button(action: {
                    NSWorkspace.shared.activateFileViewerSelecting([wallpaper])
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
        .frame(minWidth: 500, minHeight: 520)
        .onAppear {
            currentWallpaper = WallpaperManager.currentWallpaper()
            currentThemeName = UserDefaults.standard.string(forKey: "lastUsedTheme") ?? "None"
        }
    }
}
