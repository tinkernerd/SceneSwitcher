//
//  LoggingSettingsTab.swift
//  WallpaperThemeSwitcher
//
//  Created by Nick Stull on 4/19/25.
//

import SwiftUI

struct LoggingSettingsTab: View {
    @ObservedObject private var settings = SettingsStore.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Logging Settings")
                .font(.title)
                .bold()

            if settings.releaseMode {
                Label("Logging is disabled in Release Mode.", systemImage: "lock.slash")
                    .foregroundColor(.secondary)
                    .padding(.top)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable Logging", isOn: $settings.loggingEnabled)
                        .toggleStyle(SwitchToggleStyle())

                    Toggle("Log to Terminal", isOn: $settings.terminalLoggingEnabled)
                        .disabled(!settings.loggingEnabled)

                    Toggle("Log to File", isOn: $settings.fileLoggingEnabled)
                        .disabled(!settings.loggingEnabled)

                    HStack {
                        Button("🧹 Clear Logs") {
                            AppLog.clear()
                        }
                        .disabled(!settings.loggingEnabled)

                        Button("📂 Open Log Files Folder") {
                            AppLog.openLogFolderInFinder()
                        }
                        .disabled(!settings.loggingEnabled)

                        Button("📄 View Latest Log in Console") {
                            AppLog.openLatestLogInConsole()
                        }
                        .disabled(!settings.loggingEnabled || AppLog.latestExistingLogFile == nil)

                    }
                }
                .padding(.top)
            }

            Divider()

            Toggle("Release Mode (Disable Logging)", isOn: $settings.releaseMode)
                .help("Disables all logging and hides the Logging tab in production builds.")

            Spacer()
        }
        .padding(24)
    }
}
