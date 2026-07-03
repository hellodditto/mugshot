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
}
