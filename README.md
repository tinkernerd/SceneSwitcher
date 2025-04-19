## 📸 SceneSwitcher for macOS

**SceneSwitcher** is a lightweight macOS menu bar app that lets you rotate desktop wallpapers using themed folders or synced Flickr albums — all from a clean native interface.

---

## 📦 Versions

| Version | Status       | Description                             |
|---------|--------------|-----------------------------------------|
| ![version](https://img.shields.io/badge/version-0.1.0-blue) | ✅ Released   | Folder-based themes + wallpaper rotation |
| ![version](https://img.shields.io/badge/version-0.2.0-blue) | 🚧 In Dev     | Flickr integration, photo downloading    |

📋 [Changelog](./CHANGELOG.md) — see what’s new!

---

### ✨ Features

- 🎨 Switch between wallpaper themes stored as local folders
- 📂 Add Flickr albums as themes — downloads originals
- 🔁 Automatic wallpaper rotation on a timer
- 🖼 Preview current wallpaper and theme path
- 🔋 Optional: pause on battery or disable entirely
- ✅ Skips already-downloaded Flickr images
- 📸 Filters for landscape-oriented images only
- 🧠 Remembers last used theme, shows recent ones in menu
- ⚙️ Native macOS Preferences with:
  - Launch on login
  - Rotation interval
  - Flatten theme folders
  - Reset app and API key
  - Change wallpaper directory
- 🧼 First-launch setup with folder prompt
- 🔎 Check for updates via GitHub API
- ✅ Swift + SwiftUI native macOS app (no Electron)

---

### 📁 Folder Structure

By default, SceneSwitcher uses:  
`~/Pictures/Wallpapers/`

You can also choose a custom folder in Preferences.

```
~/Pictures/Wallpapers/
├── Nature/
│   ├── image1.jpg
├── Anime/
│   ├── OnePiece/
│   │   ├── luffy.jpg
├── Drone_Night/
│   ├── city.jpg
```

- Folder names are prettified (`drone_night` → `Drone Night`)
- Nested folders become grouped submenus
- Optional flattening for themes with a single subfolder

---

### 📷 Flickr Integration (v0.2.0+)

Add any public Flickr album and SceneSwitcher will:

- 🧠 Automatically detect the album + user
- ⬇️ Download original-resolution **landscape** photos
- ✅ Skip images already saved locally
- 📸 Save albums to your selected wallpaper folder
- 🎛 Enable or disable individual albums for download

#### 🔐 Setup

1. [Create a Flickr API Key](https://www.flickr.com/services/apps/create/)
2. Paste your key into Preferences → Flickr tab
3. Add album links and manage them inside the app

---

### 🧪 Preferences & Utilities

- ⏱ Set wallpaper rotation interval (1–120 min)
- ⏸ Pause rotation manually
- 🔋 Disable on battery power
- ⚙️ Launch at login
- 📂 Change or reset the wallpaper folder
- 📦 Reset app settings (non-destructive)
- 🔑 Remove Flickr API key
- 🔄 Flatten single-subtheme themes (optional)

---

### 🔄 Update Checker

- Checks against [latest GitHub release](https://github.com/tinkernerd/SceneSwitcher/releases/latest)
- If current version is older, opens download page
- Otherwise shows "You're up to date"

---

### 🛠 Install & Build

```bash
git clone https://github.com/tinkernerd/SceneSwitcher.git
cd SceneSwitcher
open SceneSwitcher.xcodeproj
```

> Be sure to **disable sandboxing** to allow access to:
> - Wallpaper folder
> - Clipboard (for API key entry)
> - File system

---


Awesome — that’s a super clean, expressive format! Here’s your updated section fully integrated using your preferred style:

---

### 📦 Roadmap & Upcoming Ideas

- 📤 **Import/Export Flickr Config**  
  Save and restore album setups to quickly move between machines or share presets

- 🎛 **Theme Selector**  
  Choose which themes show up in the menu bar and hide the rest for cleaner access

- 🔁 **Download Themes from GitHub**  
  Use a GitHub API token to pull wallpapers directly from a public or private repo  
  > May require Git integration for sync and versioning support

- ☁️ **Cloud Sync Support**  
  Automatically pull themes from:
  - 🟦 OneDrive
  - 🟢 Dropbox
  - 🍎 iCloud

- 🧠 **Smart Filters**  
  Allow filtering wallpapers by:
  - Orientation (landscape only)
  - File type (`jpg`, `heic`, etc.)
  - Tags or filename patterns

- 🔐 **Flickr API Key in Keychain**  
  Secure key storage via macOS Keychain instead of `@AppStorage`

- 🧹 **Cleaner First-Time Setup**  
  More polished first-run experience with default folder check, permissions prompt, and helpful intro guide

---


### 💻 Requirements

- macOS 12.0 or later
- Xcode 15+
- Flickr API Key for online album sync

---

### 🧑‍💻 Author

**Nick Stull**  
[github.com/tinkernerd](https://github.com/tinkernerd)

---

### 📜 License

MIT © [tinkernerd](https://github.com/tinkernerd)

---

### 👩‍💻 Developer Notes

If you're working on the code or contributing to the app, check out the [Developer README](./README.dev.md) for build details, architecture, API notes, and feature planning.

👉 See [VERSIONING.md](./VERSIONING.md) for release strategy and tagging
