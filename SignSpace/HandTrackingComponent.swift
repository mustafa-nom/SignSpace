import RealityKit
import ARKit

struct HandTrackingComponent: Component {
    let chirality: AnchoringComponent.Target.Chirality
    var fingers: [HandSkeleton.JointName: Entity] = [:]
    
    init(chirality: AnchoringComponent.Target.Chirality) {
        self.chirality = chirality
        HandTrackingSystem.registerSystem()
    }
}
