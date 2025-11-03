import SwiftUI
import Observation

@MainActor
@Observable
final class ContentViewModel {
    var currentTargetSign: ASLSign = .A
    var detectedSign: ASLSign = .none
    var confidence: Float = 0.0
    var feedback: String = "Make the sign for 'A'"
    var feedbackColor: Color = .gray
    var feedbackEmoji: String = "✋"
    var signsLearned: Set<ASLSign> = []
    var showConfetti: Bool = false
    
    let allSigns: [ASLSign] = [.A, .B, .C, .Hello, .ThankYou]
    
    private let gestureRecognizer = MLGestureRecognizer()
    private var detectionTimer: Timer?
    private var lastSoundPlayedAt = Date.distantPast
    private let cooldown: TimeInterval = 2.0
    
    // MARK: - Lifecycle
    func start(with handTracker: HandTrackingManager) {
        startGestureDetection(using: handTracker)
        handTracker.start()
    }
    
    func stop(with handTracker: HandTrackingManager) {
        stopGestureDetection()
        handTracker.stop()
    }
    
    private func startGestureDetection(using handTracker: HandTrackingManager) {
        detectionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkGesture(using: handTracker)
            }
        }
    }
    
    private func stopGestureDetection() {
        detectionTimer?.invalidate()
        detectionTimer = nil
    }
    
    func checkGesture(using handTracker: HandTrackingManager) {
        let result = gestureRecognizer.detectSign(from: handTracker.rightHand)
        detectedSign = result.sign
        confidence = result.confidence
        let now = Date()
        
        if detectedSign == currentTargetSign {
            if confidence > 0.85 {
                feedbackColor = .green
                feedbackEmoji = "🎉"
                feedback = "Perfect!"
                
                if now.timeIntervalSince(lastSoundPlayedAt) > cooldown {
                    SoundManager.shared.playSuccess()
                    lastSoundPlayedAt = now
                }
                
                if !signsLearned.contains(currentTargetSign) {
                    signsLearned.insert(currentTargetSign)
                    triggerConfetti()
                }
            } else if confidence > 0.65 {
                feedbackColor = .yellow
                feedbackEmoji = "👍"
                feedback = "Almost there!"
                
                if now.timeIntervalSince(lastSoundPlayedAt) > cooldown {
                    SoundManager.shared.playProgress()
                    lastSoundPlayedAt = now
                }
            } else {
                feedbackColor = .orange
                feedbackEmoji = "🤏"
                feedback = "Hold the pose a bit clearer"
            }
        } else if detectedSign != .none {
            feedbackColor = .red
            feedbackEmoji = "👋"
            feedback = "That's \(detectedSign.rawValue). Try \(currentTargetSign.rawValue)."
            
            if now.timeIntervalSince(lastSoundPlayedAt) > cooldown {
                SoundManager.shared.playError()
                lastSoundPlayedAt = now
            }
        } else {
            feedbackColor = .gray
            feedbackEmoji = "✋"
            feedback = "Show your hand to the camera"
        }
    }
    
    private func triggerConfetti() {
        showConfetti = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.showConfetti = false
        }
    }
    
    // MARK: - Navigation
    func nextSign() {
        guard let idx = allSigns.firstIndex(of: currentTargetSign),
              idx < allSigns.count - 1 else { return }
        currentTargetSign = allSigns[idx + 1]
        resetFeedback()
    }
    
    func previousSign() {
        guard let idx = allSigns.firstIndex(of: currentTargetSign),
              idx > 0 else { return }
        currentTargetSign = allSigns[idx - 1]
        resetFeedback()
    }
    
    private func resetFeedback() {
        feedbackColor = .gray
        feedbackEmoji = "✋"
        feedback = "Make the sign for '\(currentTargetSign.rawValue)'"
        detectedSign = .none
        confidence = 0.0
    }
}
