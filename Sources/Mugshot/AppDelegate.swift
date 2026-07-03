import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    static private(set) var shared: AppDelegate!

    let settings = AppSettings.shared
    private(set) var coordinator: PromptCoordinator?
    private var onboardingWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        if settings.onboardingDone {
            startWatching()
        } else {
            showOnboarding()
        }
    }

    @MainActor
    func startWatching() {
        let c = PromptCoordinator(settings: settings)
        c.start()
        coordinator = c
    }

    @MainActor
    private func showOnboarding() {
        let view = OnboardingView { [weak self] in
            self?.onboardingWindow?.close()
            self?.onboardingWindow = nil
            self?.startWatching()
        }
        let win = NSWindow(contentViewController: NSHostingController(rootView: view))
        win.title = "mugshot"
        win.styleMask = [.titled, .closable]
        win.isReleasedWhenClosed = false
        win.center()
        win.delegate = self
        NSApp.activate(ignoringOtherApps: true)
        win.makeKeyAndOrderFront(nil)
        onboardingWindow = win
    }

    func windowWillClose(_ notification: Notification) {
        guard (notification.object as? NSWindow) === onboardingWindow else { return }
        onboardingWindow = nil
        // Closing onboarding without Start = accept defaults: no system changes, start watching.
        if !settings.onboardingDone {
            settings.onboardingDone = true
            startWatching()
        }
    }

    @MainActor
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // LSUIElement app with the menu bar icon off: re-opening the app is the
        // user's only path back to Settings. (Ignore reopen while onboarding is up.)
        if onboardingWindow == nil, !flag {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        }
        return true
    }
}
