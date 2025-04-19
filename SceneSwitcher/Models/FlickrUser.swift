import Foundation

struct FlickrLookupUserResponse: Codable {
    let user: FlickrUser
    let stat: String
}

struct FlickrUser: Codable {
    let id: String
    let username: FlickrUsername

    struct FlickrUsername: Codable {
        let content: String

        enum CodingKeys: String, CodingKey {
            case content = "_content"
        }
    }
}
