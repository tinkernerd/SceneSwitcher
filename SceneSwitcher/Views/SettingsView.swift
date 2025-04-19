//
//  SettingsView.swift
//  WallpaperThemeSwitcher
//
//  Created by Nick Stull on 4/18/25.
//

import SwiftUI

enum SettingsTab: Hashable {
    case general, flickr, preview, logging, about
}

struct SettingsView: View {
    @State private var selectedTab: SettingsTab = .general
    @ObservedObject private var settings = SettingsStore.shared

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsTab()
                .tag(SettingsTab.general)
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            FlickrAlbumsTab()
                .tag(SettingsTab.flickr)
                .tabItem {
                    Label("Flickr", systemImage: "photo.stack")
                }

            PreviewTab()
                .tag(SettingsTab.preview)
                .tabItem {
                    Label("Preview", systemImage: "eye")
                }

            if !settings.releaseMode {
                LoggingSettingsTab()
                    .tag(SettingsTab.logging)
                    .tabItem {
                        Label("Logging", systemImage: "terminal")
                    }
            }

            AboutTab()
                .tag(SettingsTab.about)
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .onChange(of: selectedTab) { _, newTab in
            adjustWindowSize(for: newTab)
        }
        .frame(minWidth: 500)
    }

    func adjustWindowSize(for tab: SettingsTab) {
        guard let window = NSApp.keyWindow else { return }

        let newHeight: CGFloat
        switch tab {
        case .general:
            newHeight = 600
        case .flickr:
            newHeight = 480
        case .preview:
            newHeight = 480
        case .logging:
            newHeight = 480
        case .about:
            newHeight = 400
        }

        var frame = window.frame
        let delta = newHeight - frame.height
        frame.origin.y -= delta
        frame.size.height += delta

        window.setFrame(frame, display: true, animate: true)
    }
}
