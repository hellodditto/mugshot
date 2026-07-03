import Foundation
import MugshotCore

/// Wires the pipeline: folder change → scan → mark seen → prompt → rename.
@MainActor
final class PromptCoordinator {
    private let settings: AppSettings
    private let seen = SeenMarker()
    private var panel: PromptPanelController?
    private var watcher: ScreenshotWatcher?

    init(settings: AppSettings) {
        self.settings = settings
    }

    func start() {
        panel = PromptPanelController(strings: LocaleStrings.load())
        restartWatcher()
        scan()   // catch anything captured moments before launch
    }

    func restartWatcher() {
        watcher?.stop()
        watcher = ScreenshotWatcher(path: settings.watchedFolder) { [weak self] in
            self?.scan()
        }
    }

    private func scan() {
        guard !settings.paused, let panel else { return }
        let scanner = NewShotScanner(directory: URL(fileURLWithPath: settings.watchedFolder),
                                     seen: seen)
        for file in scanner.findNew() {
            // Mark first so a skipped/timed-out file is never asked about again.
            seen.markSeen(file)
            panel.enqueue(file)
        }
    }
}
