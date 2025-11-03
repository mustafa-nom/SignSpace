import SwiftUI
import UIKit

struct DataCollectionView: View {
    @State private var viewModel = DataCollectionViewModel()

    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.handTrackingManager) private var handTracker

    var body: some View {
        VStack(spacing: 30) {
            Text("Data Collection Mode")
                .font(.largeTitle.bold())

            // status
            HStack {
                Circle()
                    .fill(viewModel.isHandTracked ? .green : .red)
                    .frame(width: 20, height: 20)

                Text(viewModel.isHandTracked ? "Hand Visible" : "Show Hand to Camera")
                    .font(.headline)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            // current sign
            VStack(spacing: 10) {
                Text("Current Sign:")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text(viewModel.currentSign.rawValue)
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(viewModel.isRecording ? .red : .blue)
            }

            // progress
            VStack(spacing: 8) {
                Text("\(viewModel.samplesCollected) / \(viewModel.targetSamplesPerSign) samples")
                    .font(.title.bold())
                    .foregroundStyle(viewModel.isComplete ? .green : .orange)

                ProgressView(value: viewModel.progressPercentage)
                    .frame(width: 300)
            }

            if viewModel.isRecording {
                Text("RECORDING...")
                    .font(.title.bold())
                    .foregroundStyle(.red)
                    .padding()
                    .background(Color.red.opacity(0.15))
                    .cornerRadius(12)
            }

            Spacer()

            VStack(spacing: 15) {
                Button {
                    viewModel.toggleRecording()
                } label: {
                    HStack {
                        Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "record.circle")
                        Text(viewModel.isRecording ? "Stop Recording" : "Start Recording")
                    }
                    .font(.title3.bold())
                }
                .buttonStyle(.borderedProminent)
                .tint(viewModel.isRecording ? .red : .green)
                .disabled(!viewModel.canStartRecording)

                HStack(spacing: 20) {
                    Button("Previous Sign") { viewModel.previousSign() }
                        .disabled(!viewModel.canNavigatePrevious)

                    Button("Next Sign") { viewModel.nextSign() }
                        .disabled(!viewModel.canNavigateNext)
                }
                .buttonStyle(.bordered)

                Button("Export All Data as CSV") {
                    viewModel.exportToCSV()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.collectedSamples.isEmpty)

                if !viewModel.collectedSamples.isEmpty {
                    Text("Total samples: \(viewModel.collectedSamples.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, 30)
        }
        .padding()
        .task {
            // hook up the env manager
            if let handTracker {
                viewModel.attach(handTracker: handTracker)
            }

            // open immersive space once
            if !viewModel.immersiveSpaceOpened {
                await openImmersiveSpace(id: "HandTrackingScene")
                viewModel.immersiveSpaceOpened = true
                try? await Task.sleep(for: .seconds(0.5))
                viewModel.startHandTracking()
            }
        }
        .onDisappear {
            viewModel.stopHandTracking()
            Task { await dismissImmersiveSpace() }
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            if let url = viewModel.exportedFileURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
}

// MARK: - ShareSheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
