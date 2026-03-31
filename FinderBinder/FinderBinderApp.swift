import SwiftUI

@main
struct FinderBinderApp: App {
    @State private var settings: AppSettings
    @State private var monitor: FinderMonitor

    init() {
        let s = AppSettings()
        let m = FinderMonitor(settings: s)
        m.start()
        _settings = State(initialValue: s)
        _monitor = State(initialValue: m)
    }

    var body: some Scene {
        MenuBarExtra {
            SettingsView(settings: settings)
        } label: {
            Image(systemName: "link")
        }
        .menuBarExtraStyle(.window)
    }
}
