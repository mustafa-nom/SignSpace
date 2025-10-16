//
//  GestureRecognizer.swift
//  SignSpace
//
//  Created by Mus Nom on 10/16/25.
//
//  Simple rule-based ASL gesture detection for hackathon
// has now become
//  Enhanced ASL gesture detection with specific feedback
//

import Foundation
import simd

enum ASLSign: String {
    case letterA = "A"
    case letterB = "B"
    case letterC = "C"
    case hello = "Hello"
    case thankYou = "Thank You"
    case none = "Unknown"
}

struct GestureResult {
    let sign: ASLSign
    let confidence: Float
    let feedback: String  // Specific correction advice
}

class GestureRecognizer {
    
    // Detect which ASL sign the hand is making with detailed feedback
    func detectSign(from hand: HandData?) -> GestureResult {
        guard let hand = hand, hand.isTracked else {
            return GestureResult(sign: .none, confidence: 0.0, feedback: "Show your hand to the camera")
        }
        
        // Get key joint positions
        guard let wrist = hand.joints.first(where: { $0.name.contains("wrist") }),
              let thumbTip = hand.joints.first(where: { $0.name.contains("thumbTip") }),
              let indexTip = hand.joints.first(where: { $0.name.contains("indexFingerTip") }),
              let middleTip = hand.joints.first(where: { $0.name.contains("middleFingerTip") }),
              let ringTip = hand.joints.first(where: { $0.name.contains("ringFingerTip") }),
              let pinkyTip = hand.joints.first(where: { $0.name.contains("littleFingerTip") })
        else {
            return GestureResult(sign: .none, confidence: 0.0, feedback: "Position your hand in view")
        }
        
        // Check each sign pattern with specific feedback
        let letterAResult = checkLetterA(wrist: wrist, thumbTip: thumbTip, indexTip: indexTip, middleTip: middleTip, ringTip: ringTip, pinkyTip: pinkyTip)
        if letterAResult.sign == .letterA {
            return letterAResult
        }
        
        let letterBResult = checkLetterB(wrist: wrist, thumbTip: thumbTip, indexTip: indexTip, middleTip: middleTip, ringTip: ringTip, pinkyTip: pinkyTip)
        if letterBResult.sign == .letterB {
            return letterBResult
        }
        
        let letterCResult = checkLetterC(wrist: wrist, thumbTip: thumbTip, indexTip: indexTip, middleTip: middleTip, ringTip: ringTip, pinkyTip: pinkyTip)
        if letterCResult.sign == .letterC {
            return letterCResult
        }
        
        let helloResult = checkHello(wrist: wrist, thumbTip: thumbTip, indexTip: indexTip, middleTip: middleTip, ringTip: ringTip, pinkyTip: pinkyTip)
        if helloResult.sign == .hello {
            return helloResult
        }
        
        let thankYouResult = checkThankYou(wrist: wrist, thumbTip: thumbTip, indexTip: indexTip, middleTip: middleTip, ringTip: ringTip, pinkyTip: pinkyTip)
        if thankYouResult.sign == .thankYou {
            return thankYouResult
        }
        
        return GestureResult(sign: .none, confidence: 0.0, feedback: "Try making a clear sign")
    }
    
    // MARK: - Letter A Detection with Feedback
    
