# 🧑‍💻 SceneSwitcher – Developer Documentation

This guide is for contributors or developers working on SceneSwitcher.  
For user instructions and features, see the main [README.md](./README.md).

---

## 🧱 Project Structure

```
SceneSwitcher/
├── Core/               # App delegate, settings, loaders
│   ├── AppDelegate.swift
│   ├── SettingsStore.swift
│   ├── ThemeLoader.swift
│   └── WallpaperManager.swift
│
├── Models/             # Codable structs and shared types
│   ├── FlickrAlbum.swift
│   ├── FlickrPhoto.swift
│   └── FlickrUser.swift
│
├── Services/           # Flickr API, download manager, utils
│   ├── FlickrService.swift
│   ├── FlickrImageDownloader.swift
│   └── Utils.swift
│
├── Views/
│   └── SettingTabs/    # Tabbed settings content
│       ├── GeneralSettingsTab.swift
│       ├── FlickrAlbumsTab.swift
│       ├── PreviewTab.swift
│       └── AboutTab.swift
├── Utilities/
│   └── AppLog.swift        # Terminal/file logging handler
│
├── Components/
│   └── CocoaTextField.swift
│
├── SceneSwitcherApp.swift
└── Assets.xcassets / Info.plist
```

---

## ⚙️ Build & Setup

### 1. Clone and Open in Xcode

```bash
git clone https://github.com/tinkernerd/SceneSwitcher.git
cd SceneSwitcher
open SceneSwitcher.xcodeproj
```

### 2. Disable App Sandbox

To allow file system access, clipboard, and downloads:

- Open project settings
- Go to `Signing & Capabilities`
- Remove **App Sandbox** or disable:
  - File read/write
  - Network access
  - Pasteboard

> 🔐 Required for Flickr albums, download folder access, and user interaction

---
### 🔖 Tagging a Release

Use [SemVer](./VERSIONING.md) and tag like so:

```bash
git tag v0.2.0
git push origin v0.2.0
```
---

## 🔧 Key App Behaviors

| Feature                    | File                        |
|---------------------------|-----------------------------|
| App initialization        | `AppDelegate.swift`         |
| Menu bar setup            | `setupMenu()` in AppDelegate |
| Preferences logic         | `SettingsStore.swift`       |
| Theme loading             | `ThemeLoader.swift`         |
| Wallpaper switching       | `WallpaperManager.swift`    |
| Flickr API integration    | `FlickrService.swift`       |
| Download manager          | `FlickrImageDownloader.swift` |
| Logging system            | `AppLog.swift`                |


---

## 🔐 Flickr Integration Notes

- API key stored in `@AppStorage("flickrApiKey")`
- Use `FlickrService.shared.validateKey()` to check
- No user authentication required — only album lookup + download
- API key is **never uploaded**

---

## 🧪 Testing Tips

- Use **Reset App Settings** in General tab to clear UserDefaults
- Or wipe from terminal:
  ```bash
  defaults delete com.tinkernerd.SceneSwitcher
  ```

- Remove sandbox app data:
  ```bash
  rm -rf ~/Library/Containers/Tinkernerd.SceneSwitcher
  ```
  
- Logs stored in `~/Documents/SceneSwitcherLogs`
- Logs rotate daily and include log level in filename
- Log output appears in Xcode console or macOS Console.app

---

## 🛠 Branches

| Branch                | Purpose                              |
|-----------------------|--------------------------------------|
| `main`                | Stable public releases ([tags](https://github.com/tinkernerd/SceneSwitcher/tags)) |
| `flickr-integration`  | Ongoing work toward `v0.2.0`         |
| `feature/...`         | Experimental or upcoming features    |

---

## 🛣 Roadmap for Contributors

- [ ] GitHub-based theme import with personal token
- [ ] Cloud sync (Dropbox / OneDrive / iCloud)
- [ ] Keychain-backed API key storage
- [ ] Smart rotation filtering (landscape, tags)
- [ ] Drag-and-drop theme organizer
- [ ] Localization support

---

## 👥 Credits & Maintainer

Developed by [Nick Stull (tinkernerd)](https://github.com/tinkernerd)  
License: MIT

