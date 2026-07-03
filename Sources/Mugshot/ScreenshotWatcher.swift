import Foundation
import CoreServices

/// FSEvents subscription on the watched folder — the native replacement for
/// the launchd WatchPaths trigger. Callbacks are delivered on the main queue.
final class ScreenshotWatcher {
    private var stream: FSEventStreamRef?
    private let onChange: () -> Void

    init(path: String, onChange: @escaping () -> Void) {
        self.onChange = onChange

        var context = FSEventStreamContext()
        context.info = Unmanaged.passUnretained(self).toOpaque()

        let callback: FSEventStreamCallback = { _, info, _, _, _, _ in
            guard let info else { return }
            Unmanaged<ScreenshotWatcher>.fromOpaque(info)
                .takeUnretainedValue().onChange()
        }

        stream = FSEventStreamCreate(
            nil, callback, &context,
            [path] as CFArray,
            FSEventStreamEventId(kFSEventStreamEventIdSinceNow),
            0.3,
            FSEventStreamCreateFlags(kFSEventStreamCreateFlagNone))

        guard let stream else {
            NSLog("Mugshot: FSEventStreamCreate failed for \(path)")
            return
        }
        FSEventStreamSetDispatchQueue(stream, .main)
        if !FSEventStreamStart(stream) {
            NSLog("Mugshot: FSEventStreamStart failed for \(path)")
        }
    }

    func stop() {
        guard let stream else { return }
        FSEventStreamStop(stream)
        FSEventStreamInvalidate(stream)
        FSEventStreamRelease(stream)
        self.stream = nil
    }

    deinit { stop() }
}
