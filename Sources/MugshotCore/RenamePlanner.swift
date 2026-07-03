import Foundation

public enum RenamePlanner {
    /// Port of bash `target_path()`: keep the original name's date/time tail
    /// (starting at the LAST `YYYY-MM-DD` occurrence, matching the greedy sed),
    /// prefix it with the reason, keep the extension, and dodge collisions
    /// with " (2)", " (3)", …
    public static func targetURL(for file: URL, reason: String) -> URL {
        let dir = file.deletingLastPathComponent()
        let base = file.lastPathComponent
        let stem: String
        let ext: String
        if let dot = base.lastIndex(of: "."), dot != base.startIndex {
            stem = String(base[..<dot])
            ext = String(base[dot...])
        } else {
            stem = base
            ext = ""
        }

        let name: String
        if let tail = dateTailRange(in: stem) {
            name = "\(reason) \(stem[tail.lowerBound...])"
        } else {
            name = reason
        }

        var target = dir.appendingPathComponent(name + ext)
        var n = 2
        while FileManager.default.fileExists(atPath: target.path) {
            target = dir.appendingPathComponent("\(name) (\(n))\(ext)")
            n += 1
        }
        return target
    }

    @discardableResult
    public static func rename(_ file: URL, reason: String) throws -> URL {
        let target = targetURL(for: file, reason: reason)
        try FileManager.default.moveItem(at: file, to: target)
        return target
    }

    private static func dateTailRange(in stem: String) -> Range<String.Index>? {
        let regex = try! NSRegularExpression(pattern: "[0-9]{4}-[0-9]{2}-[0-9]{2}")
        let full = NSRange(stem.startIndex..., in: stem)
        guard let last = regex.matches(in: stem, range: full).last,
              let r = Range(last.range, in: stem) else { return nil }
        return r
    }
}
