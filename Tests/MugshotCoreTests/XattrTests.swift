import XCTest
@testable import MugshotCore

final class XattrTests: XCTestCase {
    var file: URL!

    override func setUpWithError() throws {
        file = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("mugshot-xattr-\(UUID().uuidString).txt")
        FileManager.default.createFile(atPath: file.path, contents: Data())
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: file)
    }

    func testSetHasRemove() {
        XCTAssertFalse(Xattr.has("com.test.flag", at: file.path))
        Xattr.set("com.test.flag", at: file.path)
        XCTAssertTrue(Xattr.has("com.test.flag", at: file.path))
        Xattr.remove("com.test.flag", at: file.path)
        XCTAssertFalse(Xattr.has("com.test.flag", at: file.path))
    }

    func testSeenMarkerUsesStaticAttr() {
        let seen = SeenMarker(user: "alice")
        XCTAssertEqual(seen.attrName, "com.hellodditto.mugshot.seen")
        XCTAssertFalse(seen.isSeen(file))
        seen.markSeen(file)
        XCTAssertTrue(seen.isSeen(file))
        XCTAssertTrue(Xattr.has("com.hellodditto.mugshot.seen", at: file.path))
        XCTAssertFalse(Xattr.has("com.alice.mugshot.seen", at: file.path))
        seen.unmark(file)
        XCTAssertFalse(seen.isSeen(file))
    }

    func testSeenMarkerRecognizesAndPurgesLegacyPerUserAttr() {
        let seen = SeenMarker(user: "alice")
        Xattr.set("com.alice.mugshot.seen", at: file.path)
        XCTAssertTrue(seen.isSeen(file))
        seen.unmark(file)
        XCTAssertFalse(seen.isSeen(file))
        XCTAssertFalse(Xattr.has("com.alice.mugshot.seen", at: file.path))
    }
}
