import AppKit
import UniformTypeIdentifiers

struct AppPicker {
    /// Shows an NSOpenPanel to select an application from /Applications.
    /// Returns (bundleID, appName) on success, nil on cancel.
    static func chooseApp() -> (bundleID: String, name: String)? {
        let panel = NSOpenPanel()
        panel.title = "Choose Replacement App"
        panel.message = "Select the application to launch instead of Finder"
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.application]

        guard panel.runModal() == .OK, let url = panel.url else {
            return nil
        }

        guard let bundle = Bundle(url: url),
              let bundleID = bundle.bundleIdentifier,
              bundleID != "com.apple.finder",
              bundleID != Bundle.main.bundleIdentifier else {
            return nil
        }

        let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? url.deletingPathExtension().lastPathComponent

        return (bundleID, name)
    }
}
