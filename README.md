<div align="center">

# 📸 mugshot

**You take a screenshot. mugshot asks why. The file gets renamed to your answer.**

No more `Screenshot 2026-07-02 at 14.32.07.png` sitting anonymously in a folder
for six months, guilty of a crime nobody remembers.

[![Release](https://img.shields.io/github/v/release/hellodditto/mugshot?color=blue)](https://github.com/hellodditto/mugshot/releases)
[![CI](https://github.com/hellodditto/mugshot/actions/workflows/ci.yml/badge.svg)](https://github.com/hellodditto/mugshot/actions/workflows/ci.yml)
![Platform](https://img.shields.io/badge/macOS-13%2B-black?logo=apple)
[![License](https://img.shields.io/badge/license-Apache--2.0-green)](LICENSE)

```bash
brew install --cask hellodditto/tap/mugshot
```

> _Demo GIF coming soon._

</div>

---

## How the booking goes

1. **Capture** — `⌘⇧4`, `⌘⇧3`, or a `⌘⇧5` screen recording. Anything macOS drops
   in your screenshot folder.
2. **Interrogate** — a small floating panel slides into the corner:
   *"State the identity of this capture."* It never steals focus from what
   you're doing.
3. **Book it 💾** — type a reason, hit <kbd>Enter</kbd>. A green checkmark, and
   the file becomes `<your reason> <original date & time>.png` — it still sorts
   chronologically next to its untouched siblings. The renamed file is already
   on your clipboard: **`⌘V` pastes it anywhere.**
4. **Or let it walk** — <kbd>Esc</kbd> (or ignoring the panel for 2 minutes)
   keeps the original name, untouched, and it's never asked about again.

Took five shots in a row? The panel works through them one by one and shows
`(+N)` for the suspects still waiting.

## What makes it pleasant

| | |
|---|---|
| 🫥 **Invisible by default** | No Dock icon. Just a small 📷 menu bar icon for pause / settings / quit — and you can turn even that off. |
| ⚡ **No polling, no daemon churn** | An `FSEvents` subscription sleeps until the screenshot folder actually changes. |
| 🎬 **Recordings too** | `⌘⇧5` screen recordings (`.mov`) get the same booking treatment, thumbnail included. |
| 📋 **Paste-ready** | After a rename the file sits on your clipboard, Finder-style. (Toggleable — it does replace whatever was there.) |
| 🌍 **16 languages** | The panel speaks your system language: `en` `ko` `es` `fr` `de` `pt` `it` `ru` `ja` `zh` `ar` `hi` `tr` `nl` `pl` `vi`. |
| 🔒 **Nothing leaves your Mac** | No network calls, no logs, no analytics. The only trace is the renamed file itself. |

## Install

**Homebrew** (recommended — signed & notarized, no Gatekeeper hoops):

```bash
brew install --cask hellodditto/tap/mugshot
```

Or grab `Mugshot-<version>.zip` from [Releases](https://github.com/hellodditto/mugshot/releases).

Launch it once and answer the three onboarding questions:

- Switch your screenshot location to a dedicated `~/Screenshots` folder?
  (keeps your desktop clean; the original location is remembered)
- Turn off the macOS floating screenshot thumbnail? (recommended — see
  [the gotcha](#the-floating-thumbnail-gotcha) below)
- Launch mugshot at login?

## Settings

Open Settings from the 📷 menu bar icon — or, if you've hidden the icon,
just launch Mugshot.app again while it's running.

| Setting | What it does |
|---|---|
| Watched folder | Where mugshot looks — changing it also moves the macOS screenshot location |
| Floating thumbnail | Toggle the system thumbnail (off = snappier panel) |
| Clipboard copy | Put the renamed file on the clipboard after each save |
| Menu bar icon | Show/hide the 📷 icon |
| Launch at login | Self-explanatory |
| **Revert everything & quit** | Restores the original screenshot location and thumbnail setting, removes the login item, forgets all settings, optionally strips mugshot's seen-tags. Files you renamed are never touched. |

## The floating thumbnail gotcha

macOS's screenshot thumbnail (the little preview in the corner) delays
*actually writing the file to disk* until it dismisses. mugshot only reacts
once the file exists, so the panel appears late while the thumbnail is on.
Onboarding offers to turn it off (reverting restores it). By hand:
**⌘⇧5 → Options → uncheck "Show Floating Thumbnail"**.

## How it works

- An `FSEvents` stream watches your screenshot folder; there is no polling.
- A new `*.png` counts as a screenshot if macOS tagged it
  (`kMDItemIsScreenCapture`) or it's named like one; a new `*.mov` counts as a
  screen recording if it carries the system's date-and-time stamp. Either way
  it must be under a minute old and not previously seen (tracked with a
  `com.hellodditto.mugshot.seen` xattr on the file).
- Skip/timeout leaves the file exactly as macOS named it.
- No log files. The only trace is the renamed file itself.

## Building from source

```bash
git clone https://github.com/hellodditto/mugshot && cd mugshot
make run      # build + open (first run shows onboarding)
make app      # just assemble build/Mugshot.app
swift test    # core-logic unit tests
make clean
```

- Requires macOS 13+. Building needs only the Xcode Command Line Tools;
  `swift test` needs a full Xcode install (XCTest isn't in the CLT — set
  `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` if your
  `xcode-select` points at the CLT).
- Core logic lives in `Sources/MugshotCore` (pure, tested); the app shell
  (watcher, panel, settings) in `Sources/Mugshot`.
- A local `make app` build is ad-hoc signed — fine on your own machine, but
  don't distribute it. Homebrew/Release builds are Developer ID-signed and
  notarized by CI.
- Localization PRs are very welcome — the strings are machine translations of
  a playful "booking" theme; fix yours in
  `Resources/<code>.lproj/Localizable.strings`.

## Security and trust

- **No network calls.** mugshot never talks to the internet.
- **No secrets.** Nothing to configure involves credentials or tokens.
- **System changes require your consent.** The only macOS settings mugshot
  touches are the screenshot save location and the floating-thumbnail toggle,
  only after you say yes — and both are restored by "Revert everything".

## License

[Apache-2.0](LICENSE)
