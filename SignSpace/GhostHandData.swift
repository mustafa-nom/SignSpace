//
//  GhostHandData.swift
//  SignSpace
//
//  Created by Mus Nom on 10/16/25.
//
//  Defines the ideal hand positions for each ASL sign
//

import Foundation
import simd

struct GhostHandData {
    
    // Returns the ideal hand joint positions for a given sign
    static func getIdealHandPositions(for sign: ASLSign) -> [HandJoint] {
        switch sign {
        case .letterA:
            return letterAPositions()
        case .letterB:
            return letterBPositions()
        case .letterC:
            return letterCPositions()
        case .hello:
            return helloPositions()
        case .thankYou:
            return thankYouPositions()
        case .none:
            return []
        }
    }
    
    // MARK: - Letter A (Closed fist, thumb on side)
    private static func letterAPositions() -> [HandJoint] {
        return [
            HandJoint(name: "wrist", position: SIMD3(0.15, 0.0, -0.3)),
            HandJoint(name: "thumbTip", position: SIMD3(0.18, 0.03, -0.27)),
            HandJoint(name: "indexFingerTip", position: SIMD3(0.15, 0.05, -0.28)),
            HandJoint(name: "middleFingerTip", position: SIMD3(0.17, 0.06, -0.28)),
            HandJoint(name: "ringFingerTip", position: SIMD3(0.19, 0.05, -0.28)),
            HandJoint(name: "littleFingerTip", position: SIMD3(0.21, 0.04, -0.28)),
        ]
    }
    
    // MARK: - Letter B (Fingers straight up, thumb tucked)
    private static func letterBPositions() -> [HandJoint] {
        return [
            HandJoint(name: "wrist", position: SIMD3(0.15, 0.0, -0.3)),
            HandJoint(name: "thumbTip", position: SIMD3(0.16, 0.02, -0.28)),
            HandJoint(name: "indexFingerTip", position: SIMD3(0.13, 0.18, -0.25)),
            HandJoint(name: "middleFingerTip", position: SIMD3(0.15, 0.19, -0.25)),
            HandJoint(name: "ringFingerTip", position: SIMD3(0.17, 0.18, -0.25)),
            HandJoint(name: "littleFingerTip", position: SIMD3(0.19, 0.17, -0.25)),
        ]
    }
    
    // MARK: - Letter C (Curved hand forming C shape)
    private static func letterCPositions() -> [HandJoint] {
        return [
            HandJoint(name: "wrist", position: SIMD3(0.15, 0.0, -0.3)),
            HandJoint(name: "thumbTip", position: SIMD3(0.10, 0.08, -0.27)),
            HandJoint(name: "indexFingerTip", position: SIMD3(0.12, 0.13, -0.25)),
            HandJoint(name: "middleFingerTip", position: SIMD3(0.14, 0.14, -0.25)),
            HandJoint(name: "ringFingerTip", position: SIMD3(0.16, 0.13, -0.25)),
            HandJoint(name: "littleFingerTip", position: SIMD3(0.18, 0.11, -0.26)),
        ]
    }
    
    // MARK: - Hello (All fingers extended, waving)
    private static func helloPositions() -> [HandJoint] {
        return [
            HandJoint(name: "wrist", position: SIMD3(0.15, 0.0, -0.3)),
            HandJoint(name: "thumbTip", position: SIMD3(0.10, 0.10, -0.25)),
            HandJoint(name: "indexFingerTip", position: SIMD3(0.12, 0.18, -0.23)),
            HandJoint(name: "middleFingerTip", position: SIMD3(0.15, 0.20, -0.23)),
            HandJoint(name: "ringFingerTip", position: SIMD3(0.18, 0.19, -0.23)),
            HandJoint(name: "littleFingerTip", position: SIMD3(0.21, 0.17, -0.24)),
        ]
    }
    
    // MARK: - Thank You (Flat hand, fingers together)
    private static func thankYouPositions() -> [HandJoint] {
        return [
            HandJoint(name: "wrist", position: SIMD3(0.15, 0.0, -0.3)),
            HandJoint(name: "thumbTip", position: SIMD3(0.12, 0.08, -0.26)),
            HandJoint(name: "indexFingerTip", position: SIMD3(0.14, 0.17, -0.24)),
            HandJoint(name: "middleFingerTip", position: SIMD3(0.15, 0.18, -0.24)),
            HandJoint(name: "ringFingerTip", position: SIMD3(0.16, 0.17, -0.24)),
            HandJoint(name: "littleFingerTip", position: SIMD3(0.17, 0.16, -0.24)),
        ]
    }
}
