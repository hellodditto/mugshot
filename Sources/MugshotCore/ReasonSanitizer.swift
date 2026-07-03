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
        // Drop Cc controls and bidi embedding/override marks (filename
        // spoofing), but keep other format chars — ZWJ must survive or
        // family/profession emoji shred into their components.
        var s = String(String.UnicodeScalarView(
            raw.prefix(2048).unicodeScalars.filter { scalar in
                if scalar.properties.generalCategory == .control { return false }
                if (0x202A...0x202E).contains(scalar.value) { return false }
                if (0x2066...0x2069).contains(scalar.value) { return false }
                return true
            }
        ))
        s = String(s.map { "/:\\".contains($0) ? " " : $0 })
        while s.contains("  ") {
            s = s.replacingOccurrences(of: "  ", with: " ")
        }
        s = s.trimmingCharacters(in: .whitespaces)
        while let f = s.first, f == "." || f == "-" || f.isWhitespace {
            s.removeFirst()
        }
        while s.utf8.count > maxUTF8Bytes {
            s.removeLast()
        }
        return s.trimmingCharacters(in: .whitespaces)
    }
}
