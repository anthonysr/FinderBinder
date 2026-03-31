import AppKit

final class FinderMonitor {
    private let settings: AppSettings
    private var observation: NSObjectProtocol?

    private static let finderBundleID = "com.apple.finder"

    init(settings: AppSettings) {
        self.settings = settings
    }

    deinit {
        stop()
    }

    func start() {
        stop()
        observation = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleActivation(notification)
        }
    }

    func stop() {
        if let observation {
            NSWorkspace.shared.notificationCenter.removeObserver(observation)
        }
        observation = nil
    }

    private func handleActivation(_ notification: Notification) {
        guard settings.isEnabled,
              settings.hasReplacement,
              let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              app.bundleIdentifier == Self.finderBundleID
        else { return }

        // Option-key bypass: let Finder through when Option is held
        if NSEvent.modifierFlags.contains(.option) {
            return
        }

        // Only redirect clicks from the Dock area, not desktop clicks.
        // visibleFrame excludes the Dock and menu bar — if the mouse is
        // outside visibleFrame, the click originated from the Dock region.
        let mouse = NSEvent.mouseLocation
        let inDockArea = NSScreen.screens.contains { screen in
            NSMouseInRect(mouse, screen.frame, false)
                && !NSMouseInRect(mouse, screen.visibleFrame, false)
        }
        if !inDockArea {
            return
        }

        // Launch or activate the replacement app
        guard let replacementURL = settings.replacementAppURL else {
            settings.errorMessage = "Replacement app not found. It may have been uninstalled."
            settings.isEnabled = false
            return
        }

        // Hide Finder after a brief delay so macOS finishes its unhide/activate
        // cycle from the dock click — hiding during that cycle is ignored.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            app.hide()
        }

        // Directly activate the running replacement app (handles already-running case)
        if let running = NSWorkspace.shared.runningApplications.first(where: {
            $0.bundleIdentifier == self.settings.replacementAppBundleID
        }) {
            running.unhide()
            running.activate()
        }

        // Also call openApplication to handle the not-yet-running case
        let config = NSWorkspace.OpenConfiguration()
        config.activates = true
        NSWorkspace.shared.openApplication(at: replacementURL, configuration: config) { [weak self] _, error in
            if let error {
                DispatchQueue.main.async {
                    self?.settings.errorMessage = "Failed to launch app: \(error.localizedDescription)"
                }
            }
        }
    }
}