    private func checkLetterA(wrist: HandJoint, thumbTip: HandJoint, indexTip: HandJoint, middleTip: HandJoint, ringTip: HandJoint, pinkyTip: HandJoint) -> GestureResult {
        
        let indexDist = distance(indexTip.position, wrist.position)
        let middleDist = distance(middleTip.position, wrist.position)
        let ringDist = distance(ringTip.position, wrist.position)
        let pinkyDist = distance(pinkyTip.position, wrist.position)
        
        let indexCurled = indexDist < 0.12
        let middleCurled = middleDist < 0.12
        let ringCurled = ringDist < 0.12
        let pinkyCurled = pinkyDist < 0.12
        
        let thumbOnSide = thumbTip.position.x > indexTip.position.x - 0.03
        
        // Perfect Letter A
        if indexCurled && middleCurled && ringCurled && pinkyCurled && thumbOnSide {
            let confidence = calculateConfidence(
                indexCurled: indexCurled,
                middleCurled: middleCurled,
                ringCurled: ringCurled,
                pinkyCurled: pinkyCurled,
                thumbOnSide: thumbOnSide
            )
            return GestureResult(sign: .letterA, confidence: confidence, feedback: "Perfect! 🎉")
        }
        
        // Close but needs corrections
        var corrections: [String] = []
        
        if !indexCurled {
            corrections.append("Curl your index finger into your palm")
        }
        if !middleCurled {
            corrections.append("Curl your middle finger more")
        }
        if !ringCurled {
            corrections.append("Tuck your ring finger in")
        }
        if !pinkyCurled {
            corrections.append("Curl your pinky finger")
        }
        if !thumbOnSide {
            corrections.append("Place your thumb on the side of your fist")
        }
        
        // If we're close (3+ correct), return partial match with feedback
        let correctCount = [indexCurled, middleCurled, ringCurled, pinkyCurled, thumbOnSide].filter { $0 }.count
        if correctCount >= 3 {
            let feedback = corrections.isEmpty ? "Almost there!" : corrections.first!
            return GestureResult(sign: .letterA, confidence: Float(correctCount) / 5.0, feedback: feedback)
        }
        
        return GestureResult(sign: .none, confidence: 0.0, feedback: "")
    }
    
    // MARK: - Letter B Detection with Feedback
    
    private func checkLetterB(wrist: HandJoint, thumbTip: HandJoint, indexTip: HandJoint, middleTip: HandJoint, ringTip: HandJoint, pinkyTip: HandJoint) -> GestureResult {
        
        let indexExtended = distance(indexTip.position, wrist.position) > 0.15
        let middleExtended = distance(middleTip.position, wrist.position) > 0.15
        let ringExtended = distance(ringTip.position, wrist.position) > 0.15
        let pinkyExtended = distance(pinkyTip.position, wrist.position) > 0.14
        
        let fingersParallel = abs(indexTip.position.y - middleTip.position.y) < 0.05
        let thumbTucked = distance(thumbTip.position, wrist.position) < 0.10
        
        // Perfect Letter B
        if indexExtended && middleExtended && ringExtended && pinkyExtended && fingersParallel && thumbTucked {
            return GestureResult(sign: .letterB, confidence: 0.95, feedback: "Excellent! ✨")
        }
        
        // Provide specific corrections
        var corrections: [String] = []
        
        if !indexExtended {
            corrections.append("Extend your index finger straight up")
        }
        if !middleExtended {
            corrections.append("Straighten your middle finger")
        }
        if !ringExtended {
            corrections.append("Extend your ring finger")
        }
        if !pinkyExtended {
            corrections.append("Straighten your pinky")
        }
        if !fingersParallel {
            corrections.append("Keep all fingers together and parallel")
        }
        if !thumbTucked {
            corrections.append("Tuck your thumb into your palm")
        }
        
        let correctCount = [indexExtended, middleExtended, ringExtended, pinkyExtended, fingersParallel, thumbTucked].filter { $0 }.count
        if correctCount >= 4 {
            let feedback = corrections.isEmpty ? "Almost perfect!" : corrections.first!
            return GestureResult(sign: .letterB, confidence: Float(correctCount) / 6.0, feedback: feedback)
        }
        
        return GestureResult(sign: .none, confidence: 0.0, feedback: "")
    }
    
    // MARK: - Letter C Detection with Feedback
    
    private func checkLetterC(wrist: HandJoint, thumbTip: HandJoint, indexTip: HandJoint, middleTip: HandJoint, ringTip: HandJoint, pinkyTip: HandJoint) -> GestureResult {
        
        let indexDist = distance(indexTip.position, wrist.position)
        let middleDist = distance(middleTip.position, wrist.position)
        
        let indexCurved = indexDist > 0.10 && indexDist < 0.16
        let middleCurved = middleDist > 0.10 && middleDist < 0.16
        let thumbOpposite = abs(thumbTip.position.x - indexTip.position.x) > 0.08
        
        // Perfect Letter C
        if indexCurved && middleCurved && thumbOpposite {
            return GestureResult(sign: .letterC, confidence: 0.92, feedback: "Great! 👏")
        }
        
        var corrections: [String] = []
        
        if !indexCurved {
            if indexDist < 0.10 {
                corrections.append("Extend your index finger more to form a 'C' curve")
            } else {
                corrections.append("Curl your index finger slightly more")
            }
        }
        if !middleCurved {
            corrections.append("Curve your middle finger to match the 'C' shape")
        }
        if !thumbOpposite {
            corrections.append("Move your thumb opposite your index finger to open the 'C'")
        }
        
        let correctCount = [indexCurved, middleCurved, thumbOpposite].filter { $0 }.count
        if correctCount >= 2 {
            let feedback = corrections.isEmpty ? "Almost there!" : corrections.first!
            return GestureResult(sign: .letterC, confidence: Float(correctCount) / 3.0, feedback: feedback)
        }
        
        return GestureResult(sign: .none, confidence: 0.0, feedback: "")
    }
    
