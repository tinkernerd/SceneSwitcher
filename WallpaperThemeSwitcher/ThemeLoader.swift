//
//  ThemeLoader.swift
//  WallpaperThemeSwitcher
//
//  Created by Nick Stull on 4/13/25.
//

import Foundation
struct ThemeGroup {
    let name: String
    let themes: [WallpaperTheme]
}

class ThemeLoader {
    static var defaultPath: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Pictures/Wallpapers")
    }


    static var currentDirectory: URL {
        let stored = UserDefaults.standard.string(forKey: "wallpaperDirectory")
        return URL(fileURLWithPath: stored ?? defaultPath.path)
    }


    static func loadThemes(completion: @escaping ([WallpaperTheme], [ThemeGroup]) -> Void) {
        DispatchQueue.global().async {
            let basePath = currentDirectory
            print("📂 Loading themes from: \(basePath.path)")

            var flatThemes: [WallpaperTheme] = []
            var groupedThemes: [ThemeGroup] = []

            guard let topFolders = try? FileManager.default.contentsOfDirectory(
                at: basePath,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            ) else {
                print("❌ Failed to read contents of: \(basePath.path)")
                DispatchQueue.main.async { completion([], []) }
                return
            }

            for folder in topFolders where folder.hasDirectoryPath {
                print("🔍 Checking folder: \(folder.lastPathComponent)")

                let subfolders = (try? FileManager.default.contentsOfDirectory(
                    at: folder,
                    includingPropertiesForKeys: nil,
                    options: .skipsHiddenFiles
                )) ?? []

                let themeSubfolders = subfolders.filter { $0.hasDirectoryPath }

                if themeSubfolders.isEmpty {
                    print("✅ Flat Theme: \(folder.lastPathComponent)")
                    let theme = WallpaperTheme(name: folder.lastPathComponent, folderURL: folder)
                    if !theme.imageURLs.isEmpty {
                        flatThemes.append(theme)
                    }
                } else {
                    print("📁 Theme Group: \(folder.lastPathComponent)")
                    for sub in themeSubfolders {
                        print("   └─ SubTheme: \(sub.lastPathComponent)")
                    }
                    let subThemes = themeSubfolders.map {
                        WallpaperTheme(name: $0.lastPathComponent, folderURL: $0)
                    }.filter { !$0.imageURLs.isEmpty }

                    let flatten = UserDefaults.standard.bool(forKey: "flattenSingleSubthemes")
                    if flatten, subThemes.count == 1 {
                        let single = WallpaperTheme(name: folder.lastPathComponent, folderURL: subThemes[0].folderURL)
                        flatThemes.append(single)
                    }
                        else if !subThemes.isEmpty {
                        let group = ThemeGroup(name: folder.lastPathComponent, themes: subThemes)
                        groupedThemes.append(group)
                    }
                }
            }

            print("📦 Total flat themes: \(flatThemes.count), grouped themes: \(groupedThemes.count)")

            DispatchQueue.main.async {
                completion(flatThemes, groupedThemes)
            }
        }
    }


}
