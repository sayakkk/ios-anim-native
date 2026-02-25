import SwiftUI

@main
struct AnimRefApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        .defaultSize(width: 1120, height: 740)
        .windowResizability(.contentMinSize)
        .commands {
            // Disable "New Window" shortcut (Cmd+N)
            CommandGroup(replacing: .newItem) {}
        }
    }
}
