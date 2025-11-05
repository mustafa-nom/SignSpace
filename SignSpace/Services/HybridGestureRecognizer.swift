//
//  HybridGestureRecognizer.swift
//  SignSpace
//
//  Created by Mus Nom on 10/31/25.
//


final class HybridGestureRecognizer {
    private let ml = MLGestureRecognizer() //MLGR
    private let rule = GestureRecognizer() //RGR

    // MLGR if high confidence --> else RGR fall-back
    func detect(from hand: HandData?) -> GestureResult {
        let mlResult = ml.detectSign(from: hand)
        
        if mlResult.confidence > 0.88, mlResult.sign != .none {
            return mlResult
        }

        let ruleResult = rule.detectSign(from: hand)

        if ruleResult.sign != .none {
            return ruleResult
        }

        return mlResult
    }
}
