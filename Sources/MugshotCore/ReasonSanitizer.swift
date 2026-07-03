import Foundation

public enum ReasonSanitizer {
    /// Port of the Bash `sanitize()`: drop control characters, replace
    /// `/`, `:`, `\` with spaces, squeeze space runs, trim.
    public static func sanitize(_ raw: String) -> String {
        var s = String(String.UnicodeScalarView(
            raw.unicodeScalars.filter { !CharacterSet.controlCharacters.contains($0) }
        ))
        s = String(s.map { "/:\\".contains($0) ? " " : $0 })
        while s.contains("  ") {
            s = s.replacingOccurrences(of: "  ", with: " ")
        }
        return s.trimmingCharacters(in: CharacterSet(charactersIn: " "))
    }
}
