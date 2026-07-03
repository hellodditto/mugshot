import Foundation

public enum ReasonSanitizer {
    /// Keeps realistic renames under the 255-byte filename limit (reason +
    /// date tail + collision suffix + extension). Pathologically long
    /// original names can still overflow — the rename then fails and the
    /// panel shows it, leaving the file untouched.
    public static let maxUTF8Bytes = 180

    /// Port of the Bash `sanitize()`: drop control characters, replace
    /// `/`, `:`, `\` with spaces, squeeze space runs, trim. On top of the
    /// port: strip leading "."/"-" (dotfile / shell-flag hazards) and cap
    /// the length so realistic renames stay under the filename limit.
    public static func sanitize(_ raw: String) -> String {
        // Bound pasted novels before the quadratic space-squeeze below;
        // 2048 chars comfortably exceeds anything the byte cap can keep.
        var s = String(String.UnicodeScalarView(
            raw.prefix(2048).unicodeScalars.filter { !CharacterSet.controlCharacters.contains($0) }
        ))
        s = String(s.map { "/:\\".contains($0) ? " " : $0 })
        while s.contains("  ") {
            s = s.replacingOccurrences(of: "  ", with: " ")
        }
        s = s.trimmingCharacters(in: CharacterSet(charactersIn: " "))
        while let f = s.first, f == "." || f == "-" || f == " " {
            s.removeFirst()
        }
        while s.utf8.count > maxUTF8Bytes {
            s.removeLast()
        }
        return s.trimmingCharacters(in: CharacterSet(charactersIn: " "))
    }
}
