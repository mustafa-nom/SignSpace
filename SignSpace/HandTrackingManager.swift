//
//  HandTrackingManager.swift
//  SignSpace
//
//  Created by Mus Nom on 10/16/25.
//  Hand tracking manager with mock data support for simulator testing

import Foundation
import SwiftUI
import RealityKit
import ARKit

// Represents a single hand joint position
struct HandJoint {
    let name: String
    let position: SIMD3<Float>
}

// Represents a complete hand with all joints
struct HandData {
    let joints: [HandJoint]
    let isTracked: Bool
}

@Observable
class HandTrackingManager {
    
    // TOGGLE THIS: true for simulator testing, false for real Vision Pro
    var useMockData = true
    
    // Current hand data
    var leftHand: HandData?
    var rightHand: HandData?
    
    // Hand tracking session (only used when useMockData = false)
    private var handTrackingSession: ARKitSession?
    private var handTracking: HandTrackingProvider?
    
    // Mock data animation
    private var mockAnimationTimer: Timer?
    private var mockAnimationPhase: Float = 0
    
    init() {
        if useMockData {
            startMockHandTracking()
        } else {
            startRealHandTracking()
        }
    }
    
    // MARK: - Mock Hand Tracking (For Simulator)
    
    func startMockHandTracking() {
        print("📱 Starting MOCK hand tracking (simulator mode)")
        
        // Create fake hand data that updates every frame
        mockAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.033, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Animate mock hands (simulate movement)
            self.mockAnimationPhase += 0.05
            
            // Generate mock left hand
            self.leftHand = self.generateMockHand(isLeft: true)
            
            // Generate mock right hand
            self.rightHand = self.generateMockHand(isLeft: false)
        }
    }
    
    func generateMockHand(isLeft: Bool) -> HandData {
        let xOffset: Float = isLeft ? -0.15 : 0.15
        let wave = sin(mockAnimationPhase) * 0.05
        
        // Simplified hand with key joints (thumb, index, middle, ring, pinky tips + palm)
        let joints: [HandJoint] = [
            HandJoint(name: "wrist", position: SIMD3(xOffset, 0.0 + wave, -0.3)),
            HandJoint(name: "thumbTip", position: SIMD3(xOffset + 0.03, 0.05 + wave, -0.25)),
            HandJoint(name: "indexFingerTip", position: SIMD3(xOffset, 0.1 + wave, -0.2)),
            HandJoint(name: "middleFingerTip", position: SIMD3(xOffset + 0.02, 0.12 + wave, -0.2)),
            HandJoint(name: "ringFingerTip", position: SIMD3(xOffset + 0.04, 0.11 + wave, -0.2)),
            HandJoint(name: "littleFingerTip", position: SIMD3(xOffset + 0.06, 0.09 + wave, -0.2)),
        ]
        
        return HandData(joints: joints, isTracked: true)
    }
    
    // MARK: - Real Hand Tracking (For Vision Pro)
    
    func startRealHandTracking() {
        print("👋 Starting REAL hand tracking (Vision Pro mode)")
        
        Task {
            do {
                // Request hand tracking authorization
                let session = ARKitSession()
                let handTracking = HandTrackingProvider()
                
                print("Requesting hand tracking authorization...")
                let authResult = await session.requestAuthorization(for: [.handTracking])
                
                guard authResult[.handTracking] == .allowed else {
                    print("❌ Hand tracking not authorized")
                    return
                }
                
                // Start hand tracking
                try await session.run([handTracking])
                self.handTrackingSession = session
                self.handTracking = handTracking
                
                print("✅ Hand tracking started successfully")
                
                // Process hand updates
                await processHandUpdates(handTracking)
                
            } catch {
                print("❌ Failed to start hand tracking: \(error)")
            }
        }
    }
    
    func processHandUpdates(_ handTracking: HandTrackingProvider) async {
        for await update in handTracking.anchorUpdates {
            switch update.event {
            case .added, .updated:
                let anchor = update.anchor
                
                // Process left hand
                if anchor.chirality == .left {
                    leftHand = extractHandData(from: anchor)
                }
                
                // Process right hand
                if anchor.chirality == .right {
                    rightHand = extractHandData(from: anchor)
                }
                
            case .removed:
                // Handle hand tracking lost
                if update.anchor.chirality == .left {
                    leftHand = nil
                }
                if update.anchor.chirality == .right {
                    rightHand = nil
                }
            }
        }
    }
    
    func extractHandData(from anchor: HandAnchor) -> HandData {
        var joints: [HandJoint] = []
        
        // Extract all joint positions
        let skeleton = anchor.handSkeleton
        
        // Key joints we care about for ASL
        let jointNames: [HandSkeleton.JointName] = [
            .wrist,
            .thumbTip, .thumbIntermediateTip, .thumbIntermediateBase, .thumbKnuckle,
            .indexFingerTip, .indexFingerIntermediateTip, .indexFingerIntermediateBase, .indexFingerKnuckle, .indexFingerMetacarpal,
            .middleFingerTip, .middleFingerIntermediateTip, .middleFingerIntermediateBase, .middleFingerKnuckle, .middleFingerMetacarpal,
            .ringFingerTip, .ringFingerIntermediateTip, .ringFingerIntermediateBase, .ringFingerKnuckle, .ringFingerMetacarpal,
            .littleFingerTip, .littleFingerIntermediateTip, .littleFingerIntermediateBase, .littleFingerKnuckle, .littleFingerMetacarpal,
        ]
        
        for jointName in jointNames {
            // Fix 1: Safely unwrap skeleton and joint
            guard let joint = skeleton?.joint(jointName) else { continue }
            
            let position = anchor.originFromAnchorTransform * joint.anchorFromJointTransform.columns.3
            
            // Fix 2: Use string interpolation instead of .rawValue
            joints.append(HandJoint(
                name: "\(jointName)",
                position: SIMD3(position.x, position.y, position.z)
            ))
        }
        
        return HandData(joints: joints, isTracked: anchor.isTracked)
    }
    
    deinit {
        mockAnimationTimer?.invalidate()
    }
}
