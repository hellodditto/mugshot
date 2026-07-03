import Foundation

final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private let d: UserDefaults

    @Published var watchedFolder: String {
        didSet { d.set(watchedFolder, forKey: "watchedFolder") }
    }

    /// Menu-bar pause; intentionally not persisted across launches.
    @Published var paused = false

    var onboardingDone: Bool {
        get { d.bool(forKey: "onboardingDone") }
        set { d.set(newValue, forKey: "onboardingDone") }
    }

    /// Original com.apple.screencapture location, saved before we changed it.
    var previousLocation: String? {
        get { d.string(forKey: "previousLocation") }
        set { d.set(newValue, forKey: "previousLocation") }
    }

    /// Non-nil means mugshot turned the floating thumbnail off.
    var previousThumbnail: String? {
        get { d.string(forKey: "previousThumbnail") }
        set { d.set(newValue, forKey: "previousThumbnail") }
    }

    init(defaults: UserDefaults = .standard) {
        d = defaults
        watchedFolder = defaults.string(forKey: "watchedFolder")
            ?? SystemSettings.screenshotLocation()
    }
}
