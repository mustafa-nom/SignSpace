//
//  GhostHandData.swift
//  SignSpace
//

import Foundation
import simd

struct GhostHandData {
    static func getIdealHandPositions(for sign: ASLSign) -> [HandJoint] {
        switch sign {
        case .A:
            return letterAPositions()
        case .B:
            return letterBPositions()
        case .C:
            return letterCPositions()
        case .Hello:
            return helloPositions()
        case .ThankYou:
            return thankYouPositions()
        case .none:
            return []
        }
    }
    
    // all positions relative to wrist at origin, using realistic proportions
    
    private static func letterAPositions() -> [HandJoint] {
        return [
            HandJoint(name: "wrist", position: SIMD3(0, 0, 0)),
            HandJoint(name: "thumbTip", position: SIMD3(0.04, 0.03, 0.02)),
            HandJoint(name: "indexFingerTip", position: SIMD3(0.02, 0.08, 0)),
            HandJoint(name: "middleFingerTip", position: SIMD3(0.01, 0.09, 0)),
            HandJoint(name: "ringFingerTip", position: SIMD3(0, 0.08, 0)),
            HandJoint(name: "littleFingerTip", position: SIMD3(-0.01, 0.07, 0)),
        ]
    }
    
    private static func letterBPositions() -> [HandJoint] {
        return [
            HandJoint(name: "wrist", position: SIMD3(0, 0, 0)),
            HandJoint(name: "thumbTip", position: SIMD3(0.03, 0.02, 0.01)),
            HandJoint(name: "indexFingerTip", position: SIMD3(0.02, 0.18, 0)),
            HandJoint(name: "middleFingerTip", position: SIMD3(0, 0.19, 0)),
            HandJoint(name: "ringFingerTip", position: SIMD3(-0.02, 0.18, 0)),
            HandJoint(name: "littleFingerTip", position: SIMD3(-0.04, 0.17, 0)),
        ]
    }
    
    private static func letterCPositions() -> [HandJoint] {
        return [
            HandJoint(name: "wrist", position: SIMD3(0, 0, 0)),
            HandJoint(name: "thumbTip", position: SIMD3(0.05, 0.10, 0)),
            HandJoint(name: "indexFingerTip", position: SIMD3(0.03, 0.15, -0.02)),
            HandJoint(name: "middleFingerTip", position: SIMD3(0.01, 0.16, -0.02)),
            HandJoint(name: "ringFingerTip", position: SIMD3(-0.01, 0.15, -0.02)),
            HandJoint(name: "littleFingerTip", position: SIMD3(-0.03, 0.13, -0.01)),
        ]
    }
    
    private static func helloPositions() -> [HandJoint] {
        return [
            HandJoint(name: "wrist", position: SIMD3(0, 0, 0)),
            HandJoint(name: "thumbTip", position: SIMD3(0.06, 0.08, 0.01)),
            HandJoint(name: "indexFingerTip", position: SIMD3(0.03, 0.18, 0)),
            HandJoint(name: "middleFingerTip", position: SIMD3(0.01, 0.19, 0)),
            HandJoint(name: "ringFingerTip", position: SIMD3(-0.01, 0.18, 0)),
            HandJoint(name: "littleFingerTip", position: SIMD3(-0.03, 0.16, 0)),
        ]
    }
    
    private static func thankYouPositions() -> [HandJoint] {
        return [
            HandJoint(name: "wrist", position: SIMD3(0, 0, 0)),
            HandJoint(name: "thumbTip", position: SIMD3(0.05, 0.06, 0.01)),
            HandJoint(name: "indexFingerTip", position: SIMD3(0.02, 0.17, 0.02)),
            HandJoint(name: "middleFingerTip", position: SIMD3(0, 0.18, 0.02)),
            HandJoint(name: "ringFingerTip", position: SIMD3(-0.02, 0.17, 0.02)),
            HandJoint(name: "littleFingerTip", position: SIMD3(-0.04, 0.16, 0.02)),
        ]
    }
}
