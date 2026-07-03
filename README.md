# mugshot

You take a screenshot. mugshot asks why. The file gets renamed to your answer.

That's it. No more `Screenshot 2026-07-02 at 14.32.07.png` sitting anonymously in a
folder for six months, guilty of a crime nobody remembers.

> _Demo GIF coming soon._

## What it does

1. You press `⌘⇧4` (or `⌘⇧3`, or whatever) and take a screenshot.
2. A small floating panel appears in the corner: *"State the identity of this capture."*
3. You type a reason and hit **Book it 💾** (or just press Enter) — the screenshot is
   renamed to `<your reason> <original date & time>.png` (e.g.
   `q3 roadmap 2026-07-02 at 14.32.07.png`), so it still sorts chronologically
   next to its untouched siblings. If the original name has no date, it's just
   `<your reason>.png`.
4. Or you hit **Nah, skip** (or Esc) — the file keeps its original name, untouched.
   Ignore the panel and it gives up after 2 minutes, same thing.

mugshot is a tiny native macOS app. By default it's completely invisible — no Dock
icon, no menu bar icon (you can turn one on in Settings). It sits idle on an
FSEvents subscription and only wakes when the screenshot folder actually changes.

## Requirements

- macOS 13 (Ventura) or later
- Xcode command line tools (to build; no Xcode project needed). `swift test`
  needs a full Xcode install, though — `XCTest` isn't shipped with the
  Command Line Tools. Building/running the app (`make app` / `make run`)
  works fine with just the CLT, as long as `DEVELOPER_DIR` points at an
  installed Xcode if you have one (e.g. `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`).

## Build & run

```bash
git clone https://github.com/hellodditto/mugshot && cd mugshot
make run
```

`make app` assembles `build/Mugshot.app` (SwiftPM build + bundle script, ad-hoc
signed). `make run` opens it. On first launch mugshot asks three things:

- switch your screenshot location to a dedicated `~/Screenshots` folder?
  (keeps your desktop clean; the original location is remembered)
- turn off the macOS floating screenshot thumbnail? (see below — recommended)
- launch mugshot at login?

Move `build/Mugshot.app` to `/Applications` if you want it to stick around.
If you already enabled launch-at-login before moving it, re-toggle that
setting afterward — the login item was registered against the old path.

## The floating thumbnail gotcha

macOS's screenshot thumbnail (the little preview that pops up in the corner)
delays *actually writing the file to disk* until it dismisses. Since mugshot
only reacts once the file exists, the naming panel appears noticeably late if
the thumbnail is on. Onboarding offers to turn it off (and reverting mugshot
restores it). By hand: **Cmd-Shift-5 → Options → uncheck "Show Floating Thumbnail"**.

## Settings

Open Settings by launching Mugshot.app again while it's running (the app has no
Dock icon or menu bar item by default, so re-launching it is what brings
Settings to the front), or press `⌘,` while the onboarding window is
frontmost. Once you're in Settings you can enable the menu bar icon for
quicker access next time. You can:

- change the watched folder (also moves the macOS screenshot location)
- toggle the floating thumbnail, menu bar icon, and launch-at-login
- pause/resume watching from the menu bar icon
- **Revert everything & quit** — restores the original screenshot location and
  thumbnail setting, removes the login item, forgets all settings, and
  optionally strips mugshot's seen-tags from skipped files. Screenshots you
  already renamed are never touched.

## Localization

The rename panel ships in 16 languages, picked automatically from your system
language: `en` `ko` `es` `fr` `de` `pt` `it` `ru` `ja` `zh` `ar` `hi` `tr` `nl`
`pl` `vi`. These are machine translations of a playful "booking"/mugshot theme —
if something reads wrong in your language, a PR improving
`Resources/<code>.lproj/Localizable.strings` is very welcome.

## How it works

- An `FSEvents` stream watches your screenshot folder; there is no polling.
- A new `*.png` counts as a screenshot if macOS tagged it
  (`kMDItemIsScreenCapture`) or it's named like one (`Screenshot …` /
  `…YYYY-MM-DD at …`), it's under a minute old, and mugshot hasn't asked about
  it before (tracked with a `com.hellodditto.mugshot.seen` xattr on the file).
- Skip/timeout leaves the file exactly as macOS named it.
- No log files. The only trace is the renamed file itself.

## Development

```bash
swift test    # unit tests for the core logic (rename, detect, scan, locales)
make app      # assemble build/Mugshot.app
make clean
```

Core logic lives in `Sources/MugshotCore` (pure, tested); the app shell
(FSEvents watcher, floating panel, settings) in `Sources/Mugshot`.

## Security and trust

- **No network calls.** mugshot never talks to the internet.
- **No secrets.** Nothing to configure involves credentials or tokens.
- **System changes require your consent.** The only macOS settings mugshot
  touches are the screenshot save location and the floating-thumbnail toggle
  (both via `defaults write`), only after you say yes — and both are restored
  by "Revert everything".

## Caveats

- macOS only, 13+.
- The build is ad-hoc signed; distribution signing/notarization is not set up yet.

## License

[Apache-2.0](LICENSE)
