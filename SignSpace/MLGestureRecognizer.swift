//
//  MLGestureRecognizer.swift
//  SignSpace
//
//  ML-powered gesture recognition using trained ASL model
//

import CoreML
import Foundation

class MLGestureRecognizer {
    
    private var model: ASLClassifier1?
    
    init() {
        do {
            let config = MLModelConfiguration()
            model = try ASLClassifier1(configuration: config)
            print("✅ ML Model loaded successfully!")
        } catch {
            print("❌ Failed to load ML model: \(error)")
        }
    }
    
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
        
        // Extract features from hand joints (12 features = 6 joints × 2 coords)
        guard hand.joints.count >= 6 else {
            return GestureResult(
                sign: .none,
                confidence: 0.0,
                feedback: "Not enough joints tracked"
            )
        }
        
        let features = extractFeatures(from: hand)
        
        do {
            // Create model input
            let input = ASLClassifier1Input(
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
            
            // Get prediction
            let prediction = try model.prediction(input: input)
            
            // Convert to ASLSign
            guard let detectedSign = ASLSign(rawValue: prediction.label) else {
                print("⚠️ Unknown label from model: \(prediction.label)")
                return GestureResult(
                    sign: .none,
                    confidence: 0.0,
                    feedback: "Unknown sign detected: \(prediction.label)"
                )
            }
            
            // Get confidence from labelProbability (singular!)
            var confidence: Float = 0.0
            
            if let probDict = prediction.labelProbability as? [String: Double],
               let prob = probDict[prediction.label] {
                confidence = Float(prob)
            } else if let probDict = prediction.labelProbability as? [String: NSNumber],
                      let prob = probDict[prediction.label] {
                confidence = Float(truncating: prob)
            } else {
                // Fallback
                confidence = 0.85
            }
            
            // Generate feedback
            let feedback = generateFeedback(for: detectedSign, confidence: confidence)
            
            print("🤖 ML Prediction: \(prediction.label) (\(Int(confidence * 100))% confidence)")
            
            return GestureResult(
                sign: detectedSign,
                confidence: confidence,
                feedback: feedback
            )
            
        } catch {
            print("❌ ML Prediction error: \(error)")
            return GestureResult(
                sign: .none,
                confidence: 0.0,
                feedback: "Prediction failed"
            )
        }
    }
    
    private func extractFeatures(from hand: HandData) -> [Double] {
        var features: [Double] = []
        
        // Extract X and Y coordinates from first 6 joints
        for i in 0..<6 {
            let joint = hand.joints[i]
            features.append(Double(joint.position.x))
            features.append(Double(joint.position.y))
        }
        
        return features
    }
    
    private func generateFeedback(for sign: ASLSign, confidence: Float) -> String {
        if confidence > 0.9 {
            return "Perfect! 🎉"
        } else if confidence > 0.75 {
            return "Great! Almost perfect for \(sign.rawValue)"
        } else if confidence > 0.6 {
            return "Good try! Keep practicing \(sign.rawValue)"
        } else if confidence > 0.4 {
            return "Getting closer to \(sign.rawValue)..."
        } else {
            return "Not quite \(sign.rawValue). Review the correct form"
        }
    }
}
