import Foundation

class FlickrImageDownloader {
    static let shared = FlickrImageDownloader()
    
    let fileManager = FileManager.default

    func download(album: FlickrAlbum) {
        let destinationFolder = getAlbumFolder(albumTitle: album.title)
        createDirectoryIfNeeded(at: destinationFolder)

        FlickrService.shared.fetchAlbumPhotos(photosetId: album.id, userId: album.userId) { photos in
            let horizontalPhotos = photos.filter {
                if let w = $0.width, let h = $0.height {
                    return w > h
                }
                return false
            }

            DispatchQueue.main.async {
                SettingsStore.shared.updateDownloadProgress(
                    for: album.id,
                    downloaded: 0,
                    total: horizontalPhotos.count
                )
            }

            for photo in horizontalPhotos {
                let filename = "\(photo.title.snakeified())_\(photo.id).jpg"
                let fileURL = destinationFolder.appendingPathComponent(filename)

                if self.fileManager.fileExists(atPath: fileURL.path) {
                    print("📁 Skipping already downloaded photo: \(filename)")
                    DispatchQueue.main.async {
                        SettingsStore.shared.incrementDownloadedCount(for: album.id)
                    }
                    continue
                }

                URLSession.shared.downloadTask(with: photo.imageURL) { tempURL, _, error in
                    guard let tempURL = tempURL, error == nil else {
                        print("❌ Error downloading \(photo.imageURL): \(error?.localizedDescription ?? "unknown error")")
                        return
                    }

                    do {
                        try self.fileManager.moveItem(at: tempURL, to: fileURL)
                        print("✅ Downloaded: \(fileURL.lastPathComponent)")
                    } catch {
                        print("❌ Failed to move downloaded file: \(error)")
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
        let safeName = albumTitle.snakeified()
        return base.appendingPathComponent(safeName)
    }

    private func createDirectoryIfNeeded(at url: URL) {
        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
                print("📂 Created album folder: \(url.lastPathComponent)")
            } catch {
                print("❌ Failed to create folder: \(error)")
                DispatchQueue.main.async {
                    PermissionAlert.show()
                }
            }
        }
    }
}
