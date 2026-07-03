import XCTest
@testable import MugshotCore

final class ScreenshotDetectorTests: XCTestCase {
    var dir: URL!

    override func setUpWithError() throws {
        dir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("mugshot-detect-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: dir)
    }

    @discardableResult
    func touch(_ name: String) -> URL {
        let u = dir.appendingPathComponent(name)
        FileManager.default.createFile(atPath: u.path, contents: Data())
        return u
    }

    func testXattrTaggedFileIsScreenshot() {
        let f = touch("whatever.png")
        Xattr.set(ScreenshotDetector.screencapAttr, at: f.path)
        XCTAssertTrue(ScreenshotDetector.isScreenshot(f))
    }

    func testScreenshotPrefixName() {
        XCTAssertTrue(ScreenshotDetector.isScreenshot(touch("Screenshot 2026-07-01 at 14.30.05.png")))
    }

    func testDateAtPatternName() {
        XCTAssertTrue(ScreenshotDetector.isScreenshot(touch("2026-07-01 at 14.30.05.png")))
    }

    func testPlainFileIsNot() {
        XCTAssertFalse(ScreenshotDetector.isScreenshot(touch("vacation.png")))
    }

    func testDateWithoutAtIsNot() {
        XCTAssertFalse(ScreenshotDetector.isScreenshot(touch("report 2026-07-01 final.png")))
    }
}
