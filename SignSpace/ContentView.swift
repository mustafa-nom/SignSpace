//
//  ContentView.swift
//  SignSpace
//
//  Created by Mus Nom on 10/16/25.

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    @State private var handTracker = HandTrackingManager()
    @State private var gestureRecognizer = GestureRecognizer()
    
    @State private var currentTargetSign: ASLSign = .letterA
    @State private var detectedSign: ASLSign = .none
    @State private var confidence: Float = 0.0
    @State private var feedback: String = "Make the sign for 'A'"
    
    @State private var feedbackColor: Color = .gray
    @State private var feedbackEmoji = "✋"
    
    @State private var signsLearned: Set<ASLSign> = []
    @State private var showConfetti = false
    
    // Timer for continuous gesture detection
    @State private var detectionTimer: Timer?
    
    let allSigns: [ASLSign] = [.letterA, .letterB, .letterC, .hello, .thankYou]
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                
                // Header with Progress
                VStack(spacing: 5) {
                    Text("SignSpace")
                        .font(.extraLargeTitle)
                        .fontWeight(.bold)
                    
                    Text(handTracker.useMockData ? "🎮 Simulator Mode" : "👋 Vision Pro Mode")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    
                    // Progress Bar
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
                
                // 3D Hand Visualization Area with Ghost Hands + Skeleton
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
                
                // Feedback Section
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
                    
                    // Debug info
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
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                    }
                    .disabled(currentTargetSign == .letterA)
                    
                    Button(action: nextSign) {
                        HStack {
                            Text("Next Sign")
                            Image(systemName: "chevron.right")
                        }
                    }
                    .disabled(currentTargetSign == .thankYou)
                    
                }
                .buttonStyle(.bordered)
                .padding(.bottom, 30)
                
                ToggleImmersiveSpaceButton()
                    .padding(.bottom, 20)
            }
            
            // Confetti Effect
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }
        }
        .padding()
        .onAppear {
            startGestureDetection()
        }
        .onDisappear {
            stopGestureDetection()
        }
    }
    
    // MARK: - Hand Visualization with Ghost Hands + Skeleton
    
    func createHandVisualization() -> Entity {
        let container = Entity()
        container.name = "handContainer"
        return container
    }
    
    func updateHandVisualization(content: RealityViewContent) {
        guard let container = content.entities.first(where: { $0.name == "handContainer" }) else { return }
        
        container.children.removeAll()
        
        // 1. Draw GHOST HANDS (target positions) - Semi-transparent GREEN
        let ghostPositions = GhostHandData.getIdealHandPositions(for: currentTargetSign)
        
        // Draw ghost joints
        for joint in ghostPositions {
            let sphere = MeshResource.generateSphere(radius: 0.012)
            var material = UnlitMaterial(color: .green)
            material.blending = .transparent(opacity: 0.4)
            
            let ghostEntity = ModelEntity(mesh: sphere, materials: [material])
            ghostEntity.position = joint.position
            container.addChild(ghostEntity)
        }
        
        // Draw ghost skeleton lines
        if ghostPositions.count >= 6 {
            let wrist = ghostPositions[0].position
            let thumb = ghostPositions[1].position
            let index = ghostPositions[2].position
            let middle = ghostPositions[3].position
            let ring = ghostPositions[4].position
            let pinky = ghostPositions[5].position
            
            // Connect wrist to all fingers
            container.addChild(createLineBetween(from: wrist, to: thumb, color: .green.withAlphaComponent(0.4)))
            container.addChild(createLineBetween(from: wrist, to: index, color: .green.withAlphaComponent(0.4)))
            container.addChild(createLineBetween(from: wrist, to: middle, color: .green.withAlphaComponent(0.4)))
            container.addChild(createLineBetween(from: wrist, to: ring, color: .green.withAlphaComponent(0.4)))
            container.addChild(createLineBetween(from: wrist, to: pinky, color: .green.withAlphaComponent(0.4)))
            
            // Connect fingers to each other (palm structure)
            container.addChild(createLineBetween(from: index, to: middle, color: .green.withAlphaComponent(0.3), thickness: 0.002))
            container.addChild(createLineBetween(from: middle, to: ring, color: .green.withAlphaComponent(0.3), thickness: 0.002))
            container.addChild(createLineBetween(from: ring, to: pinky, color: .green.withAlphaComponent(0.3), thickness: 0.002))
        }
        
        // 2. Draw USER'S ACTUAL HANDS (blue) with skeleton
        if let rightHand = handTracker.rightHand, rightHand.joints.count >= 6 {
            
            // Draw user's joints
            for joint in rightHand.joints {
                let sphere = MeshResource.generateSphere(radius: 0.010)
                let material = SimpleMaterial(color: .systemBlue, isMetallic: false)
                
                let jointEntity = ModelEntity(mesh: sphere, materials: [material])
                jointEntity.position = joint.position
                container.addChild(jointEntity)
            }
            
            // Draw user's skeleton lines
            let wrist = rightHand.joints[0].position
            let thumb = rightHand.joints[1].position
            let index = rightHand.joints[2].position
            let middle = rightHand.joints[3].position
            let ring = rightHand.joints[4].position
            let pinky = rightHand.joints[5].position
            
            // Connect wrist to all fingers
            container.addChild(createLineBetween(from: wrist, to: thumb, color: .systemBlue))
            container.addChild(createLineBetween(from: wrist, to: index, color: .systemBlue))
            container.addChild(createLineBetween(from: wrist, to: middle, color: .systemBlue))
            container.addChild(createLineBetween(from: wrist, to: ring, color: .systemBlue))
            container.addChild(createLineBetween(from: wrist, to: pinky, color: .systemBlue))
            
            // Connect fingers to each other
            container.addChild(createLineBetween(from: index, to: middle, color: .systemBlue, thickness: 0.002))
            container.addChild(createLineBetween(from: middle, to: ring, color: .systemBlue, thickness: 0.002))
            container.addChild(createLineBetween(from: ring, to: pinky, color: .systemBlue, thickness: 0.002))
        }
    }
    
    // Helper function to create lines between joints
    func createLineBetween(from: SIMD3<Float>, to: SIMD3<Float>, color: UIColor, thickness: Float = 0.003) -> ModelEntity {
        let distance = simd_distance(from, to)
        let midpoint = (from + to) / 2
        
        // Create a cylinder to represent the line
        let cylinder = MeshResource.generateCylinder(height: distance, radius: thickness)
        let material = SimpleMaterial(color: color, isMetallic: false)
        let lineEntity = ModelEntity(mesh: cylinder, materials: [material])
        
        // Position at midpoint
        lineEntity.position = midpoint
        
        // Rotate to point from 'from' to 'to'
        let direction = normalize(to - from)
        let up = SIMD3<Float>(0, 1, 0)
        
        if abs(dot(direction, up)) < 0.999 {
            let rotationAxis = cross(up, direction)
            let rotationAngle = acos(dot(up, direction))
            lineEntity.orientation = simd_quatf(angle: rotationAngle, axis: rotationAxis)
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
    }
    
    func checkGesture() {
        let result = gestureRecognizer.detectSign(from: handTracker.rightHand)
        detectedSign = result.sign
        confidence = result.confidence
        feedback = result.feedback.isEmpty ? "Make the sign for '\(currentTargetSign.rawValue)'" : result.feedback
        
        // Update feedback based on result
        if detectedSign == currentTargetSign {
            if confidence > 0.85 {
                feedbackColor = .green
                feedbackEmoji = "🎉"
                
                // ADD THIS LINE:
                SoundManager.shared.playSuccess()
                
                // Mark sign as learned
                if !signsLearned.contains(currentTargetSign) {
                    signsLearned.insert(currentTargetSign)
                    triggerConfetti()
                }
            } else if confidence > 0.65 {
                feedbackColor = .yellow
                feedbackEmoji = "👍"
                
                // ADD THIS LINE:
                SoundManager.shared.playProgress()
                
            } else {
                feedbackColor = .orange
                feedbackEmoji = "🤏"
            }
        } else if detectedSign != .none {
            feedbackColor = .red
            feedbackEmoji = "👋"
            
            // ADD THIS LINE:
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
    
    // MARK: - Navigation
    
    func nextSign() {
        guard let currentIndex = allSigns.firstIndex(of: currentTargetSign),
              currentIndex < allSigns.count - 1 else { return }
        
        currentTargetSign = allSigns[currentIndex + 1]
        resetFeedback()
    }
    
    func previousSign() {
        guard let currentIndex = allSigns.firstIndex(of: currentTargetSign),
              currentIndex > 0 else { return }
        
        currentTargetSign = allSigns[currentIndex - 1]
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

// MARK: - Confetti View

struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50) { index in
                Circle()
                    .fill(Color.random)
                    .frame(width: 10, height: 10)
                    .position(
                        x: CGFloat.random(in: 0...1000),
                        y: animate ? 1000 : -100
                    )
                    .animation(
                        .linear(duration: Double.random(in: 1...2))
                        .repeatForever(autoreverses: false),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

extension Color {
    static var random: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
