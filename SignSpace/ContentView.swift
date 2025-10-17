import SwiftUI
import RealityKit
import UIKit
import RealityKitContent

struct ContentView: View {

    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    @State private var showDataCollection = false
    @State private var handTracker = HandTrackingManager()
    @State private var gestureRecognizer = MLGestureRecognizer()

    @State private var currentTargetSign: ASLSign = .letterA
    @State private var detectedSign: ASLSign = .none
    @State private var confidence: Float = 0.0
    @State private var feedback: String = "Make the sign for 'A'"

    @State private var feedbackColor: Color = .gray
    @State private var feedbackEmoji = "✋"

    @State private var signsLearned: Set<ASLSign> = []
    @State private var showConfetti = false

    @State private var detectionTimer: Timer?

    let allSigns: [ASLSign] = [.letterA, .letterB, .letterC, .hello, .thankYou]

    var body: some View {
        if showDataCollection {
            DataCollectionView(handTracker: handTracker)
        } else {
            ZStack {
                VStack(spacing: 20) {

                    // Header with Progress
                    VStack(spacing: 5) {
                        Text("SignSpace")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(handTracker.useMockData ? "🎮 Simulator Mode" : "👋 Vision Pro Mode")
                            .font(.title3)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 15) {
                            Text("Progress:")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 5) {
                                ForEach(allSigns, id: \.self) { sign in
                                    Circle()
                                        .fill(signsLearned.contains(sign) ? Color.green : Color.gray.opacity(0.3))
                                        .frame(width: 12, height: 12)
                                }
                            }

                            Text("\(signsLearned.count)/\(allSigns.count)")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.top, 20)

                    // Current Lesson
                    VStack(spacing: 5) {
                        Text("Learn the sign:")
                            .font(.title2)
                            .foregroundStyle(.secondary)

                        Text(currentTargetSign.rawValue)
                            .font(.system(size: 100))
                            .fontWeight(.bold)
                            .foregroundStyle(feedbackColor)
                            .animation(.spring(response: 0.3), value: feedbackColor)
                    }

                    // Hand visualization
                    RealityView { content in
                        let handVisualization = createHandVisualization()
                        content.add(handVisualization)
                    } update: { content in
                        updateHandVisualization(content: content)
                    }
                    .frame(height: 200)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(20)
                    .padding(.horizontal)

                    // Feedback
                    VStack(spacing: 10) {
                        HStack {
                            Text(feedbackEmoji)
                                .font(.system(size: 50))
                                .animation(.spring(response: 0.3), value: feedbackEmoji)

                            VStack(alignment: .leading, spacing: 5) {
                                Text(feedback)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.leading)

                                if confidence > 0 {
                                    HStack(spacing: 8) {
                                        ProgressView(value: Double(confidence))
                                            .frame(width: 100)
                                        Text("\(Int(confidence * 100))%")
                                            .font(.caption)
                                            .fontWeight(.bold)
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

                    // Controls
                    HStack(spacing: 20) {
                        Button(action: previousSign) {
                            HStack { Image(systemName: "chevron.left"); Text("Previous") }
                        }
                        .disabled(currentTargetSign == .letterA)

                        Button(action: nextSign) {
                            HStack { Text("Next Sign"); Image(systemName: "chevron.right") }
                        }
                        .disabled(currentTargetSign == .thankYou)
                    }
                    .buttonStyle(.bordered)
                    .padding(.bottom, 30)

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
                handTracker.start() // This now just polls HandTrackingSystem
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

    // MARK: - Hand Visualization

    func createHandVisualization() -> Entity {
        let container = Entity()
        container.name = "handContainer"
        return container
    }

    func updateHandVisualization(content: RealityViewContent) {
        guard let container = content.entities.first(where: { $0.name == "handContainer" }) else { return }
        container.children.removeAll()

        // Ghost (target) hand
        let ghostPositions = GhostHandData.getIdealHandPositions(for: currentTargetSign)
        for joint in ghostPositions {
            let sphere = MeshResource.generateSphere(radius: 0.012)
            let material = SimpleMaterial(color: UIColor.green.withAlphaComponent(0.4), isMetallic: false)
            let ghostEntity = ModelEntity(mesh: sphere, materials: [material])
            ghostEntity.position = joint.position
            container.addChild(ghostEntity)
        }

        if ghostPositions.count >= 6 {
            let wrist = ghostPositions[0].position
            let thumb = ghostPositions[1].position
            let index = ghostPositions[2].position
            let middle = ghostPositions[3].position
            let ring = ghostPositions[4].position
            let pinky = ghostPositions[5].position

            container.addChild(createLineBetween(from: wrist, to: thumb, color: .green.withAlphaComponent(0.4)))
            container.addChild(createLineBetween(from: wrist, to: index, color: .green.withAlphaComponent(0.4)))
            container.addChild(createLineBetween(from: wrist, to: middle, color: .green.withAlphaComponent(0.4)))
            container.addChild(createLineBetween(from: wrist, to: ring, color: .green.withAlphaComponent(0.4)))
            container.addChild(createLineBetween(from: wrist, to: pinky, color: .green.withAlphaComponent(0.4)))

            container.addChild(createLineBetween(from: index, to: middle, color: .green.withAlphaComponent(0.3), thickness: 0.002))
            container.addChild(createLineBetween(from: middle, to: ring, color: .green.withAlphaComponent(0.3), thickness: 0.002))
            container.addChild(createLineBetween(from: ring, to: pinky, color: .green.withAlphaComponent(0.3), thickness: 0.002))
        }

        // Live right hand
        if let rightHand = handTracker.rightHand, rightHand.joints.count >= 6 {
            for joint in rightHand.joints {
                let sphere = MeshResource.generateSphere(radius: 0.010)
                let material = SimpleMaterial(color: UIColor.systemBlue, isMetallic: false)
                let jointEntity = ModelEntity(mesh: sphere, materials: [material])
                jointEntity.position = joint.position
                container.addChild(jointEntity)
            }

            let wrist = rightHand.joints[0].position
            let thumb = rightHand.joints[1].position
            let index = rightHand.joints[2].position
            let middle = rightHand.joints[3].position
            let ring = rightHand.joints[4].position
            let pinky = rightHand.joints[5].position

            container.addChild(createLineBetween(from: wrist, to: thumb, color: .systemBlue))
            container.addChild(createLineBetween(from: wrist, to: index, color: .systemBlue))
            container.addChild(createLineBetween(from: wrist, to: middle, color: .systemBlue))
            container.addChild(createLineBetween(from: wrist, to: ring, color: .systemBlue))
            container.addChild(createLineBetween(from: wrist, to: pinky, color: .systemBlue))

            container.addChild(createLineBetween(from: index, to: middle, color: .systemBlue, thickness: 0.002))
            container.addChild(createLineBetween(from: middle, to: ring, color: .systemBlue, thickness: 0.002))
            container.addChild(createLineBetween(from: ring, to: pinky, color: .systemBlue, thickness: 0.002))
        }
    }

    func createLineBetween(from: SIMD3<Float>, to: SIMD3<Float>, color: UIColor, thickness: Float = 0.003) -> ModelEntity {
        let distance = simd_distance(from, to)
        let midpoint = (from + to) / 2
        let cylinder = MeshResource.generateCylinder(height: distance, radius: thickness)
        let material = SimpleMaterial(color: color, isMetallic: false)
        let lineEntity = ModelEntity(mesh: cylinder, materials: [material])
        lineEntity.position = midpoint

        let direction = normalize(to - from)
        let up = SIMD3<Float>(0, 1, 0)
        if abs(dot(direction, up)) < 0.999 {
            let axis = cross(up, direction)
            let angle = acos(dot(up, direction))
            lineEntity.orientation = simd_quatf(angle: angle, axis: axis)
        }
        return lineEntity
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
        feedback = result.feedback.isEmpty ? "Make the sign for '\(currentTargetSign.rawValue)'" : result.feedback

        if detectedSign == currentTargetSign {
            if confidence > 0.85 {
                feedbackColor = .green
                feedbackEmoji = "🎉"
                SoundManager.shared.playSuccess()
                if !signsLearned.contains(currentTargetSign) {
                    signsLearned.insert(currentTargetSign)
                    triggerConfetti()
                }
            } else if confidence > 0.65 {
                feedbackColor = .yellow
                feedbackEmoji = "👍"
                SoundManager.shared.playProgress()
            } else {
                feedbackColor = .orange
                feedbackEmoji = "🤏"
            }
        } else if detectedSign != .none {
            feedbackColor = .red
            feedbackEmoji = "👋"
            SoundManager.shared.playError()
        } else {
            feedbackColor = .gray
            feedbackEmoji = "✋"
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
