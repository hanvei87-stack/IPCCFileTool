import SwiftUI

@main
struct IPCCFileToolApp: App {
    @StateObject private var accessSession = FileAccessSession(
        fileClient: LocalFileClient()
    )

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(accessSession)
        }
    }
}
