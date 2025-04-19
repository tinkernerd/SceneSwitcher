import Foundation
import Combine
import SwiftUI

class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    // MARK: - General
    @AppStorage("wallpaperDirectory") var wallpaperDirectory: String = ThemeLoader.defaultPath.path
    @AppStorage("launchAtLogin") var launchAtLogin: Bool = false
    @AppStorage("rotationInterval") var rotationInterval: Int = 10
    @AppStorage("quitWarningEnabled") var quitWarningEnabled: Bool = true
    @AppStorage("rotationPaused") var rotationPaused: Bool = false
    @AppStorage("disableOnBattery") var disableOnBattery: Bool = false
    @AppStorage("flattenSingleSubthemes") var flattenSingleSubthemes: Bool = false

    // MARK: - Logging
    @AppStorage("loggingEnabled") var loggingEnabled: Bool = true
    @AppStorage("terminalLoggingEnabled") var terminalLoggingEnabled: Bool = true
    @AppStorage("fileLoggingEnabled") var fileLoggingEnabled: Bool = true
    @AppStorage("releaseMode") var releaseMode: Bool = false

    // MARK: - Flickr
    @Published var isFlickrKeyValid: Bool = false
    @AppStorage("flickrApiKey") var flickrApiKey: String = ""
    @AppStorage("flickrAlbums") private var encodedAlbums: String = "" {
        didSet {
            flickrAlbums = decodeAlbums(from: encodedAlbums)
        }
    }

    @Published var flickrAlbums: [FlickrAlbum] = []

    // MARK: - Init
    init() {
        flickrAlbums = decodeAlbums(from: encodedAlbums)

        // Optional: Automatically enable release mode in production builds
        #if !DEBUG
        releaseMode = true
        #endif
    }

    // MARK: - Album Management
    func updateAlbum(_ updated: FlickrAlbum) {
        if let index = flickrAlbums.firstIndex(of: updated) {
            flickrAlbums[index] = updated
            saveAlbums()
        }
    }

    func setAllAlbumsEnabled(_ enabled: Bool) {
        flickrAlbums = flickrAlbums.map { album in
            var updated = album
            updated.shouldDownload = enabled
            return updated
        }
        saveAlbums()
    }

    func updateDownloadProgress(for albumId: String, downloaded: Int, total: Int) {
        flickrAlbums = flickrAlbums.map { album in
            if album.id == albumId {
                var updated = album
                updated.downloadedCount = downloaded
                updated.totalCount = total
                return updated
            }
            return album
        }
    }

    func incrementDownloadedCount(for albumId: String) {
        flickrAlbums = flickrAlbums.map { album in
            if album.id == albumId {
                var updated = album
                updated.downloadedCount += 1
                return updated
            }
            return album
        }
    }

    // MARK: - Save / Load Albums
    func saveAlbums() {
        if let data = try? JSONEncoder().encode(flickrAlbums),
           let string = String(data: data, encoding: .utf8) {
            encodedAlbums = string
        }
    }

    private func decodeAlbums(from string: String) -> [FlickrAlbum] {
        guard let data = string.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([FlickrAlbum].self, from: data) else {
            return []
        }
        return decoded
    }
}