    // MARK: - Hello Detection with Feedback
    
    private func checkHello(wrist: HandJoint, thumbTip: HandJoint, indexTip: HandJoint, middleTip: HandJoint, ringTip: HandJoint, pinkyTip: HandJoint) -> GestureResult {
        
        let indexExtended = distance(indexTip.position, wrist.position) > 0.15
        let middleExtended = distance(middleTip.position, wrist.position) > 0.15
        let ringExtended = distance(ringTip.position, wrist.position) > 0.15
        let pinkyExtended = distance(pinkyTip.position, wrist.position) > 0.14
        let thumbExtended = distance(thumbTip.position, wrist.position) > 0.12
        
        // Perfect Hello
        if indexExtended && middleExtended && ringExtended && pinkyExtended && thumbExtended {
            return GestureResult(sign: .hello, confidence: 0.98, feedback: "Perfect wave! 👋")
        }
        
        var corrections: [String] = []
        
        if !indexExtended || !middleExtended || !ringExtended || !pinkyExtended {
            corrections.append("Spread all fingers wide open")
        }
        if !thumbExtended {
            corrections.append("Extend your thumb out to the side")
        }
        
        let correctCount = [indexExtended, middleExtended, ringExtended, pinkyExtended, thumbExtended].filter { $0 }.count
        if correctCount >= 4 {
            let feedback = corrections.isEmpty ? "Almost perfect!" : corrections.first!
            return GestureResult(sign: .hello, confidence: Float(correctCount) / 5.0, feedback: feedback)
        }
        
        return GestureResult(sign: .none, confidence: 0.0, feedback: "")
    }
    
    // MARK: - Thank You Detection with Feedback
    
    private func checkThankYou(wrist: HandJoint, thumbTip: HandJoint, indexTip: HandJoint, middleTip: HandJoint, ringTip: HandJoint, pinkyTip: HandJoint) -> GestureResult {
        
        let indexExtended = distance(indexTip.position, wrist.position) > 0.15
        let middleExtended = distance(middleTip.position, wrist.position) > 0.15
        let ringExtended = distance(ringTip.position, wrist.position) > 0.15
        let fingersTogether = distance(indexTip.position, middleTip.position) < 0.04
        
        // Perfect Thank You
        if indexExtended && middleExtended && ringExtended && fingersTogether {
            return GestureResult(sign: .thankYou, confidence: 0.94, feedback: "Beautiful! 🙏")
        }
        
        var corrections: [String] = []
        
        if !indexExtended || !middleExtended || !ringExtended {
            corrections.append("Extend all fingers straight")
        }
        if !fingersTogether {
            corrections.append("Keep your fingers close together (flat hand)")
        }
        
        let correctCount = [indexExtended, middleExtended, ringExtended, fingersTogether].filter { $0 }.count
        if correctCount >= 3 {
            let feedback = corrections.isEmpty ? "Almost perfect!" : corrections.first!
            return GestureResult(sign: .thankYou, confidence: Float(correctCount) / 4.0, feedback: feedback)
        }
        
        return GestureResult(sign: .none, confidence: 0.0, feedback: "")
    }
    
    // MARK: - Helper Functions
    
    private func distance(_ a: SIMD3<Float>, _ b: SIMD3<Float>) -> Float {
        return simd_distance(a, b)
    }
    
    private func calculateConfidence(indexCurled: Bool, middleCurled: Bool, ringCurled: Bool, pinkyCurled: Bool, thumbOnSide: Bool) -> Float {
        let correctCount = [indexCurled, middleCurled, ringCurled, pinkyCurled, thumbOnSide].filter { $0 }.count
        return Float(correctCount) / 5.0 * 0.95 + 0.05 // Slight randomness
    }
}
