import SwiftUI
import QueueSyncCore

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct QueueSyncApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var queueManager = QueueManager()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(queueManager)
                .frame(minWidth: 800, minHeight: 500)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
