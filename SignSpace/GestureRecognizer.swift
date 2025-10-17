//
//  GestureRecognizer.swift
//  SignSpace
//

import Foundation
import simd

enum ASLSign: String, CaseIterable {
    case A = "A"
    case B = "B"
    case C = "C"
    case Hello = "Hello"
    case ThankYou = "Thank You"
    case none = "none"
}

struct GestureResult {
    let sign: ASLSign
    let confidence: Float
    let feedback: String
}

final class GestureRecognizer {

    func detectSign(from hand: HandData?) -> GestureResult {
        guard let hand = hand, hand.isTracked else {
            return GestureResult(sign: .none, confidence: 0.0, feedback: "Show your hand to the camera")
        }

        guard
            let wrist     = hand.joints.first(where: { $0.name.contains("wrist") }),
            let thumbTip  = hand.joints.first(where: { $0.name.contains("thumbTip") }),
            let indexTip  = hand.joints.first(where: { $0.name.contains("indexFingerTip") }),
            let middleTip = hand.joints.first(where: { $0.name.contains("middleFingerTip") }),
            let ringTip   = hand.joints.first(where: { $0.name.contains("ringFingerTip") }),
            let pinkyTip  = hand.joints.first(where: { $0.name.contains("littleFingerTip") })
        else {
            return GestureResult(sign: .none, confidence: 0.0, feedback: "Position your hand in view")
        }

        // A
        let aResult = checkLetterA(wrist: wrist, thumbTip: thumbTip, indexTip: indexTip, middleTip: middleTip, ringTip: ringTip, pinkyTip: pinkyTip)
        if aResult.sign == .A { return aResult }

        // B
        let bResult = checkLetterB(wrist: wrist, thumbTip: thumbTip, indexTip: indexTip, middleTip: middleTip, ringTip: ringTip, pinkyTip: pinkyTip)
        if bResult.sign == .B { return bResult }

        // C
        let cResult = checkLetterC(wrist: wrist, thumbTip: thumbTip, indexTip: indexTip, middleTip: middleTip, ringTip: ringTip, pinkyTip: pinkyTip)
        if cResult.sign == .C { return cResult }

        // Hello
        let helloResult = checkHello(wrist: wrist, thumbTip: thumbTip, indexTip: indexTip, middleTip: middleTip, ringTip: ringTip, pinkyTip: pinkyTip)
        if helloResult.sign == .Hello { return helloResult }

        // Thank You
        let thankYouResult = checkThankYou(wrist: wrist, thumbTip: thumbTip, indexTip: indexTip, middleTip: middleTip, ringTip: ringTip, pinkyTip: pinkyTip)
        if thankYouResult.sign == .ThankYou { return thankYouResult }

        return GestureResult(sign: .none, confidence: 0.0, feedback: "Try making a clear sign")
    }

    // MARK: - A
    private func checkLetterA(
        wrist: HandJoint, thumbTip: HandJoint, indexTip: HandJoint, middleTip: HandJoint, ringTip: HandJoint, pinkyTip: HandJoint
    ) -> GestureResult {

        let indexDist  = distance(indexTip.position, wrist.position)
        let middleDist = distance(middleTip.position, wrist.position)
        let ringDist   = distance(ringTip.position, wrist.position)
        let pinkyDist  = distance(pinkyTip.position, wrist.position)

        let indexCurled  = indexDist  < 0.12
        let middleCurled = middleDist < 0.12
        let ringCurled   = ringDist   < 0.12
        let pinkyCurled  = pinkyDist  < 0.12

        let thumbOnSide = (thumbTip.position.x > indexTip.position.x - 0.03)

        if indexCurled && middleCurled && ringCurled && pinkyCurled && thumbOnSide {
            return GestureResult(sign: .A, confidence: confidenceA(indexCurled, middleCurled, ringCurled, pinkyCurled, thumbOnSide), feedback: "Perfect! 🎉")
        }

        var corrections: [String] = []
        if !indexCurled  { corrections.append("Curl your index finger into your palm") }
        if !middleCurled { corrections.append("Curl your middle finger more") }
        if !ringCurled   { corrections.append("Tuck your ring finger in") }
        if !pinkyCurled  { corrections.append("Curl your pinky finger") }
        if !thumbOnSide  { corrections.append("Place your thumb on the side of your fist") }

        let correctCount = [indexCurled, middleCurled, ringCurled, pinkyCurled, thumbOnSide].filter { $0 }.count
        if correctCount >= 3 {
            return GestureResult(sign: .A, confidence: Float(correctCount) / 5.0, feedback: corrections.first ?? "Almost there!")
        }

        return GestureResult(sign: .none, confidence: 0.0, feedback: "")
    }

    // MARK: - B
    private func checkLetterB(
        wrist: HandJoint, thumbTip: HandJoint, indexTip: HandJoint, middleTip: HandJoint, ringTip: HandJoint, pinkyTip: HandJoint
    ) -> GestureResult {

        let indexExtended  = distance(indexTip.position, wrist.position)  > 0.15
        let middleExtended = distance(middleTip.position, wrist.position) > 0.15
        let ringExtended   = distance(ringTip.position, wrist.position)   > 0.15
        let pinkyExtended  = distance(pinkyTip.position, wrist.position)  > 0.14

        let fingersParallel = abs(indexTip.position.y - middleTip.position.y) < 0.05
        let thumbTucked = distance(thumbTip.position, wrist.position) < 0.10

        if indexExtended && middleExtended && ringExtended && pinkyExtended && fingersParallel && thumbTucked {
            return GestureResult(sign: .B, confidence: 0.95, feedback: "Excellent! ✨")
        }

        var corrections: [String] = []
        if !indexExtended     { corrections.append("Extend your index finger straight up") }
        if !middleExtended    { corrections.append("Straighten your middle finger") }
        if !ringExtended      { corrections.append("Extend your ring finger") }
        if !pinkyExtended     { corrections.append("Straighten your pinky") }
        if !fingersParallel   { corrections.append("Keep all fingers together and parallel") }
        if !thumbTucked       { corrections.append("Tuck your thumb into your palm") }

        let correctCount = [indexExtended, middleExtended, ringExtended, pinkyExtended, fingersParallel, thumbTucked].filter { $0 }.count
        if correctCount >= 4 {
            return GestureResult(sign: .B, confidence: Float(correctCount) / 6.0, feedback: corrections.first ?? "Almost perfect!")
        }

        return GestureResult(sign: .none, confidence: 0.0, feedback: "")
    }

