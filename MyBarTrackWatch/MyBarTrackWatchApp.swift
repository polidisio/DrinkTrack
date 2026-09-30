import SwiftUI

@main
struct MyBarTrackWatchApp: App {
    @StateObject private var sync = WatchSyncService.shared

    init() {
        WatchSyncService.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(sync)
        }
    }
}
