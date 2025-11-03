import RealityKit
import ARKit

struct HandTrackingSystem: System {
    // CRITICAL: These must be static so they persist across all entities
    static var arSession = ARKitSession()
    static let handTracking = HandTrackingProvider()
    
    // Public access to latest hands for other parts of app
    @MainActor
    static var latestLeftHand: HandAnchor?
    @MainActor
    static var latestRightHand: HandAnchor?
    
    static let query = EntityQuery(where: .has(HandTrackingComponent.self))
    
    init(scene: RealityKit.Scene) {
        // Start the session once when system initializes
        Task { await Self.runSession() }
    }
    
    @MainActor
    static func runSession() async {
        do {
            print("🚀 Starting ARKit hand tracking session...")
            try await arSession.run([handTracking])
            print("✅ ARKit session running!")
        } catch let error as ARKitSession.Error {
            print("❌ ARKit session error: \(error.localizedDescription)")
        } catch {
            print("❌ Unexpected error: \(error.localizedDescription)")
        }
        
        // Monitor hand updates continuously
        for await update in handTracking.anchorUpdates {
            switch update.anchor.chirality {
            case .left:
                Self.latestLeftHand = update.anchor
            case .right:
                Self.latestRightHand = update.anchor
            @unknown default:
                break
            }
        }
    }
    
    func update(context: SceneUpdateContext) {
        let handEntities = context.entities(matching: Self.query, updatingSystemWhen: .rendering)
        
        for entity in handEntities {
            guard var handComponent = entity.components[HandTrackingComponent.self] else { continue }
            
            // Setup joints if first time
            if handComponent.fingers.isEmpty {
                addJoints(to: entity, handComponent: &handComponent)
            }
            
            // Get the correct hand anchor based on chirality
            guard let handAnchor: HandAnchor = switch handComponent.chirality {
                case .left: Self.latestLeftHand
                case .right: Self.latestRightHand
                default: nil
            } else { continue }
            
            // Update all joint positions
            if let handSkeleton = handAnchor.handSkeleton {
                for (jointName, jointEntity) in handComponent.fingers {
                    let anchorFromJointTransform = handSkeleton.joint(jointName).anchorFromJointTransform
                    jointEntity.setTransformMatrix(
                        handAnchor.originFromAnchorTransform * anchorFromJointTransform,
                        relativeTo: nil
                    )
                }
            }
        }
    }
    
    func addJoints(to handEntity: Entity, handComponent: inout HandTrackingComponent) {
        let radius: Float = 0.01
        let material = SimpleMaterial(color: .white, isMetallic: false)
        let sphereEntity = ModelEntity(
            mesh: .generateSphere(radius: radius),
            materials: [material]
        )
        
        // Add sphere for each joint
        for bone in Hand.joints {
            let newJoint = sphereEntity.clone(recursive: false)
            handEntity.addChild(newJoint)
            handComponent.fingers[bone.0] = newJoint
        }
        
        // Save updated component back to entity
        handEntity.components.set(handComponent)
    }
}
