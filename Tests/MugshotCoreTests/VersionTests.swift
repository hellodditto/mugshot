import XCTest
@testable import MugshotCore

final class VersionTests: XCTestCase {
    func testVersion() {
        XCTAssertEqual(MugshotVersion, "0.2.0")
    }
}
