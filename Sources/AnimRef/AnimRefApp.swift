import SwiftUI

@main
struct AnimRefApp: App {
    @AppStorage("appLang") var appLang = "ko"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.appLang, appLang)
                .preferredColorScheme(.light)
        }
        .defaultSize(width: 1120, height: 740)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) {}

            CommandMenu(appLang == "en" ? "Language" : "언어") {
                Button("한국어") {
                    appLang = "ko"
                }
                .keyboardShortcut("k", modifiers: [.command, .shift])

                Button("English") {
                    appLang = "en"
                }
                .keyboardShortcut("e", modifiers: [.command, .shift])
            }
        }
    }
}
