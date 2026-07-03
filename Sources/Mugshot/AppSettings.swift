import Foundation

final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private let d: UserDefaults

    @Published var watchedFolder: String {
        didSet { d.set(watchedFolder, forKey: "watchedFolder") }
    }

    /// Menu-bar pause; intentionally not persisted across launches.
    @Published var paused = false

    /// Put the renamed file on the clipboard so it can be pasted right away.
    @Published var copyAfterRename: Bool {
        didSet { d.set(copyAfterRename, forKey: "copyAfterRename") }
    }

    var onboardingDone: Bool {
        get { d.bool(forKey: "onboardingDone") }
        set { d.set(newValue, forKey: "onboardingDone") }
    }

    /// Original com.apple.screencapture location, saved before we changed it.
    var previousLocation: String? {
        get { d.string(forKey: "previousLocation") }
        set { d.set(newValue, forKey: "previousLocation") }
    }

    /// Non-nil means Mugshot turned the floating thumbnail off.
    var previousThumbnail: String? {
        get { d.string(forKey: "previousThumbnail") }
        set { d.set(newValue, forKey: "previousThumbnail") }
    }

    init(defaults: UserDefaults = .standard) {
        d = defaults
        watchedFolder = defaults.string(forKey: "watchedFolder")
            ?? SystemSettings.screenshotLocation()
        copyAfterRename = defaults.object(forKey: "copyAfterRename") as? Bool ?? true
    }
}
