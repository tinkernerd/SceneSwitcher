import Foundation

class FlickrService {
    static let shared = FlickrService()

    private var apiKey: String {
        SettingsStore.shared.flickrApiKey
    }

    private let baseURL = "https://api.flickr.com/services/rest/"
    
    // MARK: Key Validation
    func validateKey(_ key: String) async -> Bool {
        guard let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.test.echo&api_key=\(key)&format=json&nojsoncallback=1") else {
            return false
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return json?["stat"] as? String == "ok"
        } catch {
            return false
        }
    }

    // MARK: - Fetch Photos from Album
    func fetchAlbumPhotos(photosetId: String, userId: String, completion: @escaping ([FlickrPhoto]) -> Void) {
        guard !apiKey.isEmpty else {
            AppLog.warn("⚠️ Flickr API key not set")
            completion([])
            return
        }

        let urlString = "\(baseURL)?method=flickr.photosets.getPhotos&api_key=\(apiKey)&photoset_id=\(photosetId)&user_id=\(userId)&extras=url_o,url_l,url_c,width_o,height_o,width_l,height_l,width_c,height_c&format=json&nojsoncallback=1"
        AppLog.info("📸 Fetching album photos: \(urlString)")

        guard let url = URL(string: urlString) else {
            AppLog.error("❌ Invalid URL")
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                AppLog.error("❌ No data: \(error?.localizedDescription ?? "unknown error")")
                completion([])
                return
            }

            if let raw = String(data: data, encoding: .utf8) {
                AppLog.info("📦 Album photos raw response: \(raw)")
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               json["stat"] as? String == "fail" {
                AppLog.error("❌ Flickr API Error: \(json)")
                completion([])
                return
            }

            do {
                let result = try JSONDecoder().decode(FlickrPhotosetResponse.self, from: data)
                completion(result.photoset.photo)
            } catch {
                AppLog.error("❌ JSON decode failed: \(error)")
                completion([])
            }
        }.resume()
    }

    // MARK: - Extract Photoset ID from Flickr Album URL
    func extractPhotosetId(from urlString: String) -> String? {
        guard let url = URL(string: urlString) else { return nil }
        let pathComponents = url.pathComponents

        if let albumIndex = pathComponents.firstIndex(of: "albums"),
           albumIndex + 1 < pathComponents.count {
            return pathComponents[albumIndex + 1]
        }

        return nil
    }

    // MARK: - Lookup User ID & Username from Album URL
    func lookupUserId(from url: String, completion: @escaping (String?, String?) -> Void) {
        guard !apiKey.isEmpty else {
            AppLog.warn("⚠️ Flickr API key not set")
            completion(nil, nil)
            return
        }

        let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let lookupUrl = "\(baseURL)?method=flickr.urls.lookupUser&api_key=\(apiKey)&url=\(encodedUrl)&format=json&nojsoncallback=1"
        AppLog.info("👤 Lookup user URL: \(lookupUrl)")

        guard let url = URL(string: lookupUrl) else {
            AppLog.error("❌ Invalid lookup URL")
            completion(nil, nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                AppLog.error("❌ No data: \(error?.localizedDescription ?? "unknown error")")
                completion(nil, nil)
                return
            }

            do {
                let result = try JSONDecoder().decode(FlickrLookupUserResponse.self, from: data)
                AppLog.info("✅ User ID: \(result.user.id), Username: \(result.user.username.content)")
                completion(result.user.id, result.user.username.content)
            } catch {
                AppLog.error("❌ Lookup decode failed: \(error)")
                if let raw = String(data: data, encoding: .utf8) {
                    AppLog.info("📦 User lookup response: \(raw)")
                }
                completion(nil, nil)
            }
        }.resume()
    }

    // MARK: - Fetch Album Title
    func fetchAlbumTitle(photosetId: String, userId: String, completion: @escaping (String?) -> Void) {
        guard !apiKey.isEmpty else {
            AppLog.warn("⚠️ Flickr API key not set")
            completion(nil)
            return
        }

        let urlString = "\(baseURL)?method=flickr.photosets.getInfo&api_key=\(apiKey)&photoset_id=\(photosetId)&user_id=\(userId)&format=json&nojsoncallback=1"
        AppLog.info("📝 Fetching album title: \(urlString)")

        guard let url = URL(string: urlString) else {
            AppLog.error("❌ Invalid album info URL")
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                AppLog.error("❌ No data for album info: \(error?.localizedDescription ?? "unknown error")")
                completion(nil)
                return
            }

            if let raw = String(data: data, encoding: .utf8) {
                AppLog.info("📦 Album info response: \(raw)")
            }

            do {
                let result = try JSONDecoder().decode(FlickrAlbumInfoResponse.self, from: data)
                AppLog.info("✅ Album title: \(result.photoset.title.content)")
                completion(result.photoset.title.content)
            } catch {
                AppLog.error("❌ Failed to decode album title: \(error)")
                completion(nil)
            }
        }
        .resume()
    }
}
