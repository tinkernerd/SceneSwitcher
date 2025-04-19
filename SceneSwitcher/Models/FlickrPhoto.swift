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
    let width: Int?
    let height: Int?

    var imageURL: URL {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_b.jpg")!
    }
}
