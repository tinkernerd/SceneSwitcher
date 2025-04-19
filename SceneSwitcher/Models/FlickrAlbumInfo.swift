import Foundation

struct FlickrAlbumInfoResponse: Codable {
    let photoset: FlickrAlbumInfo
    let stat: String
}

struct FlickrAlbumInfo: Codable {
    let id: String
    let title: FlickrAlbumTitle
}

struct FlickrAlbumTitle: Codable {
    let content: String

    enum CodingKeys: String, CodingKey {
        case content = "_content"
    }
}
