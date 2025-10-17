import SwiftUI

@main
struct SignSpaceApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }

        ImmersiveSpace(id: "HandTrackingScene") {
            HandTrackingView()
        }
    }
}
