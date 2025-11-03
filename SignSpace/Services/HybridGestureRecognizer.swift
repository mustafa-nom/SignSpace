//
//  HybridGestureRecognizer.swift
//  SignSpace
//
//  Created by Mus Nom on 10/31/25.
//


final class HybridGestureRecognizer {
    private let ml = MLGestureRecognizer()
    private let rule = GestureRecognizer()   // your rule-based

    func detect(from hand: HandData?) -> GestureResult {
        // 1. try ML first
        let mlResult = ml.detectSign(from: hand)

        // high confidence? just use ML
        if mlResult.confidence > 0.88, mlResult.sign != .none {
            return mlResult
        }

        // 2. otherwise fall back to rule-based for better feedback
        let ruleResult = rule.detectSign(from: hand)

        // if ML guessed a sign but was low, and rule has corrections, prefer rule
        if ruleResult.sign != .none {
            return ruleResult
        }

        return mlResult   // default
    }
}
