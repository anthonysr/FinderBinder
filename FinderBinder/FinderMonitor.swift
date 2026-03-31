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

        // Hide Finder
        app.hide()

        // Launch or activate the replacement app
        guard let replacementURL = settings.replacementAppURL else {
            settings.errorMessage = "Replacement app not found. It may have been uninstalled."
            settings.isEnabled = false
            return
        }

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
