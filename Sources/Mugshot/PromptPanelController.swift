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
    private var currentSaved = false

    /// Parity with the osascript dialog's `giving up after 120`.
    private let timeout: TimeInterval = 120

    init(strings: LocaleStrings) {
        self.strings = strings
    }

    func enqueue(_ url: URL) {
        queue.append(url)
        if panel == nil {
            showNext()
        } else {
            updateTitle()   // live "+N" badge while a panel is already up
        }
    }

    private func showNext() {
        guard !queue.isEmpty else { return }
        let file = queue.removeFirst()
        guard FileManager.default.fileExists(atPath: file.path) else {
            showNext()
            return
        }

        current = file
        currentSaved = false

        let view = PromptView(
            file: file,
            message: strings.randomMessage(),
            strings: strings,
            attemptSave: { [weak self] reason in
                self?.attemptSave(file: file, reason: reason) ?? .dismissed
            },
            onDismiss: { [weak self] in
                self?.dismiss(file: file)
            })
        let hosting = NSHostingView(rootView: view)

        let panel = PromptPanel(
            contentRect: .zero,
            styleMask: [.titled, .nonactivatingPanel],
            backing: .buffered, defer: false)
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.contentView = hosting
        panel.setContentSize(hosting.fittingSize)
        self.panel = panel
        updateTitle()

        // Slide in from just above the resting spot, like the system
        // screenshot thumbnail: subtle, short, and skippable by design.
        let resting = restingOrigin(for: panel)
        panel.setFrameOrigin(NSPoint(x: resting.x, y: resting.y + 12))
        panel.alphaValue = 0
        panel.makeKeyAndOrderFront(nil)
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.18
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
            panel.animator().setFrameOrigin(resting)
        }

        // .common mode so the timeout keeps ticking while a menu or a
        // modal panel (e.g. the Settings folder picker) is tracking.
        let timer = Timer(timeInterval: timeout, repeats: false) { [weak self] _ in
            Task { @MainActor in self?.dismiss(file: file) }
        }
        RunLoop.main.add(timer, forMode: .common)
        timeoutTimer = timer
    }

    /// Sanitize + rename + clipboard. Returns what the view should do next.
    private func attemptSave(file: URL, reason: String) -> PromptView.SaveOutcome {
        guard file == current else { return .dismissed }
        // A double-fired Enter (onSubmit + default action) must not rename
        // twice — the second call just reports the already-saved state.
        guard !currentSaved else { return .saved }
        let clean = ReasonSanitizer.sanitize(reason)
        if clean.isEmpty {
            // Parity with the Bash worker: an empty (or emptied) reason is a skip.
            dismiss(file: file)
            return .dismissed
        }
        do {
            let target = try RenamePlanner.rename(file, reason: clean)
            currentSaved = true
            if AppSettings.shared.copyAfterRename {
                let pb = NSPasteboard.general
                pb.clearContents()
                pb.writeObjects([target as NSURL])
            }
            return .saved
        } catch {
            // If the file itself is gone (trashed mid-prompt), retrying is
            // futile — resolve the panel like the old worker did.
            if !FileManager.default.fileExists(atPath: file.path) {
                dismiss(file: file)
                return .dismissed
            }
            // Otherwise (name too long, permissions, collision race) the
            // original is untouched; let the view show the failure.
            return .failed
        }
    }

    /// Close the current panel (skip, timeout, or after the saved-checkmark
    /// beat) and move on to the next queued screenshot.
    private func dismiss(file: URL) {
        // Ignore stale completions (e.g. a timeout landing after Save already
        // resolved this file and a different panel is now showing).
        guard file == current else { return }
        current = nil

        timeoutTimer?.invalidate()
        timeoutTimer = nil

        if let panel {
            self.panel = nil
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.15
                panel.animator().alphaValue = 0
            }, completionHandler: { [weak self] in
                panel.orderOut(nil)
                // After the fade, so panels never overlap.
                Task { @MainActor in self?.showNext() }
            })
        } else {
            showNext()
        }
    }

    private func updateTitle() {
        guard let panel else { return }
        panel.title = queue.isEmpty
            ? strings.dialogTitle
            : "\(strings.dialogTitle) (+\(queue.count))"
    }

    private func restingOrigin(for panel: NSPanel) -> NSPoint {
        guard let screen = NSScreen.main else { return .zero }
        let vf = screen.visibleFrame
        let size = panel.frame.size
        return NSPoint(x: vf.maxX - size.width - 16,
                       y: vf.maxY - size.height - 16)
    }
}
