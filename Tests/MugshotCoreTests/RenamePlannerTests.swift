import XCTest
@testable import MugshotCore

final class RenamePlannerTests: XCTestCase {
    var dir: URL!

    override func setUpWithError() throws {
        dir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("mugshot-tests-\(UUID().uuidString)")
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

    func testReasonFirstThenOriginalDateTail() {
        let f = touch("스크린샷 2026-07-02 오후 6.32.09.png")
        XCTAssertEqual(RenamePlanner.targetURL(for: f, reason: "회의록 정리").lastPathComponent,
                       "회의록 정리 2026-07-02 오후 6.32.09.png")
    }

    func testReasonOnlyWhenNoDate() {
        let f = touch("randomimage.png")
        XCTAssertEqual(RenamePlanner.targetURL(for: f, reason: "hello").lastPathComponent,
                       "hello.png")
    }

    func testCollisionAddsSuffix() {
        let f = touch("스크린샷 2026-07-02 오후 6.32.09.png")
        touch("dup 2026-07-02 오후 6.32.09.png")
        XCTAssertEqual(RenamePlanner.targetURL(for: f, reason: "dup").lastPathComponent,
                       "dup 2026-07-02 오후 6.32.09 (2).png")
    }

    func testLastDateInNameWins() {
        // bash used a greedy `.*` before the capture, i.e. the LAST date starts the tail
        let f = touch("shot 2026-01-01 copy 2026-07-02 at 14.30.05.png")
        XCTAssertEqual(RenamePlanner.targetURL(for: f, reason: "x").lastPathComponent,
                       "x 2026-07-02 at 14.30.05.png")
    }

    func testNoExtension() {
        let f = touch("Screenshot 2026-07-01 at 14.30.05")
        XCTAssertEqual(RenamePlanner.targetURL(for: f, reason: "x").lastPathComponent,
                       "x 2026-07-01 at 14.30.05")
    }

    func testRenameMovesFile() throws {
        let f = touch("Screenshot 2026-07-01 at 14.30.05.png")
        let target = try RenamePlanner.rename(f, reason: "bug repro")
        XCTAssertEqual(target.lastPathComponent, "bug repro 2026-07-01 at 14.30.05.png")
        XCTAssertTrue(FileManager.default.fileExists(atPath: target.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: f.path))
    }
}
