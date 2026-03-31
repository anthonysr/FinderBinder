import SwiftUI

@main
struct FinderBinderApp: App {
    @State private var settings = AppSettings()
    @State private var monitor: FinderMonitor?

    var body: some Scene {
        MenuBarExtra {
            SettingsView(settings: settings)
                .onAppear {
                    if monitor == nil {
                        let m = FinderMonitor(settings: settings)
                        m.start()
                        monitor = m
                    }
                }
        } label: {
            Image(systemName: "link")
        }
        .menuBarExtraStyle(.window)
    }
}
