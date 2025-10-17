import SwiftUI
import RealityKit
import UIKit
import RealityKitContent

struct ContentView: View {

    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    @State private var showDataCollection = false
    @State private var handTracker = HandTrackingManager()
    @State private var gestureRecognizer = MLGestureRecognizer()

    @State private var currentTargetSign: ASLSign = .A
    @State private var detectedSign: ASLSign = .none
    @State private var confidence: Float = 0.0
    @State private var feedback: String = "Make the sign for 'A'"
    @State private var lastSoundPlayedAt = Date.distantPast

    @State private var feedbackColor: Color = .gray
    @State private var feedbackEmoji = "✋"

    @State private var signsLearned: Set<ASLSign> = []
    @State private var showConfetti = false

    @State private var detectionTimer: Timer?

    let allSigns: [ASLSign] = [.A, .B, .C, .Hello, .ThankYou]

    var body: some View {
        if showDataCollection {
            DataCollectionView(handTracker: handTracker)
        } else {
            ZStack {
                VStack(spacing: 25) {

                    // Header with Progress
                    VStack(spacing: 6) {
                        Text("SignSpace")
                            .font(.largeTitle.bold())

                        Text(handTracker.useMockData ? "🎮 Simulator Mode" : "👋 Vision Pro Mode")
                            .font(.title3)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            Text("Progress:")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 6) {
                                ForEach(allSigns, id: \.self) { sign in
                                    Circle()
                                        .fill(signsLearned.contains(sign) ? Color.green : Color.gray.opacity(0.3))
                                        .frame(width: 10, height: 10)
                                }
                            }

                            Text("\(signsLearned.count)/\(allSigns.count)")
                                .font(.caption.bold())
                        }
                    }
                    .padding(.top, 25)

                    // Current Lesson Section
                    VStack(spacing: 10) {
                        Text("Learn the Sign:")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        
                        Text(currentTargetSign.rawValue.replacingOccurrences(of: "letter", with: "").uppercased())
                            .font(.system(size: 100, weight: .bold))
                            .foregroundStyle(feedbackColor)

                        
                        // Polished static ASL image card
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.15))
                                .frame(width: 280, height: 280)
                                .shadow(radius: 8)

                            Image(currentTargetSign.rawValue)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 220, height: 220)
                                .cornerRadius(20)
                        }
                    }
                    .padding(.top, 10)

                    // Feedback
                    VStack(spacing: 12) {
                        HStack {
                            Text(feedbackEmoji)
                                .font(.system(size: 50))
                                .animation(.spring(response: 0.3), value: feedbackEmoji)

                            VStack(alignment: .leading, spacing: 6) {
                                Text(feedback)
                                    .font(.title3.bold())
                                    .multilineTextAlignment(.leading)

                                if confidence > 0 {
                                    HStack(spacing: 8) {
                                        ProgressView(value: Double(confidence))
                                            .frame(width: 120)
                                        Text("\(Int(confidence * 100))%")
                                            .font(.caption.bold())
                                            .foregroundStyle(feedbackColor)
                                    }
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(feedbackColor.opacity(0.15))
                        .cornerRadius(15)
                        .animation(.easeInOut(duration: 0.3), value: feedbackColor)

                        if detectedSign != .none && detectedSign != currentTargetSign {
                            Text("Detected: \(detectedSign.rawValue)")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()

                    // Navigation Controls
                    HStack(spacing: 25) {
                        Button(action: previousSign) {
                            HStack { Image(systemName: "chevron.left"); Text("Previous") }
                        }
                        .disabled(currentTargetSign == .A)

                        Button(action: nextSign) {
                            HStack { Text("Next Sign"); Image(systemName: "chevron.right") }
                        }
                        .disabled(currentTargetSign == .ThankYou)
                    }
                    .buttonStyle(.bordered)
                    .padding(.bottom, 25)

                    ToggleImmersiveSpaceButton()
                        .padding(.bottom, 20)
                }

                if showConfetti {
                    ConfettiView().allowsHitTesting(false)
                }
            }
            .padding()
            .onAppear {
                startGestureDetection()
                handTracker.start()
                Task { @MainActor in
                    await openImmersiveSpace(id: "HandTrackingScene")
                }
            }
            .onDisappear {
                stopGestureDetection()
                handTracker.stop()
            }
        }
    }

    // MARK: - Gesture Detection

    func startGestureDetection() {
        detectionTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            checkGesture()
        }
    }

    func stopGestureDetection() {
        detectionTimer?.invalidate()
        detectionTimer = nil
    }

    func checkGesture() {
        let result = gestureRecognizer.detectSign(from: handTracker.rightHand)
        detectedSign = result.sign
        confidence = result.confidence

        let now = Date()
        let cooldown: TimeInterval = 2.0

        // 🔒 Only consider confidence if sign matches the current target
        if detectedSign == currentTargetSign {
            // ✅ Correct sign
            if confidence > 0.85 {
                feedbackColor = .green
                feedbackEmoji = "🎉"

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
                if now.timeIntervalSince(lastSoundPlayedAt) > cooldown {
                    SoundManager.shared.playProgress()
                    lastSoundPlayedAt = now
                }
            } else {
                feedbackColor = .orange
                feedbackEmoji = "🤏"
            }
        }
        // 🚫 Detected a sign, but not the target
        else if detectedSign != .none {
            feedbackColor = .red
            feedbackEmoji = "👋"
            feedback = "That's the sign for \(detectedSign.rawValue). Try \(currentTargetSign.rawValue)!"
            if now.timeIntervalSince(lastSoundPlayedAt) > cooldown {
                SoundManager.shared.playError()
                lastSoundPlayedAt = now
            }
        }
        // 🕓 No sign detected
        else {
            feedbackColor = .gray
            feedbackEmoji = "✋"
            feedback = "Show your hand to the camera"
        }
    }

    func triggerConfetti() {
        showConfetti = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showConfetti = false
        }
    }

    func nextSign() {
        guard let idx = allSigns.firstIndex(of: currentTargetSign), idx < allSigns.count - 1 else { return }
        currentTargetSign = allSigns[idx + 1]
        resetFeedback()
    }

    func previousSign() {
        guard let idx = allSigns.firstIndex(of: currentTargetSign), idx > 0 else { return }
        currentTargetSign = allSigns[idx - 1]
        resetFeedback()
    }

    func resetFeedback() {
        feedbackColor = .gray
        feedback = "Make the sign for '\(currentTargetSign.rawValue)'"
        feedbackEmoji = "✋"
        detectedSign = .none
        confidence = 0.0
    }
}
