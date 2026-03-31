import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings
    @State private var launchAtLogin = LoginItemManager.isEnabled

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Text("FinderBinder")
                .font(.headline)

            Divider()

            // Replacement app selection
            HStack {
                if let icon = settings.replacementAppIcon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 32, height: 32)
                }

                VStack(alignment: .leading) {
                    Text(settings.replacementAppName ?? "No app selected")
                        .font(.body)
                    if let bundleID = settings.replacementAppBundleID {
                        Text(bundleID)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Button("Browse…") {
                    if let result = AppPicker.chooseApp() {
                        settings.replacementAppBundleID = result.bundleID
                        settings.replacementAppName = result.name
                        settings.errorMessage = nil
                    }
                }
            }

            // Error message
            if let error = settings.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Divider()

            // Toggles
            Toggle("Enable Finder redirect", isOn: $settings.isEnabled)
                .disabled(!settings.hasReplacement)

            Toggle("Launch at login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { _, newValue in
                    do {
                        try LoginItemManager.setEnabled(newValue)
                    } catch {
                        launchAtLogin = !newValue // revert
                    }
                }

            Divider()

            // Hint
            Text("Hold ⌥ Option to bypass and open Finder normally")
                .font(.caption)
                .foregroundStyle(.secondary)

            // Quit
            HStack {
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .padding()
        .frame(width: 300)
    }
}
