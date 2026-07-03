import XCTest
@testable import MugshotCore

final class ReasonSanitizerTests: XCTestCase {
    func testStripsSlashesColonsAndCollapsesSpaces() {
        XCTAssertEqual(ReasonSanitizer.sanitize("meeting/notes:  q3   plan"),
                       "meeting notes q3 plan")
    }

    func testTrimsLeadingAndTrailingSpaces() {
        XCTAssertEqual(ReasonSanitizer.sanitize("   hello   "), "hello")
    }

    func testRemovesControlCharacters() {
        XCTAssertEqual(ReasonSanitizer.sanitize("a\u{07}b\nc"), "abc")
    }

    func testBackslashBecomesSpace() {
        XCTAssertEqual(ReasonSanitizer.sanitize(#"a\b"#), "a b")
    }

    func testEmptyAfterSanitizing() {
        XCTAssertEqual(ReasonSanitizer.sanitize("  /:  "), "")
    }
}
