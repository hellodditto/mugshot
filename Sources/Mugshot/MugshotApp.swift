import SwiftUI

@main
struct MugshotApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("showMenuBarIcon") private var showMenuBarIcon = false
    @ObservedObject private var settings = AppSettings.shared

    var body: some Scene {
        MenuBarExtra("mugshot", systemImage: "camera.viewfinder",
                     isInserted: $showMenuBarIcon) {
            Button(settings.paused ? "Resume watching" : "Pause watching") {
                settings.paused.toggle()
            }
            settingsButton
            Divider()
            Button("Quit mugshot") { NSApp.terminate(nil) }
        }
        Settings { SettingsView() }
    }

    @ViewBuilder
    private var settingsButton: some View {
        if #available(macOS 14.0, *) {
            SettingsLink { Text("Settings…") }
        } else {
            Button("Settings…") {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }
        }
    }
}
