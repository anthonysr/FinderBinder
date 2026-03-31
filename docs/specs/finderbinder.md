# FinderBinder — Requirements Specification

## Overview

FinderBinder is a minimal macOS menu bar app that intercepts Finder activation and redirects it to a user-chosen file manager application (e.g., [Bloom](https://bloomapp.club/), [QSpace](https://qspace.awehunt.com/en-us/index.html)).

### Problem

Clicking the Finder icon in the macOS Dock opens Finder. Users who prefer alternative file managers want that click to open their chosen app instead. Existing solutions ([click2minimize](https://click2minimize.com/), [Supercharge](https://sindresorhus.com/supercharge)) are feature-bloated for this single use case.

### Solution

A zero-permission background agent that monitors Finder activations via `NSWorkspace`, hides Finder, and launches the replacement app.

## Technical Approach

**Mechanism:** Subscribe to `NSWorkspace.didActivateApplicationNotification`. When the activated app is `com.apple.finder`, call `NSRunningApplication.hide()` on Finder and launch/activate the replacement app via `NSWorkspace.shared.openApplication(at:configuration:)`.

**Permissions:** None. No Accessibility, Input Monitoring, or Full Disk Access required.

**Trade-off:** The notification fires ~50-100ms after Finder activates, causing a brief flash before hide takes effect. Acceptable for v1.

## Functional Requirements

### FR-1: Finder Redirect
- Monitor `NSWorkspace.didActivateApplicationNotification` for Finder (`com.apple.finder`)
- When triggered and redirection is enabled, hide Finder and launch/activate replacement app
- If replacement app is already running, bring it to front instead of relaunching

### FR-2: App Selection
- Provide `NSOpenPanel` defaulting to `/Applications`, filtered to `.app` bundles
- Store replacement app by **bundle identifier** (survives updates and directory moves)
- Display selected app name and icon in the settings popover

### FR-3: Enable/Disable Toggle
- Toggle in menu bar popover to enable/disable redirection
- When disabled, Finder behaves normally

### FR-4: Option-Key Bypass
- Holding the Option key while Finder activates skips the redirect
- Allows access to Finder when genuinely needed

### FR-5: Launch at Login
- Toggle in popover to register/unregister via `SMAppService.mainApp`
- Query `SMAppService.mainApp.status` for current state (don't cache locally)

### FR-6: Menu Bar Presence
- SF Symbol icon: `link` (chain link = "binding")
- Popover style via `MenuBarExtra(.window)`
- Quit button in popover

## Non-Functional Requirements

| Requirement | Value |
|-------------|-------|
| Permissions | Zero (no entitlements beyond default) |
| Dock icon | None (`LSUIElement = true`) |
| Sandbox | Disabled (required for `hide()` and `openApplication`) |
| Deployment target | macOS 14.0 (Sonoma) |
| Dependencies | None (Apple frameworks only) |
| Distribution | Notarized, direct download |

## Architecture

```
FinderBinderApp (@main)
  └── MenuBarExtra (SF Symbol: "link")
        └── SettingsView (popover)
              ├── Selected app display + Browse button (AppPicker)
              ├── Enable/disable Toggle
              ├── Launch at login Toggle (LoginItemManager)
              └── Quit button

AppSettings (@Observable)
  ├── isEnabled: Bool (UserDefaults)
  ├── replacementAppBundleID: String? (UserDefaults)
  └── replacementAppName: String? (UserDefaults)

FinderMonitor
  ├── Subscribes to NSWorkspace.didActivateApplicationNotification
  ├── Guards: isEnabled, hasReplacement, app==Finder, !Option held
  ├── Hides Finder via NSRunningApplication.hide()
  └── Launches/activates replacement via NSWorkspace
```

### File Structure

```
FinderBinder/
├── FinderBinderApp.swift      # @main, MenuBarExtra scene
├── AppSettings.swift           # @Observable, UserDefaults persistence
├── FinderMonitor.swift         # NSWorkspace notification → hide → launch
├── SettingsView.swift          # Menu bar popover UI
├── AppPicker.swift             # NSOpenPanel wrapper for /Applications
├── LoginItemManager.swift      # SMAppService register/unregister
└── Info.plist                  # LSUIElement=true
```

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| Replacement app not installed | Disable monitoring, show error in popover |
| Replacement app already running | Activate (bring to front), don't relaunch |
| Desktop click activates Finder | Redirect fires (intentional; Option bypass available) |
| File open/save dialogs | In-process sheets, don't activate Finder — unaffected |
| System reboot | Launch at login re-enables monitoring automatically |
| Multiple monitors | No impact — notification is app-level, not display-level |

## Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| App identification | Bundle ID | Survives app updates and directory moves |
| Activation scope | All Finder activations | User wants full Finder replacement |
| Escape hatch | Option key | Simple, discoverable, no UI needed |
| State management | `@Observable` | Clean, modern, no Combine boilerplate |
| UI framework | SwiftUI `MenuBarExtra(.window)` | Native, minimal code |
| Login items | `SMAppService` | Modern API, macOS 13+ |
| Distribution | Notarized, non-sandboxed | Sandbox blocks core functionality |

## Known Limitations (v1)

1. **Finder flash (~50-100ms):** Notification fires after activation; brief visual flash before `hide()` takes effect
2. **Desktop clicks redirect:** Clicking the macOS desktop activates Finder, triggering the redirect. Use Option-key bypass when needed.
3. **No App Store distribution:** Sandbox is incompatible with core functionality (`NSRunningApplication.hide()`, unsandboxed `NSWorkspace.openApplication`)

## Acceptance Criteria

1. Clicking Finder Dock icon opens the selected replacement app instead of Finder
2. Finder is hidden within ~100ms of activation
3. Toggling "Enable" off restores normal Finder behavior immediately
4. Selecting a new replacement app via Browse updates the redirect target
5. Holding Option while clicking Finder Dock icon opens Finder normally
6. App runs with zero permission prompts on first launch
7. Launch at login toggle registers/unregisters correctly via System Settings
8. App has no Dock icon and only appears in the menu bar
