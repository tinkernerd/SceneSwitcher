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

    // Sizes (optional depending on extras returned)
    let width_o: Int?
    let height_o: Int?
    let width_l: Int?
    let height_l: Int?
    let width_c: Int?
    let height_c: Int?

    let url_o: String?
    let url_l: String?
    let url_c: String?

    // MARK: - Orientation filter helpers
    var isLandscape: Bool {
        if let w = width_o, let h = height_o {
            return w > h
        } else if let w = width_l, let h = height_l {
            return w > h
        } else if let w = width_c, let h = height_c {
            return w > h
        } else {
            return true // fallback: assume landscape
        }
    }

    // MARK: - Best available image URL
    var imageURL: URL? {
        if let url = url_o { return URL(string: url) }
        if let url = url_l { return URL(string: url) }
        if let url = url_c { return URL(string: url) }
        return nil
    }
}
