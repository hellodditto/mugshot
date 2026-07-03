import Foundation

/// Port of bash `find_new()`: top-level `*.png` files in the watched folder
/// modified within the last `maxAge` seconds that look like screenshots and
/// haven't been prompted for yet.
public struct NewShotScanner {
    public let directory: URL
    public let maxAge: TimeInterval
    public let seen: SeenMarker

    public init(directory: URL, maxAge: TimeInterval = 60, seen: SeenMarker = SeenMarker()) {
        self.directory = directory
        self.maxAge = maxAge
        self.seen = seen
    }

    public func findNew(now: Date = Date()) -> [URL] {
        let keys: [URLResourceKey] = [.contentModificationDateKey, .isRegularFileKey]
        guard let items = try? FileManager.default.contentsOfDirectory(
            at: directory, includingPropertiesForKeys: keys,
            options: [.skipsSubdirectoryDescendants]) else { return [] }

        return items
            .filter { url in
                guard url.pathExtension == "png" else { return false }
                guard let values = try? url.resourceValues(forKeys: Set(keys)),
                      values.isRegularFile == true,
                      let mtime = values.contentModificationDate else { return false }
                guard now.timeIntervalSince(mtime) <= maxAge else { return false }
                guard ScreenshotDetector.isScreenshot(url) else { return false }
                return !seen.isSeen(url)
            }
            .map { url in
                // Reconstruct URL using the input directory's path to preserve symlink references
                directory.appendingPathComponent(url.lastPathComponent)
            }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }
}
