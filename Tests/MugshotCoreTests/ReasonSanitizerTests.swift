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

extension ReasonSanitizerTests {
    func testStripsLeadingDotsAndDashes() {
        XCTAssertEqual(ReasonSanitizer.sanitize(".hidden"), "hidden")
        XCTAssertEqual(ReasonSanitizer.sanitize("--rf x"), "rf x")
        XCTAssertEqual(ReasonSanitizer.sanitize(".- .-"), "")
        XCTAssertEqual(ReasonSanitizer.sanitize("a-b.c"), "a-b.c")  // interior untouched
    }

    func testCapsLengthAt180UTF8Bytes() {
        let long = String(repeating: "가", count: 200)   // 600 UTF-8 bytes
        let out = ReasonSanitizer.sanitize(long)
        XCTAssertLessThanOrEqual(out.utf8.count, 180)
        XCTAssertFalse(out.isEmpty)
        XCTAssertTrue(out.allSatisfy { $0 == "가" })      // no broken scalars
        let ascii = String(repeating: "x", count: 500)
        XCTAssertEqual(ReasonSanitizer.sanitize(ascii).utf8.count, 180)
    }
}

extension ReasonSanitizerTests {
    func testUnicodeWhitespaceOnlyBecomesEmpty() {
        XCTAssertEqual(ReasonSanitizer.sanitize("\u{00A0}\u{00A0}"), "")
        XCTAssertEqual(ReasonSanitizer.sanitize("\u{3000} \u{2009}"), "")
        XCTAssertEqual(ReasonSanitizer.sanitize("\u{00A0}.hidden"), "hidden")
    }

    func testEmojiZWJSequencesSurvive() {
        XCTAssertEqual(ReasonSanitizer.sanitize("family 👨‍👩‍👧‍👦 trip"), "family 👨‍👩‍👧‍👦 trip")
    }

    func testBidiOverridesStillStripped() {
        XCTAssertEqual(ReasonSanitizer.sanitize("abc\u{202E}gnp.exe"), "abcgnp.exe")
    }
}
