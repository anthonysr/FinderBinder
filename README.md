# FinderBinder

A minimal macOS menu bar app that redirects Finder to your preferred file manager.

Click the Finder icon in your Dock and your chosen app opens instead — [Bloom](https://bloomapp.club/), [QSpace](https://qspace.awehunt.com/en-us/index.html), or any other file manager.

## How It Works

FinderBinder runs as a lightweight background agent (no Dock icon) and monitors for Finder activation. When Finder activates, FinderBinder hides it and opens your replacement app. That's it.

- **Zero permissions required** — no Accessibility, Input Monitoring, or Full Disk Access
- **~300 lines of Swift** — no dependencies, no frameworks, no bloat
- **Hold Option** to bypass the redirect and open Finder normally

## Install

### Build from source

Requires Xcode 15+ (macOS 14 Sonoma or later).

```bash
git clone https://github.com/anthonysr/FinderBinder.git
cd FinderBinder
swift build --disable-sandbox -c release

# Create .app bundle
mkdir -p .build/release/FinderBinder.app/Contents/MacOS
cp .build/release/FinderBinder .build/release/FinderBinder.app/Contents/MacOS/
cp FinderBinder/Info.plist .build/release/FinderBinder.app/Contents/

# Install
cp -r .build/release/FinderBinder.app /Applications/
```

### First run

1. Launch FinderBinder — a chain-link icon appears in your menu bar
2. Click the icon, then **Browse** to select your replacement app
3. The redirect enables automatically
4. Click the Finder icon in your Dock — your chosen app opens instead

## Usage

| Action | Result |
|--------|--------|
| Click Finder in Dock | Opens your replacement app |
| Hold **Option** + click Finder | Opens Finder normally (bypass) |
| Toggle "Enable Finder redirect" | Pause/resume redirection |
| Toggle "Launch at login" | Start FinderBinder on boot |

## How It Works (Technical)

FinderBinder subscribes to `NSWorkspace.didActivateApplicationNotification`. When Finder (`com.apple.finder`) activates:

1. Hides Finder via `NSRunningApplication.hide()`
2. Launches or activates the replacement app via `NSWorkspace.openApplication`

The replacement app is stored by **bundle identifier**, so it survives app updates and directory moves.

### Known Limitations

- **Brief Finder flash (~50ms)** — the notification fires after Finder activates, so there's a momentary flash before it's hidden. This is inherent to the notification-based approach.
- **Replacement app keeps its own Dock icon** — FinderBinder launches your chosen app as a normal process. macOS requires running apps to have their own Dock icon for window management, Cmd+Tab switching, and menu bar access. This can't be changed without modifying the replacement app itself.
- **Not on the App Store** — sandboxing blocks the APIs needed (`NSRunningApplication.hide()`, `NSWorkspace.openApplication`). Distribute directly or via Homebrew.

## Requirements

- macOS 14.0 (Sonoma) or later
- Any file manager app as a replacement (Bloom, QSpace, Path Finder, Marta, etc.)

## License

MIT
