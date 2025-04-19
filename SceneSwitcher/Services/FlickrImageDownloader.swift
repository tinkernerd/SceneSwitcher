import Foundation

class FlickrImageDownloader {
    static let shared = FlickrImageDownloader()
    private let fileManager = FileManager.default

    func download(album: FlickrAlbum) {
        let destinationFolder = getAlbumFolder(albumTitle: album.title)
        createDirectoryIfNeeded(at: destinationFolder)

        AppLog.log("📥 Starting download for album: \(album.title)")

        FlickrService.shared.fetchAlbumPhotos(photosetId: album.id, userId: album.userId) { photos in
            let validPhotos = photos.filter { $0.isLandscape }
            let skipped = photos.count - validPhotos.count

            AppLog.log("📸 Total photos: \(photos.count)")
            AppLog.log("🌄 Landscape photos: \(validPhotos.count), ❌ Skipped: \(skipped)")

            DispatchQueue.main.async {
                SettingsStore.shared.updateDownloadProgress(
                    for: album.id,
                    downloaded: 0,
                    total: validPhotos.count
                )
            }

            for photo in validPhotos {
                guard let imageURL = photo.imageURL else {
                    AppLog.log("❌ Invalid image URL for photo: \(photo.title)")
                    continue
                }

                let filename = "\(photo.title.snakeified())_\(photo.id).jpg"
                let fileURL = destinationFolder.appendingPathComponent(filename)

                if self.fileManager.fileExists(atPath: fileURL.path) {
                    AppLog.log("⚠️ Skipping (already exists): \(filename)")
                    DispatchQueue.main.async {
                        SettingsStore.shared.incrementDownloadedCount(for: album.id)
                    }
                    continue
                }

                AppLog.log("⬇️ Downloading: \(imageURL.absoluteString) → \(filename)")

                URLSession.shared.downloadTask(with: imageURL) { tempURL, _, error in
                    if let error = error {
                        AppLog.log("❌ Download error: \(error.localizedDescription)")
                        return
                    }

                    guard let tempURL = tempURL else {
                        AppLog.log("❌ Download failed: No temporary file URL.")
                        return
                    }

                    do {
                        try self.fileManager.moveItem(at: tempURL, to: fileURL)
                        AppLog.log("✅ Saved to: \(fileURL.path)")
                    } catch {
                        AppLog.log("❌ File move error: \(error.localizedDescription)")
                    }

                    DispatchQueue.main.async {
                        SettingsStore.shared.incrementDownloadedCount(for: album.id)
                    }
                }.resume()
            }
        }
    }

    private func getAlbumFolder(albumTitle: String) -> URL {
        let base = URL(fileURLWithPath: SettingsStore.shared.wallpaperDirectory)
        return base.appendingPathComponent(albumTitle.snakeified())
    }

    private func createDirectoryIfNeeded(at url: URL) {
        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
                AppLog.log("📂 Created album folder: \(url.path)")
            } catch {
                AppLog.log("❌ Folder creation error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    PermissionAlert.show()
                }
            }
        }
    }
}
