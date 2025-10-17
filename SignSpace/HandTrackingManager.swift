import Foundation
import RealityKit
import ARKit
import Observation

@MainActor
@Observable
final class HandTrackingManager {
    var leftHand: HandData?
    var rightHand: HandData?
    var useMockData = false
    
    private var arkitSession: ARKitSession?
    private var handTrackingProvider: HandTrackingProvider?
    private var handTrackingTask: Task<Void, Never>?
    
    func start() {
        guard handTrackingTask == nil else {
            print("⚠️ Hand tracking already started")
            return
        }
        print("🚀 Starting hand tracking...")
        handTrackingTask = Task { await startHandTracking() }
    }
    
    func stop() {
        print("🛑 Stopping hand tracking...")
        handTrackingTask?.cancel()
        handTrackingTask = nil
        arkitSession = nil
        handTrackingProvider = nil
        leftHand = nil
        rightHand = nil
    }
    
    private func startHandTracking() async {
        do {
            let session = ARKitSession()
            let provider = HandTrackingProvider()
            
            self.arkitSession = session
            self.handTrackingProvider = provider
            
            // Request authorization
            print("🔐 Requesting hand tracking authorization...")
            let auth = await session.requestAuthorization(for: [.handTracking])
            
            guard auth[.handTracking] == .allowed else {
                print("❌ Hand tracking authorization DENIED")
                return
            }
            print("✅ Hand tracking authorized!")
            
            // Run the session
            print("▶️ Running ARKit session...")
            try await session.run([provider])
            print("✅ ARKit session running!")
            
            // Monitor hand updates
            print("👀 Monitoring hand updates...")
            for await update in provider.anchorUpdates {
                let anchor = update.anchor
                let handData = extractHandData(from: anchor)
                
                if anchor.chirality == .left {
                    leftHand = handData
                    if handData.isTracked {
                        print("👈 Left hand tracked: \(handData.joints.count) joints")
                    }
                } else {
                    rightHand = handData
                    if handData.isTracked {
                        print("👉 Right hand tracked: \(handData.joints.count) joints")
                    }
                }
            }
        } catch {
            print("❌ Failed to start hand tracking: \(error.localizedDescription)")
        }
    }
    
    private func extractHandData(from anchor: HandAnchor) -> HandData {
        guard anchor.isTracked, let skeleton = anchor.handSkeleton else {
            return HandData(isTracked: false, joints: [])
        }
        
        // Key joints we need for gesture recognition
        let jointNames: [HandSkeleton.JointName] = [
            .wrist,
            .thumbTip, .thumbIntermediateTip, .thumbIntermediateBase, .thumbKnuckle,
            .indexFingerTip, .indexFingerIntermediateTip, .indexFingerIntermediateBase, .indexFingerKnuckle,
            .middleFingerTip, .middleFingerIntermediateTip, .middleFingerIntermediateBase, .middleFingerKnuckle,
            .ringFingerTip, .ringFingerIntermediateTip, .ringFingerIntermediateBase, .ringFingerKnuckle,
            .littleFingerTip, .littleFingerIntermediateTip, .littleFingerIntermediateBase, .littleFingerKnuckle
        ]
        
        var joints: [HandJoint] = []
        
        for jointName in jointNames {
            let joint = skeleton.joint(jointName)
            let worldTransform = anchor.originFromAnchorTransform * joint.anchorFromJointTransform
            let position = SIMD3<Float>(
                worldTransform.columns.3.x,
                worldTransform.columns.3.y,
                worldTransform.columns.3.z
            )
            joints.append(HandJoint(name: String(describing: jointName), position: position))
        }
        
        return HandData(isTracked: true, joints: joints)
    }
}
