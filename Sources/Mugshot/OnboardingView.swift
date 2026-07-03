import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var useDedicated = false
    @State private var disableThumbnail = true
    @State private var launchAtLogin = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📸 Welcome to Mugshot")
                .font(.title2).bold()
            Text("You take a screenshot. Mugshot asks why. The file gets renamed to your answer.")
                .foregroundStyle(.secondary)

            Toggle(isOn: $useDedicated) {
                VStack(alignment: .leading) {
                    Text("Use a dedicated ~/Screenshots folder")
                    Text("Switches the macOS screenshot location; keeps your desktop clean. Reverted if you ever revert Mugshot.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            Toggle(isOn: $disableThumbnail) {
                VStack(alignment: .leading) {
                    Text("Turn off the floating screenshot thumbnail")
                    Text("The thumbnail delays the file write, so Mugshot's dialog appears late. Recommended.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            Toggle(isOn: $launchAtLogin) {
                Text("Launch Mugshot at login")
            }

            HStack {
                Spacer()
                Button("Start") { apply() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 440)
    }

    private func apply() {
        let s = AppSettings.shared
        if useDedicated {
            WatchedFolder.switchTo(WatchedFolder.dedicated)
        }
        if disableThumbnail && SystemSettings.thumbnailEnabled() {
            if s.previousThumbnail == nil { s.previousThumbnail = "true" }
            SystemSettings.setThumbnailEnabled(false)
        }
        if launchAtLogin {
            LoginItem.set(true)
        }
        s.onboardingDone = true
        onFinish()
    }
}
