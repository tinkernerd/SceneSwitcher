import SwiftUI

struct FlickrAlbumsTab: View {
    @ObservedObject private var settings = SettingsStore.shared
    @State private var albumUrl: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var previewPhotos: [FlickrPhoto] = []

    var body: some View {
        if settings.flickrApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("🔑 Flickr API Key Required")
                    .font(.title2).bold()

                Text("This feature won’t work until you enter a Flickr API key in Preferences → Flickr.")

                HStack(spacing: 12) {
                    Button("Open Flickr API Page") {
                        if let url = URL(string: "https://www.flickr.com/services/apps/create/") {
                            NSWorkspace.shared.open(url)
                        }
                    }

                    Button("Copy API Page URL") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString("https://www.flickr.com/services/apps/create/", forType: .string)
                    }
                }

                Text("Steps to get your key:")
                    .bold()

                VStack(alignment: .leading, spacing: 6) {
                    Text("1. Visit the link above")
                    Text("2. Log in with your Flickr account")
                    Text("3. Create a non-commercial app")
                    Text("4. Copy the API key into the app's Preferences")
                }

                Spacer()
            }
            .padding()
        } else {
            VStack(alignment: .leading, spacing: 16) {
                Text("Flickr Albums")
                    .font(.title2)
                    .bold()

                Text("Paste a Flickr album URL:")
                CocoaTextField(text: $albumUrl)
                    .frame(height: 24)

                Button("Add Album") {
                    addAlbum(from: albumUrl)
                }

                if isLoading {
                    ProgressView("Loading...")
                } else if let error = errorMessage {
                    Text("❌ \(error)").foregroundColor(.red)
                }

                Divider()

                HStack {
                    Text("Saved Albums")
                        .font(.headline)
                    Spacer()

                    if !settings.flickrAlbums.isEmpty {
                        Button("Enable All") {
                            settings.setAllAlbumsEnabled(true)
                        }
                        Button("Disable All") {
                            settings.setAllAlbumsEnabled(false)
                        }
                        Button("Download") {
                            for album in settings.flickrAlbums where album.shouldDownload {
                                FlickrImageDownloader.shared.download(album: album)
                            }
                        }
                    }
                }

                if settings.flickrAlbums.isEmpty {
                    Text("No albums saved yet.")
                        .foregroundColor(.secondary)
                } else {
                    List {
                        ForEach(settings.flickrAlbums) { album in
                            HStack(alignment: .center, spacing: 12) {
                                Toggle("", isOn: Binding(
                                    get: { album.shouldDownload },
                                    set: { newValue in
                                        var updated = album
                                        updated.shouldDownload = newValue
                                        settings.updateAlbum(updated)
                                    }
                                ))
                                .labelsHidden()

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(album.title).bold()

                                    if album.totalCount > 0 {
                                        Text("\(album.downloadedCount) / \(album.totalCount)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Text(album.username)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                HStack(spacing: 12) {
                                    Link(destination: URL(string: album.url)!) {
                                        Label("Link", systemImage: "link")
                                            .labelStyle(IconOnlyLabelStyle())
                                    }

                                    Button("Preview") {
                                        loadAlbum(album)
                                    }

                                    Button(role: .destructive) {
                                        deleteAlbum(album)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .frame(height: 220)
                }

                if !previewPhotos.isEmpty {
                    Divider()
                    ScrollView(.horizontal) {
                        HStack(spacing: 12) {
                            ForEach(previewPhotos) { photo in
                                AsyncImage(url: photo.imageURL) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 100)
                                            .cornerRadius(8)
                                    case .failure:
                                        Image(systemName: "exclamationmark.triangle")
                                    default:
                                        ProgressView()
                                    }
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(24)
        }
    }

    func addAlbum(from url: String) {
        errorMessage = nil
        isLoading = true

        guard let photosetId = FlickrService.shared.extractPhotosetId(from: url) else {
            errorMessage = "Invalid album URL."
            isLoading = false
            return
        }

        FlickrService.shared.lookupUserId(from: url) { userId, username in
            guard let userId = userId else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to resolve user ID."
                    self.isLoading = false
                }
                return
            }

            FlickrService.shared.fetchAlbumTitle(photosetId: photosetId, userId: userId) { title in
                let cleanTitle = title?.trimmingCharacters(in: .whitespacesAndNewlines)
                let finalTitle = (cleanTitle?.isEmpty == false) ? cleanTitle! : photosetId

                let album = FlickrAlbum(
                    id: photosetId,
                    userId: userId,
                    title: finalTitle,
                    username: username ?? "",
                    url: url,
                    isEnabled: true
                )

                DispatchQueue.main.async {
                    if !self.settings.flickrAlbums.contains(album) {
                        self.settings.flickrAlbums.append(album)
                        self.settings.saveAlbums()
                    }
                    self.albumUrl = ""
                    self.isLoading = false
                }
            }
        }
    }

    func loadAlbum(_ album: FlickrAlbum) {
        errorMessage = nil
        isLoading = true
        previewPhotos = []

        FlickrService.shared.fetchAlbumPhotos(photosetId: album.id, userId: album.userId) { photos in
            DispatchQueue.main.async {
                self.previewPhotos = photos
                self.isLoading = false
                if photos.isEmpty {
                    self.errorMessage = "Album loaded but contains no photos."
                }
            }
        }
    }

    func deleteAlbum(_ album: FlickrAlbum) {
        settings.flickrAlbums.removeAll { $0 == album }
        settings.saveAlbums()
    }
}
