import SwiftUI

struct DataCollectionView: View {
    var handTracker: HandTrackingManager
    
    @State private var currentSign: ASLSign = .letterA
    @State private var samplesCollected = 0
    @State private var isRecording = false
    @State private var collectedSamples: [TrainingSample] = []
    @State private var recordingTimer: Timer?
    @State private var immersiveSpaceOpened = false
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    let targetSamplesPerSign = 100
    let allSigns: [ASLSign] = [.letterA, .letterB, .letterC, .hello, .thankYou]
    
    var body: some View {
        VStack(spacing: 30) {
            Text("📊 Data Collection Mode")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Hand tracking status
            HStack {
                Circle()
                    .fill(handTracker.rightHand?.isTracked == true ? Color.green : Color.red)
                    .frame(width: 20, height: 20)
                Text(handTracker.rightHand?.isTracked == true ? "Hand Visible ✅" : "Show Hand to Camera ❌")
                    .font(.headline)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            VStack(spacing: 10) {
                Text("Current Sign:")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                Text(currentSign.rawValue)
                    .font(.system(size: 80))
                    .fontWeight(.bold)
                    .foregroundStyle(isRecording ? .red : .blue)
            }
            
            VStack(spacing: 8) {
                Text("\(samplesCollected) / \(targetSamplesPerSign) samples")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(samplesCollected >= targetSamplesPerSign ? .green : .orange)
                
                ProgressView(value: Double(samplesCollected), total: Double(targetSamplesPerSign))
                    .frame(width: 300)
            }
            
            if isRecording {
                Text("🔴 RECORDING...")
                    .font(.title)
                    .foregroundStyle(.red)
                    .fontWeight(.bold)
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(10)
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Button(action: toggleRecording) {
                    HStack {
                        Image(systemName: isRecording ? "stop.circle.fill" : "record.circle")
                        Text(isRecording ? "Stop Recording" : "Start Recording")
                    }
                    .font(.title2)
                    .fontWeight(.bold)
                }
                .buttonStyle(.borderedProminent)
                .tint(isRecording ? .red : .green)
                .controlSize(.large)
                .disabled(!immersiveSpaceOpened || handTracker.rightHand?.isTracked != true)
                
                HStack(spacing: 20) {
                    Button("Previous Sign") { previousSign() }
                        .disabled(currentSign == .letterA || isRecording)
                    
                    Button("Next Sign") { nextSign() }
                        .disabled(samplesCollected < targetSamplesPerSign || isRecording)
                }
                .buttonStyle(.bordered)
                
                Button("Export All Data as CSV") { exportToCSV() }
                    .buttonStyle(.borderedProminent)
                    .disabled(collectedSamples.isEmpty)
                    .padding(.top, 20)
            }
            .padding(.bottom, 30)
        }
        .padding()
        .task {
            // Open immersive space first
            print("📱 Opening immersive space...")
            await openImmersiveSpace(id: "HandTrackingScene")
            immersiveSpaceOpened = true
            
            // Then start hand tracking
            try? await Task.sleep(for: .seconds(0.5)) // Give immersive space time to initialize
            handTracker.start()
        }
        .onDisappear {
            stopRecording()
            handTracker.stop()
            Task {
                await dismissImmersiveSpace()
            }
        }
    }
    
    // MARK: - Recording
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func startRecording() {
        guard handTracker.rightHand?.isTracked == true else {
            print("❌ Cannot start recording - hand not visible")
            return
        }
        
        isRecording = true
        print("🔴 Recording started for \(currentSign.rawValue)")
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if samplesCollected >= targetSamplesPerSign {
                stopRecording()
                return
            }
            
            if let sample = recordSample() {
                collectedSamples.append(sample)
                samplesCollected += 1
                print("✅ Sample \(samplesCollected)/\(targetSamplesPerSign) for \(currentSign.rawValue)")
            } else {
                print("⚠️ Could not record sample - hand not visible")
            }
        }
    }
    
    func stopRecording() {
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        print("⏹️ Recording stopped")
    }
    
    func recordSample() -> TrainingSample? {
        guard let hand = handTracker.rightHand, hand.isTracked else {
            return nil
        }
        
        // Extract features from first 6 key joints (wrist, thumb, index, middle, ring, pinky tips)
        var features: [Double] = []
        let jointsToUse = min(hand.joints.count, 6)
        
        for i in 0..<jointsToUse {
            let joint = hand.joints[i]
            features.append(Double(joint.position.x))
            features.append(Double(joint.position.y))
        }
        
        // Pad with zeros if needed
        while features.count < 12 {
            features.append(0.0)
        }
        
        return TrainingSample(features: features, label: currentSign.rawValue)
    }
    
    // MARK: - Navigation
    
    func nextSign() {
        if let idx = allSigns.firstIndex(of: currentSign), idx < allSigns.count - 1 {
            currentSign = allSigns[idx + 1]
            samplesCollected = 0
            print("➡️ Moving to sign: \(currentSign.rawValue)")
        }
    }
    
    func previousSign() {
        if let idx = allSigns.firstIndex(of: currentSign), idx > 0 {
            currentSign = allSigns[idx - 1]
            samplesCollected = 0
            print("⬅️ Moving to sign: \(currentSign.rawValue)")
        }
    }
    
    // MARK: - Export
    
    func exportToCSV() {
        var csv = "label,feature_0,feature_1,feature_2,feature_3,feature_4,feature_5,feature_6,feature_7,feature_8,feature_9,feature_10,feature_11\n"
        
        for sample in collectedSamples {
            csv += sample.label
            for feature in sample.features {
                csv += ",\(feature)"
            }
            csv += "\n"
        }
        
        let filename = "asl_training_data_\(Date().timeIntervalSince1970).csv"
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(filename)
            do {
                try csv.write(to: fileURL, atomically: true, encoding: .utf8)
                print("✅✅✅ CSV SAVED TO: \(fileURL.path)")
                print("📊 Total samples: \(collectedSamples.count)")
                print("📁 File: \(filename)")
            } catch {
                print("❌ Failed to save CSV: \(error)")
            }
        }
    }
}

struct TrainingSample {
    let features: [Double]
    let label: String
}
