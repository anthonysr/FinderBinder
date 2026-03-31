import Foundation
import SwiftUI

@Observable
final class AppSettings {
    private static let enabledKey = "isEnabled"
    private static let bundleIDKey = "replacementAppBundleID"
    private static let appNameKey = "replacementAppName"

    var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: Self.enabledKey) }
    }

    var replacementAppBundleID: String? {
        didSet {
            UserDefaults.standard.set(replacementAppBundleID, forKey: Self.bundleIDKey)
            updateCachedAppInfo()
        }
    }

    var replacementAppName: String? {
        didSet { UserDefaults.standard.set(replacementAppName, forKey: Self.appNameKey) }
    }

    var hasReplacement: Bool {
        replacementAppBundleID != nil
    }

    private(set) var replacementAppURL: URL?
    private(set) var replacementAppIcon: NSImage?

    private func updateCachedAppInfo() {
        guard let bundleID = replacementAppBundleID else {
            replacementAppURL = nil
            replacementAppIcon = nil
            return
        }
        replacementAppURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID)
        if let url = replacementAppURL {
            replacementAppIcon = NSWorkspace.shared.icon(forFile: url.path)
        } else {
            replacementAppIcon = nil
        }
    }

    var errorMessage: String?

    init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: Self.enabledKey)
        self.replacementAppBundleID = UserDefaults.standard.string(forKey: Self.bundleIDKey)
        self.replacementAppName = UserDefaults.standard.string(forKey: Self.appNameKey)
        updateCachedAppInfo()
    }
}
