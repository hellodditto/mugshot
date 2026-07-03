import XCTest
@testable import MugshotCore

final class NewShotScannerTests: XCTestCase {
    var dir: URL!
    var scanner: NewShotScanner!

    override func setUpWithError() throws {
        dir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("mugshot-scan-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        scanner = NewShotScanner(directory: dir)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: dir)
    }

    @discardableResult
    func touch(_ name: String, age: TimeInterval = 0) throws -> URL {
        let u = dir.appendingPathComponent(name)
        FileManager.default.createFile(atPath: u.path, contents: Data())
        if age > 0 {
            try FileManager.default.setAttributes(
                [.modificationDate: Date().addingTimeInterval(-age)], ofItemAtPath: u.path)
        }
        return u
    }

    func testFindsRecentUnseenScreenshot() throws {
        let f = try touch("Screenshot 2026-07-01 at 14.30.05.png")
        XCTAssertEqual(scanner.findNew(), [f])
    }

    func testIgnoresOldFiles() throws {
        try touch("Screenshot 2026-07-01 at 14.30.05.png", age: 7200)
        XCTAssertEqual(scanner.findNew(), [])
    }

    func testIgnoresSeenFiles() throws {
        let f = try touch("Screenshot 2026-07-01 at 14.30.05.png")
        SeenMarker().markSeen(f)
        XCTAssertEqual(scanner.findNew(), [])
    }

    func testIgnoresNonPng() throws {
        try touch("Screenshot 2026-07-01 at 14.30.05.jpg")
        XCTAssertEqual(scanner.findNew(), [])
    }

    func testIgnoresNonScreenshots() throws {
        try touch("vacation.png")
        XCTAssertEqual(scanner.findNew(), [])
    }

    func testIgnoresSubdirectories() throws {
        let sub = dir.appendingPathComponent("Screenshot 2026-07-01 at 14.30.05.png.d")
        try FileManager.default.createDirectory(at: sub, withIntermediateDirectories: true)
        XCTAssertEqual(scanner.findNew(), [])
    }

    func testMissingDirectoryReturnsEmpty() {
        let s = NewShotScanner(directory: dir.appendingPathComponent("nope"))
        XCTAssertEqual(s.findNew(), [])
    }
}

extension NewShotScannerTests {
    func testFindsRecentScreenRecordingMov() throws {
        let f = try touch("Screen Recording 2026-07-03 at 22.10.00.mov")
        XCTAssertEqual(scanner.findNew(), [f])
    }

    func testIgnoresRandomMov() throws {
        try touch("holiday-video.mov")
        XCTAssertEqual(scanner.findNew(), [])
    }
}
