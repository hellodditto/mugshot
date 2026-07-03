import AppKit
import SwiftUI
import MugshotCore

/// A panel that can take key status (for the text field) without activating
/// the app or stealing focus from whatever the user is doing.
final class PromptPanel: NSPanel {
    override var canBecomeKey: Bool { true }
}

@MainActor
final class PromptPanelController {
    private let strings: LocaleStrings
    private var queue: [URL] = []
    private var panel: PromptPanel?
    private var timeoutTimer: Timer?
    private var current: URL?

    /// Parity with the osascript dialog's `giving up after 120`.
    private let timeout: TimeInterval = 120

    init(strings: LocaleStrings) {
        self.strings = strings
    }

    func enqueue(_ url: URL) {
        queue.append(url)
        if panel == nil { showNext() }
    }

    private func showNext() {
        guard !queue.isEmpty else { return }
        let file = queue.removeFirst()
        guard FileManager.default.fileExists(atPath: file.path) else {
            showNext()
            return
        }

        current = file

        let view = PromptView(file: file, message: strings.randomMessage(),
                              strings: strings) { [weak self] reason in
            self?.finish(file: file, reason: reason)
        }
        let hosting = NSHostingView(rootView: view)

        let panel = PromptPanel(
            contentRect: .zero,
            styleMask: [.titled, .nonactivatingPanel],
            backing: .buffered, defer: false)
        panel.title = strings.dialogTitle
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentView = hosting
        panel.setContentSize(hosting.fittingSize)
        position(panel)
        panel.makeKeyAndOrderFront(nil)
        self.panel = panel

        timeoutTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            Task { @MainActor in self?.finish(file: file, reason: nil) }
        }
    }

    private func finish(file: URL, reason: String?) {
        // Ignore stale completions (e.g. a timeout Task landing after Save already
        // resolved this file and a different panel is now showing).
        guard file == current else { return }
        current = nil

        timeoutTimer?.invalidate()
        timeoutTimer = nil
        panel?.orderOut(nil)
        panel = nil

        if let reason {
            let clean = ReasonSanitizer.sanitize(reason)
            if !clean.isEmpty {
                // Rename failure (file vanished, permissions) leaves the
                // original untouched — parity with the Bash worker.
                _ = try? RenamePlanner.rename(file, reason: clean)
            }
        }
        showNext()
    }

    private func position(_ panel: NSPanel) {
        guard let screen = NSScreen.main else { return }
        let vf = screen.visibleFrame
        let size = panel.frame.size
        panel.setFrameOrigin(NSPoint(x: vf.maxX - size.width - 16,
                                     y: vf.maxY - size.height - 16))
    }
}
