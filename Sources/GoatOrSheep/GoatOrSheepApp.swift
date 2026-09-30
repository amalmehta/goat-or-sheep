import SwiftUI
import GoatOrSheepKit

@main
struct GoatOrSheepApp: App {
    @NSApplicationDelegateAdaptor private var delegate: AppDelegate
    @StateObject private var state = QuizState()

    var body: some Scene {
        Window("Goat or Sheep", id: "main") {
            ContentView(state: state, feedbackRecipient: "amal.mehta@gmail.com")
        }
        .windowResizability(.contentSize)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Needed when launched via `swift run` rather than as a bundled .app.
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
}
