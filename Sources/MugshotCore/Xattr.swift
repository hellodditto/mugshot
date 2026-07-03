import Foundation

public enum Xattr {
    public static func has(_ name: String, at path: String) -> Bool {
        getxattr(path, name, nil, 0, 0, 0) >= 0
    }

    public static func set(_ name: String, value: String = "1", at path: String) {
        _ = value.withCString { setxattr(path, name, $0, strlen($0), 0, 0) }
    }

    public static func remove(_ name: String, at path: String) {
        removexattr(path, name, 0)
    }
}