    // MARK: - C
    private func checkLetterC(
        wrist: HandJoint, thumbTip: HandJoint, indexTip: HandJoint, middleTip: HandJoint, ringTip: HandJoint, pinkyTip: HandJoint
    ) -> GestureResult {

        let indexDist  = distance(indexTip.position, wrist.position)
        let middleDist = distance(middleTip.position, wrist.position)

        let indexCurved  = (indexDist  > 0.10 && indexDist  < 0.16)
        let middleCurved = (middleDist > 0.10 && middleDist < 0.16)
        let thumbOpposite = abs(thumbTip.position.x - indexTip.position.x) > 0.08

        if indexCurved && middleCurved && thumbOpposite {
            return GestureResult(sign: .C, confidence: 0.92, feedback: "Great! 👏")
        }

        var corrections: [String] = []
        if !indexCurved  { corrections.append(indexDist < 0.10 ? "Extend your index finger a bit" : "Curl your index finger slightly") }
        if !middleCurved { corrections.append("Curve your middle finger to match the 'C'") }
        if !thumbOpposite { corrections.append("Move your thumb opposite your index finger") }

        let correctCount = [indexCurved, middleCurved, thumbOpposite].filter { $0 }.count
        if correctCount >= 2 {
            return GestureResult(sign: .C, confidence: Float(correctCount) / 3.0, feedback: corrections.first ?? "Almost there!")
        }

        return GestureResult(sign: .none, confidence: 0.0, feedback: "")
    }

    // MARK: - Hello
    private func checkHello(
        wrist: HandJoint, thumbTip: HandJoint, indexTip: HandJoint, middleTip: HandJoint, ringTip: HandJoint, pinkyTip: HandJoint
    ) -> GestureResult {

        let indexExtended  = distance(indexTip.position, wrist.position)  > 0.15
        let middleExtended = distance(middleTip.position, wrist.position) > 0.15
        let ringExtended   = distance(ringTip.position, wrist.position)   > 0.15
        let pinkyExtended  = distance(pinkyTip.position, wrist.position)  > 0.14
        let thumbExtended  = distance(thumbTip.position, wrist.position)  > 0.12

        if indexExtended && middleExtended && ringExtended && pinkyExtended && thumbExtended {
            return GestureResult(sign: .Hello, confidence: 0.98, feedback: "Perfect wave! 👋")
        }

        var corrections: [String] = []
        if !(indexExtended && middleExtended && ringExtended && pinkyExtended) {
            corrections.append("Spread all fingers wide open")
        }
        if !thumbExtended { corrections.append("Extend your thumb out to the side") }

        let correctCount = [indexExtended, middleExtended, ringExtended, pinkyExtended, thumbExtended].filter { $0 }.count
        if correctCount >= 4 {
            return GestureResult(sign: .Hello, confidence: Float(correctCount) / 5.0, feedback: corrections.first ?? "Almost perfect!")
        }

        return GestureResult(sign: .none, confidence: 0.0, feedback: "")
    }

    // MARK: - Thank You
    private func checkThankYou(
        wrist: HandJoint, thumbTip: HandJoint, indexTip: HandJoint, middleTip: HandJoint, ringTip: HandJoint, pinkyTip: HandJoint
    ) -> GestureResult {

        let indexExtended  = distance(indexTip.position, wrist.position)  > 0.15
        let middleExtended = distance(middleTip.position, wrist.position) > 0.15
        let ringExtended   = distance(ringTip.position, wrist.position)   > 0.15
        let fingersTogether = distance(indexTip.position, middleTip.position) < 0.04

        if indexExtended && middleExtended && ringExtended && fingersTogether {
            return GestureResult(sign: .ThankYou, confidence: 0.94, feedback: "Beautiful! 🙏")
        }

        var corrections: [String] = []
        if !(indexExtended && middleExtended && ringExtended) {
            corrections.append("Extend all fingers straight")
        }
        if !fingersTogether {
            corrections.append("Keep your fingers close together (flat hand)")
        }

        let correctCount = [indexExtended, middleExtended, ringExtended, fingersTogether].filter { $0 }.count
        if correctCount >= 3 {
            return GestureResult(sign: .ThankYou, confidence: Float(correctCount) / 4.0, feedback: corrections.first ?? "Almost perfect!")
        }

        return GestureResult(sign: .none, confidence: 0.0, feedback: "")
    }

    // MARK: - Helpers
    private func distance(_ a: SIMD3<Float>, _ b: SIMD3<Float>) -> Float {
        simd_distance(a, b)
    }

    private func confidenceA(_ i: Bool, _ m: Bool, _ r: Bool, _ p: Bool, _ t: Bool) -> Float {
        let correct = [i, m, r, p, t].filter { $0 }.count
        return Float(correct) / 5.0 * 0.95 + 0.05
    }
}
