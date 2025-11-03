import simd
import RealityKit
import ARKit.hand_skeleton

// Simple model types used across the app
struct HandJoint: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var position: SIMD3<Float>
}

struct HandData: Hashable {
    var isTracked: Bool
    var joints: [HandJoint]
}

// The hand skeleton mapping used by the RealityKit hand spheres system
struct Hand {
    static let joints: [(HandSkeleton.JointName, Finger, Bone)] = [
        (.thumbKnuckle, .thumb, .knuckle),
        (.thumbIntermediateBase, .thumb, .intermediateBase),
        (.thumbIntermediateTip, .thumb, .intermediateTip),
        (.thumbTip, .thumb, .tip),

        (.indexFingerMetacarpal, .index, .metacarpal),
        (.indexFingerKnuckle, .index, .knuckle),
        (.indexFingerIntermediateBase, .index, .intermediateBase),
        (.indexFingerIntermediateTip, .index, .intermediateTip),
        (.indexFingerTip, .index, .tip),

        (.middleFingerMetacarpal, .middle, .metacarpal),
        (.middleFingerKnuckle, .middle, .knuckle),
        (.middleFingerIntermediateBase, .middle, .intermediateBase),
        (.middleFingerIntermediateTip, .middle, .intermediateTip),
        (.middleFingerTip, .middle, .tip),

        (.ringFingerMetacarpal, .ring, .metacarpal),
        (.ringFingerKnuckle, .ring, .knuckle),
        (.ringFingerIntermediateBase, .ring, .intermediateBase),
        (.ringFingerIntermediateTip, .ring, .intermediateTip),
        (.ringFingerTip, .ring, .tip),

        (.littleFingerMetacarpal, .little, .metacarpal),
        (.littleFingerKnuckle, .little, .knuckle),
        (.littleFingerIntermediateBase, .little, .intermediateBase),
        (.littleFingerIntermediateTip, .little, .intermediateTip),
        (.littleFingerTip, .little, .tip),

        (.forearmWrist, .forearm, .wrist),
        (.forearmArm, .forearm, .arm)
    ]
}

enum Finger: Int, CaseIterable { case forearm, thumb, index, middle, ring, little }
enum Bone: Int, CaseIterable { case arm, wrist, metacarpal, knuckle, intermediateBase, intermediateTip, tip }
