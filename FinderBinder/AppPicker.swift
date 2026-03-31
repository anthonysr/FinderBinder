import AppKit
import UniformTypeIdentifiers

struct AppPicker {
    /// Shows an NSOpenPanel to select an application from /Applications.
    /// Temporarily switches to .regular activation policy so the panel
    /// receives proper click/focus handling (LSUIElement apps don't by default).
    static func chooseApp(completion: @escaping ((bundleID: String, name: String)?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NSApp.setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)

            let panel = NSOpenPanel()
            panel.title = "Choose Replacement App"
            panel.message = "Select the application to launch instead of Finder"
            panel.directoryURL = URL(fileURLWithPath: "/Applications")
            panel.allowsMultipleSelection = false
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.allowedContentTypes = [.application]

            let response = panel.runModal()

            NSApp.setActivationPolicy(.accessory)

            guard response == .OK, let url = panel.url else {
                completion(nil)
                return
            }

            guard let bundle = Bundle(url: url),
                  let bundleID = bundle.bundleIdentifier,
                  bundleID != "com.apple.finder",
                  bundleID != Bundle.main.bundleIdentifier else {
                completion(nil)
                return
            }

            let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
                ?? bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
                ?? url.deletingPathExtension().lastPathComponent

            completion((bundleID, name))
        }
    }
}
