import SwiftUI
import ServiceManagement

struct GeneralSettingsTab: View {
    @ObservedObject private var settings = SettingsStore.shared
    @State private var hasAttemptedValidation = false
    @State private var keyIsValid: Bool? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Preferences")
                .font(.title)
                .bold()

            VStack(alignment: .leading, spacing: 12) {
                Text("Wallpaper Folder:")
                    .bold()

                HStack {
                    TextField("Path", text: $settings.wallpaperDirectory)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Browse") {
                        let panel = NSOpenPanel()
                        panel.canChooseDirectories = true
                        panel.canChooseFiles = false
                        panel.allowsMultipleSelection = false
                        panel.directoryURL = URL(fileURLWithPath: settings.wallpaperDirectory)

                        if panel.runModal() == .OK, let selectedPath = panel.url?.path {
                            settings.wallpaperDirectory = selectedPath
                        }
                    }
                }

                Button("Set to Default Folder") {
                    let defaultURL = ThemeLoader.defaultPath

                    if !FileManager.default.fileExists(atPath: defaultURL.path) {
                        do {
                            try FileManager.default.createDirectory(at: defaultURL, withIntermediateDirectories: true)
                        } catch {
                            return
                        }
                    }

                    SettingsStore.shared.wallpaperDirectory = defaultURL.path
                }

                Toggle("Treat single-subtheme folders as flat themes", isOn: $settings.flattenSingleSubthemes)

                Divider()

                Toggle("Launch at Login", isOn: $settings.launchAtLogin)
                    .onChange(of: settings.launchAtLogin) {
                        updateLaunchAtLogin()
                    }

                Toggle("Show Quit Confirmation", isOn: $settings.quitWarningEnabled)

                Text("Rotation:")
                    .bold()

                Stepper(value: $settings.rotationInterval, in: 1...120, step: 1) {
                    Text("Rotate Wallpaper Every: \(settings.rotationInterval) minute\(settings.rotationInterval == 1 ? "" : "s")")
                }

                Toggle("Pause Wallpaper Rotation", isOn: $settings.rotationPaused)
                Toggle("Disable Rotation on Battery", isOn: $settings.disableOnBattery)
            }

            Divider()

            Text("Flickr API")
                .font(.headline)

            Text("Flickr API Key:")
                .bold()

            TextField("Flickr API Key", text: $settings.flickrApiKey, onCommit: {
                Task {
                    hasAttemptedValidation = true
                    keyIsValid = await FlickrService.shared.validateKey(settings.flickrApiKey)
                }
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())

            if hasAttemptedValidation {
                if keyIsValid == true {
                    Text("✅ Key is valid")
                        .foregroundColor(.green)
                } else {
                    Text("❌ Invalid key or connection issue")
                        .foregroundColor(.red)
                }
            }

            Divider()
            Text("Reset Options: ").bold() + Text("Cannot Undo!")

            HStack(spacing: 12) {
                Button("Reset App Settings", role: .destructive) {
                    if let bundleID = Bundle.main.bundleIdentifier {
                        UserDefaults.standard.removePersistentDomain(forName: bundleID)
                        UserDefaults.standard.synchronize()
                        NSApp.terminate(nil)
                    }
                }

                Button("Remove Flickr API Key") {
                    SettingsStore.shared.flickrApiKey = ""
                }
            }
        }
        .padding(24)
    }

    func updateLaunchAtLogin() {
        let loginService = SMAppService.mainApp
        do {
            if settings.launchAtLogin {
                try loginService.register()
            } else {
                try loginService.unregister()
            }
        } catch {
            AppLog.error("❌ Failed to update login item: \(error)")
        }
    }
}
