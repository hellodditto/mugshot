import XCTest
@testable import MugshotCore

final class LocaleStringsTests: XCTestCase {
    // repo-root/Resources, located relative to this test file
    static let resourcesURL = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()   // Tests/MugshotCoreTests
        .deletingLastPathComponent()   // Tests
        .deletingLastPathComponent()   // repo root
        .appendingPathComponent("Resources")

    func testAll16LocalesHaveAllKeys() throws {
        let expected = ["dialog.title", "btn.skip", "btn.save", "field.placeholder"] + (1...8).map { "msg.\($0)" }
        let lprojs = try FileManager.default
            .contentsOfDirectory(at: Self.resourcesURL, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "lproj" }
        XCTAssertEqual(lprojs.count, 16)
        for lproj in lprojs {
            let data = try Data(contentsOf: lproj.appendingPathComponent("Localizable.strings"))
            let plist = try PropertyListSerialization.propertyList(from: data, format: nil)
            let dict = try XCTUnwrap(plist as? [String: String], lproj.lastPathComponent)
            for key in expected {
                let value = dict[key]
                XCTAssertNotNil(value, "\(lproj.lastPathComponent) missing \(key)")
                XCTAssertFalse(value?.isEmpty ?? true, "\(lproj.lastPathComponent) empty \(key)")
            }
        }
    }

    func testLoadFromBundle() throws {
        let bundle = try XCTUnwrap(Bundle(url: Self.resourcesURL))
        let s = LocaleStrings.load(bundle: bundle)
        XCTAssertFalse(s.dialogTitle.isEmpty)
        XCTAssertFalse(s.btnSkip.isEmpty)
        XCTAssertFalse(s.btnSave.isEmpty)
        XCTAssertEqual(s.messages.count, 8)
        XCTAssertTrue(s.messages.contains(s.randomMessage()))
    }

    func testMissingBundleFallsBackToEnglishDefaults() {
        let empty = Bundle(url: URL(fileURLWithPath: NSTemporaryDirectory()))!
        let s = LocaleStrings.load(bundle: empty)
        XCTAssertEqual(s.dialogTitle, "📸 mugshot")
        XCTAssertEqual(s.btnSkip, "Skip")
        XCTAssertEqual(s.btnSave, "Save")
        XCTAssertEqual(s.messages, ["📸 Name this screenshot"])
    }
}
