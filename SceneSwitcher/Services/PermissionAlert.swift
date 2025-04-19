//
//  PermissionAlert.swift
//  SceneSwitcher
//
//  Created by Nick Stull on 4/19/25.
//

import AppKit

struct PermissionAlert {
    static func show() {
        let alert = NSAlert()
        alert.messageText = "Access Denied"
        alert.informativeText = """
        This app doesn’t have permission to write to the selected wallpaper folder.

        To fix this, go to:
        System Settings > Privacy & Security > Full Disk Access
        and enable access for SceneSwitcher.
        """
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
