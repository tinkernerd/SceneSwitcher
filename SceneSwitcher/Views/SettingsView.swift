import SwiftUI

enum SettingsTab: Hashable {
    case general, flickr, preview, about
}

struct SettingsView: View {
    @State private var selectedTab: SettingsTab = .general

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsTab()
                .tag(SettingsTab.general)
                .tabItem {Image(systemName: "gearshape")}

            FlickrAlbumsTab()
                .tag(SettingsTab.flickr)
                .tabItem {Image(systemName: "photo.stack") }

            PreviewTab()
                .tag(SettingsTab.preview)
                .tabItem {Image(systemName: "eye") }

            AboutTab()
                .tag(SettingsTab.about)
                .tabItem {Image(systemName: "info.circle") }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            adjustWindowSize(for: newValue)
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
