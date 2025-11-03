import Foundation
import Observation

@MainActor
@Observable
final class DataCollectionViewModel {
    // MARK: - State
    var currentSign: ASLSign = .A
    var samplesCollected = 0
    var isRecording = false
    var collectedSamples: [TrainingSample] = []
    var immersiveSpaceOpened = false
    var showShareSheet = false
    var exportedFileURL: URL?

    let targetSamplesPerSign = 100
    let allSigns: [ASLSign] = [.A, .B, .C, .Hello, .ThankYou]

    // comes from the environment (attached later)
    private var handTracker: HandTrackingManager?
    private var recordingTimer: Timer?

    // MARK: - Wiring
    func attach(handTracker: HandTrackingManager) {
        self.handTracker = handTracker
    }

    // MARK: - Hand tracking
    func startHandTracking() {
        handTracker?.start()
    }

    func stopHandTracking() {
        stopRecording()
        handTracker?.stop()
    }

    // MARK: - Actions
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    func nextSign() {
        guard samplesCollected >= targetSamplesPerSign,
              !isRecording,
              let idx = allSigns.firstIndex(of: currentSign),
              idx < allSigns.count - 1 else { return }

        currentSign = allSigns[idx + 1]
        samplesCollected = 0
    }

    func previousSign() {
        guard !isRecording,
              let idx = allSigns.firstIndex(of: currentSign),
              idx > 0 else { return }

        currentSign = allSigns[idx - 1]
        samplesCollected = 0
    }

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
                exportedFileURL = fileURL
                showShareSheet = true
            } catch {
                print("[ERROR] DataCollection: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Computed
    var isHandTracked: Bool {
        handTracker?.rightHand?.isTracked == true
    }

    var canStartRecording: Bool {
        immersiveSpaceOpened && isHandTracked
    }

    var canNavigateNext: Bool {
        samplesCollected >= targetSamplesPerSign && !isRecording
    }

    var canNavigatePrevious: Bool {
        currentSign != .A && !isRecording
    }

    var progressPercentage: Double {
        Double(samplesCollected) / Double(targetSamplesPerSign)
    }

    var isComplete: Bool {
        samplesCollected >= targetSamplesPerSign
    }

    // MARK: - Private
    private func startRecording() {
        guard isHandTracked else {
            print("[DataCollection] Hand not visible")
            return
        }

        isRecording = true

        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }

                if self.samplesCollected >= self.targetSamplesPerSign {
                    self.stopRecording()
                    return
                }

                if let sample = self.recordSample() {
                    self.collectedSamples.append(sample)
                    self.samplesCollected += 1
                } else {
                    print("[DataCollection] sample failed (no hand)")
                }
            }
        }
    }

    private func stopRecording() {
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
    }

    private func recordSample() -> TrainingSample? {
        guard let hand = handTracker?.rightHand, hand.isTracked else {
            return nil
        }

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

        return TrainingSample(features: features, label: currentSign.rawValue)
    }
}
