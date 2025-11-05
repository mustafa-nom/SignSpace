//
//  MLGestureRecognizer.swift
//  SignSpace
//
//  ML-powered gesture recognition using a trained ASL Core ML model.
//

import CoreML
import Foundation

// Performs on-device ASL classification using a Core ML model and returns user-facing feedback.
final class MLGestureRecognizer {
    private var model: ASLClassifierReal1?
    
    init() {
        let config = MLModelConfiguration()
        if let loadedModel = try? ASLClassifierReal1(configuration: config) {
            model = loadedModel
            print("ML model loaded successfully")
        } else {
            print("Failed to load ML model")
        }
    }
    
    // Runs inference on the provided hand data and returns the sign prediction
    func detectSign(from hand: HandData?) -> GestureResult {
        guard let hand = hand, hand.isTracked else {
            return GestureResult(
                sign: .none,
                confidence: 0.0,
                feedback: "Show your hand to the camera"
            )
        }
        
        guard let model = model else {
            return GestureResult(
                sign: .none,
                confidence: 0.0,
                feedback: "Model not loaded"
            )
        }
        
        guard hand.joints.count >= 6 else {
            return GestureResult(
                sign: .none,
                confidence: 0.0,
                feedback: "Not enough joints tracked"
            )
        }

        let features = extractFeatures(from: hand)
        
        // create model input that matches CreateML schema
        do {
            let input = ASLClassifierReal1Input(
                feature_0: features[0],
                feature_1: features[1],
                feature_2: features[2],
                feature_3: features[3],
                feature_4: features[4],
                feature_5: features[5],
                feature_6: features[6],
                feature_7: features[7],
                feature_8: features[8],
                feature_9: features[9],
                feature_10: features[10],
                feature_11: features[11]
            )
            
            let prediction = try model.prediction(input: input)
            
            // map predicted label to ASLSign enum
            guard let detectedSign = ASLSign(rawValue: prediction.label) else {
                print("Unknown label from model: \(prediction.label)")
                return GestureResult(
                    sign: .none,
                    confidence: 0.0,
                    feedback: "Unknown sign detected: \(prediction.label)"
                )
            }
            
            // Extract confidence
            var confidence: Float = 0.0
            if let prob = prediction.labelProbability[prediction.label] {
                confidence = Float(truncating: prob as NSNumber)
            } else {
                confidence = 0.50
            }
            
            let feedback = generateFeedback(for: detectedSign, confidence: confidence)
            print("ML prediction: \(prediction.label) (\(Int(confidence * 100))% confidence)")
            
            return GestureResult(
                sign: detectedSign,
                confidence: confidence,
                feedback: feedback
            )
            
        } catch {
            print("ML prediction error: \(error.localizedDescription)")
            return GestureResult(
                sign: .none,
                confidence: 0.0,
                feedback: "Prediction failed"
            )
        }
    }
    
    // converts a subset of joints into a flat feature vector of length 12 (6 joints × x/y).
    private func extractFeatures(from hand: HandData) -> [Double] {
        var features: [Double] = []

        let jointsToUse = min(hand.joints.count, 6)
        for i in 0..<jointsToUse {
            let joint = hand.joints[i]
            features.append(Double(joint.position.x))
            features.append(Double(joint.position.y))
        }

        while features.count < 12 {
            features.append(0.0)
        }

        return features
    }

    private func generateFeedback(for sign: ASLSign, confidence: Float) -> String {
        switch confidence {
        case let c where c > 0.9:
            return "Perfect"
        case let c where c > 0.75:
            return "Great—almost perfect for \(sign.rawValue)"
        case let c where c > 0.6:
            return "Good try—keep practicing \(sign.rawValue)"
        case let c where c > 0.4:
            return "Getting closer to \(sign.rawValue)"
        default:
            return "Not quite \(sign.rawValue). Review the correct form"
        }
    }
}
