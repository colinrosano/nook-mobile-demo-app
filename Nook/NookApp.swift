import SwiftUI

@main
struct NookApp: App {
    @State private var store = ShopStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .tint(Theme.forest)
        }
        // Start the consent flow once the scene is active: the ATT prompt is
        // only shown for an active app. start() is idempotent.
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .active { OsanoService.shared.start() }
        }
    }
}
