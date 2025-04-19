import Foundation

struct FlickrPhotosetResponse: Codable {
    let photoset: FlickrPhotoset
}

struct FlickrPhotoset: Codable {
    let photo: [FlickrPhoto]
}

struct FlickrPhoto: Codable, Identifiable {
    let id: String
    let title: String
    let farm: Int
    let server: String
    let secret: String
    let width_o: Int?
    let height_o: Int?

    // MARK: - Orientation filter helpers
    var isLandscape: Bool {
        guard let w = width_o, let h = height_o else { return false }
        return w > h
    }

    // MARK: - Full resolution image URL (_o = original)
    var imageURL: URL? {
        URL(string: "https://live.staticflickr.com/\(server)/\(id)_\(secret)_o.jpg")
    }
}
