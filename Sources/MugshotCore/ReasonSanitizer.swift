import Foundation

public enum ReasonSanitizer {
    /// Filenames on APFS cap at 255 UTF-8 bytes; leave room for the
    /// original date/time tail, a collision suffix, and the extension.
    public static let maxUTF8Bytes = 180

    /// Port of the Bash `sanitize()`: drop control characters, replace
    /// `/`, `:`, `\` with spaces, squeeze space runs, trim. On top of the
    /// port: strip leading "."/"-" (dotfile / shell-flag hazards) and cap
    /// the length so the rename can never exceed the filename limit.
    public static func sanitize(_ raw: String) -> String {
        var s = String(String.UnicodeScalarView(
            raw.unicodeScalars.filter { !CharacterSet.controlCharacters.contains($0) }
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
