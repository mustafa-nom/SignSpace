import SwiftUI

@main
struct SignSpaceApp: App {
    @State private var appModel = AppModel()
    @State private var handTracker = HandTrackingManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
                .environment(\.handTrackingManager, handTracker)  // <-- now ok
        }

        ImmersiveSpace(id: "HandTrackingScene") {
            HandTrackingView()
                .environment(\.handTrackingManager, handTracker)
        }
    }
}
