import Foundation

/// Marks screenshots Mugshot has already prompted for, so a skipped file is
/// never asked about twice. The key is static (no username embedded — xattrs
/// travel with shared files via AirDrop/zip/external drives, and the old
/// per-user key leaked the macOS short username). Files marked by older
/// versions (`com.<user>.mugshot.seen`) are still recognized and purgeable.
public struct SeenMarker {
    public let attrName = "com.hellodditto.mugshot.seen"
    public let legacyAttrName: String

    public init(user: String = NSUserName()) {
        legacyAttrName = "com.\(user).mugshot.seen"
    }

    public func isSeen(_ url: URL) -> Bool {
        Xattr.has(attrName, at: url.path) || Xattr.has(legacyAttrName, at: url.path)
    }

    public func markSeen(_ url: URL) { Xattr.set(attrName, at: url.path) }

    public func unmark(_ url: URL) {
        Xattr.remove(attrName, at: url.path)
        Xattr.remove(legacyAttrName, at: url.path)
    }
}
