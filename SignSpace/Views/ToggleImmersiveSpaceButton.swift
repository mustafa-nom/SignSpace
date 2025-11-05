//
//  ToggleImmersiveSpaceButton.swift
//  SignSpace
//

import SwiftUI

struct ToggleImmersiveSpaceButton: View {

    @Environment(AppModel.self) private var appModel
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some View {
        Button {
            Task { @MainActor in
                switch appModel.immersiveSpaceState {
                case .open:
                    appModel.immersiveSpaceState = .inTransition
                    await dismissImmersiveSpace()

                case .closed: // ImmersiveView.onDisappear() will set state to .closed.
                    appModel.immersiveSpaceState = .inTransition
                    switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
                    case .opened: // Let ImmersiveView.onAppear() set state to .open.
                        break
                    case .userCancelled, .error: // failed to open; mark as closed
                        fallthrough
                    @unknown default:
                        appModel.immersiveSpaceState = .closed
                    }

                case .inTransition: // disable buttons during transitions
                    break
                }
            }
        } label: {
            Text(appModel.immersiveSpaceState == .open ? "Hide Immersive Space" : "Show Immersive Space")
        }
        .disabled(appModel.immersiveSpaceState == .inTransition)
        .animation(.none, value: 0)
        .fontWeight(.semibold)
    }
}
