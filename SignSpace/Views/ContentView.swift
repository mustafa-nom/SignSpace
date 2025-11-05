import SwiftUI
import RealityKit

struct ContentView: View {
    @State private var showDataCollection = false
    @State private var viewModel = ContentViewModel()

    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.handTrackingManager) private var handTracker

    var body: some View {
        Group {
            if showDataCollection {
                DataCollectionView()
            } else {
                ZStack {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 6) {
                            Text("SignSpace")
                                .font(.largeTitle.bold())

                            Text(handTracker?.useMockData == true ? "Simulator Mode" : "Vision Pro Mode")
                                .font(.title3)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 12) {
                                Text("Progress:")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                HStack(spacing: 6) {
                                    ForEach(viewModel.allSigns, id: \.self) { sign in
                                        Circle()
                                            .fill(viewModel.signsLearned.contains(sign) ? Color.green : Color.gray.opacity(0.3))
                                            .frame(width: 10, height: 10)
                                    }
                                }

                                Text("\(viewModel.signsLearned.count)/\(viewModel.allSigns.count)")
                                    .font(.caption.bold())
                            }
                        }
                        .padding(.top, 25)

                        // Current lesson
                        VStack(spacing: 10) {
                            Text("Learn the Sign:")
                                .font(.title2)
                                .foregroundStyle(.secondary)

                            Text(viewModel.currentTargetSign.rawValue.uppercased())
                                .font(.system(size: 100, weight: .bold))
                                .foregroundStyle(viewModel.feedbackColor)

                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 280, height: 280)
                                    .shadow(radius: 8)

                                Image(viewModel.currentTargetSign.rawValue)
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
                                Text(viewModel.feedbackEmoji)
                                    .font(.system(size: 50))
                                    .animation(.spring(response: 0.3), value: viewModel.feedbackEmoji)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(viewModel.feedback)
                                        .font(.title3.bold())
                                        .multilineTextAlignment(.leading)

                                    if viewModel.confidence > 0 {
                                        HStack(spacing: 8) {
                                            ProgressView(value: Double(viewModel.confidence))
                                                .frame(width: 120)
                                            Text("\(Int(viewModel.confidence * 100))%")
                                                .font(.caption.bold())
                                                .foregroundStyle(viewModel.feedbackColor)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(viewModel.feedbackColor.opacity(0.15))
                            .cornerRadius(15)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.feedbackColor)

                            if viewModel.detectedSign != .none &&
                                viewModel.detectedSign != viewModel.currentTargetSign {
                                Text("Detected: \(viewModel.detectedSign.rawValue)")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding(.horizontal)

                        Spacer()

                        // Navigation
                        HStack(spacing: 25) {
                            Button {
                                viewModel.previousSign()
                            } label: {
                                HStack { Image(systemName: "chevron.left"); Text("Previous") }
                            }
                            .disabled(viewModel.currentTargetSign == .A)

                            Button {
                                viewModel.nextSign()
                            } label: {
                                HStack { Text("Next Sign"); Image(systemName: "chevron.right") }
                            }
                            .disabled(viewModel.currentTargetSign == .ThankYou)
                        }
                        .buttonStyle(.bordered)
                        .padding(.bottom, 25)

                        Button("Go to Data Collection") {
                            showDataCollection = true
                        }
                        .padding(.bottom, 10)
                    }

                    if viewModel.showConfetti {
                        ConfettiView().allowsHitTesting(false)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            if let handTracker {
                viewModel.start(with: handTracker)
                Task { @MainActor in
                    await openImmersiveSpace(id: "HandTrackingScene")
                }
            } else {
                print("⚠️ No HandTrackingManager in environment")
            }
        }
        .onDisappear {
            if let handTracker {
                viewModel.stop(with: handTracker)
            }
        }
    }
}
