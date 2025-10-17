import Observation

@Observable
final class AppModel {
    enum ImmersiveSpaceState { case open, closed, inTransition }
    var immersiveSpaceID: String = "HandTrackingScene"
    var immersiveSpaceState: ImmersiveSpaceState = .closed
}
