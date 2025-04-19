import Foundation
import AppKit

enum LogLevel: String {
    case info, warn, error

    var prefix: String {
        switch self {
        case .info: return "ℹ️"
        case .warn: return "⚠️"
        case .error: return "❌"
        }
    }
}

class AppLog {
    static let logFolder: URL = FileManager.default
        .homeDirectoryForCurrentUser
        .appendingPathComponent("Documents/SceneSwitcherLogs", isDirectory: true)

    // MARK: - Main Logging Entry
    static func log(_ message: String, level: LogLevel = .info) {
        guard SettingsStore.shared.loggingEnabled else { return }

        let timestamp = formattedTimestamp()
        let fullMessage = "[\(timestamp)] \(level.prefix) \(message)"

        if SettingsStore.shared.terminalLoggingEnabled {
            print(fullMessage)
        }

        if SettingsStore.shared.fileLoggingEnabled {
            writeToFile(fullMessage, level: level)
        }
    }

    // MARK: - Helpers
    static func info(_ message: String)  { log(message, level: .info) }
    static func warn(_ message: String)  { log(message, level: .warn) }
    static func error(_ message: String) { log(message, level: .error) }

    // MARK: - Clear Logs
    static func clear() {
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: logFolder, includingPropertiesForKeys: nil)
            for file in contents where file.pathExtension == "log" {
                try FileManager.default.removeItem(at: file)
            }
            info("🧹 Log files cleared.")
        } catch let err {
            print("❌ Failed to clear log files: \(err.localizedDescription)")
        }
    }

    // MARK: - Open Locations
    static func openLogFolderInFinder() {
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: logFolder.path)
    }

    static func openLatestLogInConsole() {
        guard let file = latestExistingLogFile else {
            print("❌ No log file found.")
            return
        }

        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-a", "Console", file.path]

        do {
            try task.run()
        } catch let err {
            print("❌ Failed to open log in Console: \(err.localizedDescription)")
        }
    }

    // MARK: - Latest Log File
    static var latestExistingLogFile: URL? {
        guard FileManager.default.fileExists(atPath: logFolder.path) else { return nil }

        let files = (try? FileManager.default.contentsOfDirectory(at: logFolder, includingPropertiesForKeys: [.contentModificationDateKey])) ?? []
        let logs = files.filter { $0.pathExtension == "log" }

        return logs.sorted {
            let aDate = (try? $0.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            let bDate = (try? $1.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate) ?? .distantPast
            return aDate > bDate
        }.first
    }

    // MARK: - Write to File
    private static func writeToFile(_ message: String, level: LogLevel) {
        do {
            if !FileManager.default.fileExists(atPath: logFolder.path) {
                try FileManager.default.createDirectory(at: logFolder, withIntermediateDirectories: true)
            }

            let logFile = logFileURL(for: level)
            let messageData = (message + "\n").data(using: .utf8)!

            if FileManager.default.fileExists(atPath: logFile.path) {
                if let fileHandle = try? FileHandle(forWritingTo: logFile) {
                    try fileHandle.seekToEnd()
                    fileHandle.write(messageData)
                    try fileHandle.close()
                }
            } else {
                try messageData.write(to: logFile)
            }
        } catch let err {
            print("❌ Failed to write log: \(err.localizedDescription)")
        }
    }

    // MARK: - Log File Path
    static func logFileURL(for level: LogLevel) -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())

        return logFolder.appendingPathComponent("\(dateString)_\(level.rawValue).log")
    }

    // MARK: - Timestamp
    private static func formattedTimestamp() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let utc = formatter.string(from: Date())

        let offsetSeconds = TimeZone.current.secondsFromGMT()
        let hours = offsetSeconds / 3600
        let minutes = abs(offsetSeconds % 3600) / 60
        let sign = offsetSeconds >= 0 ? "+" : "-"

        let offset = String(format: "%@%02d:%02d", sign, abs(hours), minutes)
        return "\(utc) (\(offset))"
    }
}
