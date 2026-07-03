import Foundation

/// The localized prompt strings. Loaded from the app bundle's .lproj tables;
/// hard English defaults if a table or key is missing (parity with the Bash
/// version's built-in fallbacks).
public struct LocaleStrings {
    public let dialogTitle: String
    public let btnSkip: String
    public let btnSave: String
    public let messages: [String]

    private static let missing = "\u{1}mugshot.missing\u{1}"

    public static func load(bundle: Bundle = .main) -> LocaleStrings {
        func lookup(_ key: String) -> String? {
            let v = bundle.localizedString(forKey: key, value: missing, table: nil)
            return v == missing ? nil : v
        }
        var msgs: [String] = []
        for i in 1...8 {
            if let m = lookup("msg.\(i)") { msgs.append(m) }
        }
        if msgs.isEmpty { msgs = ["📸 Name this screenshot"] }
        return LocaleStrings(
            dialogTitle: lookup("dialog.title") ?? "📸 mugshot",
            btnSkip: lookup("btn.skip") ?? "Skip",
            btnSave: lookup("btn.save") ?? "Save",
            messages: msgs
        )
    }

    public func randomMessage() -> String {
        messages.randomElement() ?? "📸 Name this screenshot"
    }
}
