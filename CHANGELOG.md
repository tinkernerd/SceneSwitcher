# 📦 Changelog – SceneSwitcher

All notable changes to this project will be documented in this file.  
Follows [Semantic Versioning](./VERSIONING.md). 
// I solemnly swear I won't abuse PATCH bumps for typos (probably) — This changelog is mainly for developers (and a little for humans too)

---
## [0.2.0] - 2025-04-19

### Added
- New `Logging` tab in Settings with options to:
  - Enable/disable terminal logging
  - Enable/disable file logging
  - Open latest log in Finder
  - View latest log in Console
  - Clear all logs
- Introduced `AppLog` utility for hybrid logging:
  - Logs messages to both terminal and file based on user settings
  - Supports log levels: `info`, `warn`, `error` (with emoji prefixes)
  - Timestamps are in UTC with local offset (e.g., `2025-04-19T14:00:00Z (+04:00)`)
  - Logs are saved in `~/Documents/SceneSwitcherLogs/`
- Logging now splits into separate files:
  - Per-day and per-level (e.g. `2025-04-19_info.log`, `2025-04-19_error.log`)
  - Automatically rotates daily for easier management
- Release Mode setting added:
  - Disables logging completely and hides the Logging tab when enabled

### Changed
- Moved all debug `print()` statements to use `AppLog`
- Refactored SettingsStore to include `loggingEnabled`, `terminalLoggingEnabled`, and `fileLoggingEnabled` flags

### Fixed
- Crash caused by recursive `AppLog.log` calls
- Clarified timestamp format and added UTC offset display in log entries

## [0.2.0] - Upcoming
> 🚧 **Unreleased — in development on `flickr-integration` branch**

### ✨ New
- **Flickr album integration**
  - Add Flickr albums via public album URL
  - Lookup username and user ID via Flickr API
  - Fetch album info and title for display
  - Parse and store album config in `@AppStorage` via `SettingsStore`
  - Preview images inline with `AsyncImage`
  - Download button to fetch all selected albums
  - Only downloads landscape-oriented images (uses `width_o > height_o` logic)
  - Auto-skips already downloaded images based on filename check
  - Stored in default wallpaper directory under folder using `snake_case` album name
- **Album Management**
  - Enable/Disable albums per checkbox (`isEnabled` flag)
  - Enable All / Disable All UI buttons
  - Persistent state for each album (saved in JSON string)
  - Album UI shows username, progress (downloadedCount/totalCount), and actions
- **Flickr API UI**
  - Custom CocoaTextField for better clipboard support
  - Helper UI when API key is missing:
    - Link to Flickr API page
    - Copy button for URL
    - Real-time validator after paste (calls Flickr method to verify key)
- **Reset Options (General Tab)**
  - Reset all app settings
  - Set to default wallpaper folder (~/Pictures/Wallpapers)
  - Remove Flickr API key only
- **Fallbacks and Permissions**
  - Checks for Full Disk Access / file permissions
  - If unable to access wallpaper folder:
    - Prompts to create default folder or choose another
    - Offers "Exit" if declined

### 🐛 Fixes
- Preview tab shows "No Theme Loaded" when no current theme
- Sandbox removed to restore:
  - Clipboard support (Cmd+C/Cmd+V)
  - File write access to ~/Pictures
- Default path now uses `FileManager.default.urls(for: .picturesDirectory)` instead of container path
- `onChange(of:)` updated to use newer SwiftUI syntax (macOS 14 compatibility)
- Theme reload now properly shows Recent Themes on launch

### 📦 Structure
- `README.dev.md` added with developer build info
- `VERSIONING.md` created to document SemVer logic
- Project structure reorganized:
  - Core/
  - Models/
  - Services/
  - Views/SettingTabs/
  - Components/
- `CHANGELOG.md` and version tags introduced for traceable releases

---

## [0.1.0] - 2025-04-20
> 🎉 **Initial stable release**

### ✨ Features
- Switch between local wallpaper themes stored in folders
- Set rotation interval from 1–120 minutes
- Pause rotation manually or when on battery
- Preview current theme name and wallpaper thumbnail
- Show last 3 recent themes for quick re-application
- Preferences window (settings) and Preview window
- Quit confirmation with toggle in preferences
- Launch on login option
- Auto-format theme folder names (snake_case -> Title Case)

### 🛠 Build Details
- Written in Swift (SwiftUI + AppKit)
- Status bar app with dynamic NSMenu
- WallpaperManager applies wallpapers using Apple APIs
- ThemeLoader reads folder structure under ~/Pictures/Wallpapers

---

