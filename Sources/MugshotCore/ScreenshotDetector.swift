import Foundation

public enum ScreenshotDetector {
    public static let screencapAttr = "com.apple.metadata:kMDItemIsScreenCapture"

    /// Port of bash `is_screenshot()`: macOS-tagged as a screen capture, or
    /// named like one ("Screenshot …" / "…YYYY-MM-DD at …").
    public static func isScreenshot(_ url: URL) -> Bool {
        if Xattr.has(screencapAttr, at: url.path) { return true }
        let base = url.lastPathComponent
        if base.hasPrefix("Screenshot ") { return true }
        return base.range(of: "[0-9]{4}-[0-9]{2}-[0-9]{2} at ",
                          options: .regularExpression) != nil
    }

    /// Cmd-Shift-5 screen recordings. macOS doesn't xattr-tag these, and
    /// localized names ("화면 기록 …") drop the " at ", so a .mov carrying
    /// the system's date stamp in its name counts.
    public static func isScreenRecording(_ url: URL) -> Bool {
        guard url.pathExtension == "mov" else { return false }
        let base = url.lastPathComponent
        if base.hasPrefix("Screen Recording ") { return true }
        return base.range(of: "[0-9]{4}-[0-9]{2}-[0-9]{2}",
                          options: .regularExpression) != nil
    }
}
