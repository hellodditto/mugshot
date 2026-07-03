import Foundation

/// Reads/writes the two macOS screencapture settings mugshot touches,
/// via the `defaults` CLI — identical semantics to the Bash version.
enum SystemSettings {
    @discardableResult
    private static func run(_ tool: String, _ args: [String]) -> String? {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: tool)
        p.arguments = args
        let out = Pipe()
        p.standardOutput = out
        p.standardError = Pipe()
        do { try p.run() } catch { return nil }
        p.waitUntilExit()
        guard p.terminationStatus == 0 else { return nil }
        let data = out.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    @discardableResult
    private static func defaults(_ args: [String]) -> String? {
        run("/usr/bin/defaults", args)
    }

    private static func restartUIServer() {
        run("/usr/bin/killall", ["SystemUIServer"])
    }

    static func screenshotLocation() -> String {
        defaults(["read", "com.apple.screencapture", "location"])
            ?? NSString(string: "~/Desktop").expandingTildeInPath
    }

    static func setScreenshotLocation(_ path: String) {
        defaults(["write", "com.apple.screencapture", "location", path])
        restartUIServer()
    }

    static func thumbnailEnabled() -> Bool {
        let v = defaults(["read", "com.apple.screencapture", "show-thumbnail"]) ?? "1"
        return v != "0" && v != "false"
    }

    static func setThumbnailEnabled(_ on: Bool) {
        defaults(["write", "com.apple.screencapture", "show-thumbnail", "-bool",
                  on ? "true" : "false"])
        restartUIServer()
    }
}
