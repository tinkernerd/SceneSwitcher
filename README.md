## 📸 Wallpaper Theme Switcher for macOS

A lightweight macOS menu bar app that lets you switch between organized wallpaper themes, rotate wallpapers on a timer, and manage everything from a slick native UI.

---

### ✨ Features

- 🎨 Switch between wallpaper themes stored as folders
- 🖼 Preview the current wallpaper and theme
- 🔁 Automatic wallpaper rotation on a timer
- 🔋 Optional: pause on battery or disable entirely
- 🧠 Remembers the last used theme
- 🕹 Recent themes shown for quick access
- 💻 Launch on login toggle
- 🧼 Quit confirmation with toggleable warning
- ⚙️ Preferences and preview windows
- ✅ macOS-native SwiftUI interface

---

### 📁 Folder Structure

Organize your wallpapers like this:

```
~/Pictures/Wallpapers/
├── Nature/
│   ├── image1.jpg
│   └── image2.jpg
├── Anime/
│   ├── OnePiece/
│   │   ├── luffy.jpg
│   │   └── zoro.jpg
├── Drone_Night/
│   ├── city.jpg
```

- **Single-level folders** become top-level themes
- **Nested folders** are grouped into submenus

> Theme names like `drone_night` are automatically displayed as `Drone Night`

---

### 🧪 Preferences

- 🔁 Set rotation interval (1–120 minutes)
- 🔋 Disable rotation when on battery
- ❌ Pause rotation manually
- 🔒 Enable/disable quit warning
- 💻 Launch on login
- 📂 Change wallpaper directory

---

### 💻 Requirements

- macOS 12.0+
- Swift & Xcode to build

---

### 🛠 Build Instructions

1. Clone the repo:
   ```bash
   git clone https://github.com/tinkernerd/Wallpaper-Theme-Switcher.git
   ```
2. Open in Xcode
3. Build and run

> 🔒 To access the wallpaper folder, you may need to disable sandboxing in your project settings.

---

### 📦 Planned Features

- ✅ Drag-and-drop theme previews
- ✅ Status item icon themes (light/dark auto switch)
- ✅ Global hotkeys
- ✅ iCloud/Dropbox theme sync support

---

### 📜 License

MIT © [tinkernerd](https://github.com/tinkernerd)

