//
//  FlickrAlbum.swift
//  SceneSwitcher
//
//  Created by Nick Stull on 4/18/25.
//

import Foundation

struct FlickrAlbum: Identifiable, Codable, Equatable {
    let id: String              // Flickr Photoset ID
    let userId: String          // Flickr NSID
    var title: String           // Optional custom title
    var username: String        // Flickr display name
    let url: String             // Original album URL
    var isEnabled: Bool = true  // For use in rotation
    var shouldDownload: Bool = false
    var downloadedCount: Int = 0
    var totalCount: Int = 0

    static func == (lhs: FlickrAlbum, rhs: FlickrAlbum) -> Bool {
        return lhs.id == rhs.id && lhs.userId == rhs.userId
    }
}
