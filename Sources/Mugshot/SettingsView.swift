import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    @AppStorage("showMenuBarIcon") private var showMenuBarIcon = true
    @State private var launchAtLogin = LoginItem.isEnabled
    @State private var thumbnailOff = !SystemSettings.thumbnailEnabled()
    @State private var confirmRevert = false

    var body: some View {
        Form {
            Section("Watched folder") {
                LabeledContent("Folder") {
                    Text(settings.watchedFolder)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                HStack {
                    Button("Choose…") { chooseFolder() }
                    Button("Use ~/Screenshots") {
                        WatchedFolder.switchTo(WatchedFolder.dedicated)
                    }
                }
            }
            Section("Behavior") {
                Toggle("Turn off macOS floating thumbnail (prompt appears sooner)",
                       isOn: $thumbnailOff)
                    .onChange(of: thumbnailOff) { off in
                        guard off != !SystemSettings.thumbnailEnabled() else { return }
                        if off {
                            if settings.previousThumbnail == nil {
                                settings.previousThumbnail = "true"
                            }
                            SystemSettings.setThumbnailEnabled(false)
                        } else {
                            SystemSettings.setThumbnailEnabled(true)
                            settings.previousThumbnail = nil
                        }
                    }
                Toggle("Show menu bar icon", isOn: $showMenuBarIcon)
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { on in
                        guard on != LoginItem.isEnabled else { return }
                        LoginItem.set(on)
                    }
            }
            Section("About") {
                LabeledContent("Language",
                               value: Bundle.main.preferredLocalizations.first ?? "en")
                Button("Revert everything & quit…", role: .destructive) {
                    confirmRevert = true
                }
                .confirmationDialog(
                    "Restore the screenshot location and thumbnail, remove the login item, forget all settings, and quit? Renamed screenshots are never touched.",
                    isPresented: $confirmRevert) {
                    Button("Revert & Quit", role: .destructive) {
                        RevertService.revertAll(purgeXattr: false)
                    }
                    Button("Revert, strip seen-tags & Quit", role: .destructive) {
                        RevertService.revertAll(purgeXattr: true)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 480)
        .onAppear {
            launchAtLogin = LoginItem.isEnabled
            thumbnailOff = !SystemSettings.thumbnailEnabled()
        }
    }

    private func chooseFolder() {
        let p = NSOpenPanel()
        p.canChooseDirectories = true
        p.canChooseFiles = false
        p.allowsMultipleSelection = false
        NSApp.activate(ignoringOtherApps: true)
        if p.runModal() == .OK, let url = p.url {
            WatchedFolder.switchTo(url.path)
        }
    }
}
