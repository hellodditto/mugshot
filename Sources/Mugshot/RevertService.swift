import AppKit
import MugshotCore

@MainActor
enum WatchedFolder {
    /// Point both macOS's screenshot location and mugshot's watcher at `path`,
    /// remembering the original location for revert (first change only).
    static func switchTo(_ path: String) {
        let s = AppSettings.shared
        try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
        if s.previousLocation == nil {
            s.previousLocation = SystemSettings.screenshotLocation()
        }
        SystemSettings.setScreenshotLocation(path)
        s.watchedFolder = path
        AppDelegate.shared?.coordinator?.restartWatcher()
    }

    static var dedicated: String {
        NSString(string: "~/Screenshots").expandingTildeInPath
    }
}

/// The `mugshot uninstall` equivalent: undo every system change, optionally
/// strip seen-tags, forget all settings, quit. Renamed screenshots are never touched.
enum RevertService {
    static func revertAll(purgeXattr: Bool) {
        let s = AppSettings.shared
        if let prev = s.previousLocation {
            SystemSettings.setScreenshotLocation(prev)
        }
        if s.previousThumbnail != nil {
            SystemSettings.setThumbnailEnabled(true)
        }
        LoginItem.set(false)
        if purgeXattr {
            let seen = SeenMarker()
            let dir = URL(fileURLWithPath: s.watchedFolder)
            let files = (try? FileManager.default.contentsOfDirectory(
                at: dir, includingPropertiesForKeys: nil)) ?? []
            for f in files where ["png", "mov"].contains(f.pathExtension) {
                seen.unmark(f)
            }
        }
        if let bid = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bid)
        }
        NSApp.terminate(nil)
    }
}
