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

extension ScreenshotDetectorTests {
    func testScreenRecordingEnglishName() {
        XCTAssertTrue(ScreenshotDetector.isScreenRecording(touch("Screen Recording 2026-07-03 at 22.10.00.mov")))
    }

    func testScreenRecordingLocalizedNameWithDate() {
        XCTAssertTrue(ScreenshotDetector.isScreenRecording(touch("화면 기록 2026-07-03 오후 10.10.00.mov")))
    }

    func testRandomMovIsNotRecording() {
        XCTAssertFalse(ScreenshotDetector.isScreenRecording(touch("holiday-video.mov")))
    }

    func testPngIsNotRecording() {
        XCTAssertFalse(ScreenshotDetector.isScreenRecording(touch("Screenshot 2026-07-03 at 22.10.00.png")))
    }
}
