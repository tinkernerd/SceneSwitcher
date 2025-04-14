//
//  WallpaperTheme.swift
//  WallpaperThemeSwitcher
//
//  Created by Nick Stull on 4/13/25.
//

import Foundation
import AppKit

struct WallpaperTheme {
    let name: String
    let folderURL: URL

    var imageURLs: [URL] {
        let files = (try? FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)) ?? []

        return files.filter { url in
            let validExtensions = ["jpg", "jpeg", "png", "heic"]
            guard validExtensions.contains(url.pathExtension.lowercased()) else { return false }

            guard let image = NSImage(contentsOf: url),
                  let rep = image.representations.first else {
                return false
            }

            let width = rep.pixelsWide
            let height = rep.pixelsHigh

            let isLandscape = width > height
            let meetsResolution = width >= 1280 && height >= 720 // Adjust if needed

            return isLandscape && meetsResolution
        }
    }
}
