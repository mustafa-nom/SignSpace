import SwiftUI
import RealityKit

struct HandTrackingView: View {
    var body: some View {
        RealityView { content in
            // Create left hand entity
            let leftHand = Entity()
            leftHand.components.set(HandTrackingComponent(chirality: .left))
            content.add(leftHand)
            
            // Create right hand entity
            let rightHand = Entity()
            rightHand.components.set(HandTrackingComponent(chirality: .right))
            content.add(rightHand)
        }
    }
}
