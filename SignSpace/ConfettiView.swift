//
//  ConfettiView.swift
//  SignSpace
//
//  Created by Mus Nom on 10/16/25.
//

// ConfettiView.swift
import SwiftUI

struct ConfettiView: View {
    @State private var animate = false
    private let count = 60

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    Circle()
                        .fill(Color.random)
                        .frame(width: CGFloat.random(in: 6...12),
                               height: CGFloat.random(in: 6...12))
                        .position(
                            x: CGFloat.random(in: 0...geo.size.width),
                            y: animate ? geo.size.height + 40 : -40
                        )
                        .rotationEffect(.degrees(animate ? 360 : 0))
                        .opacity(0.9)
                        .animation(
                            .linear(duration: Double.random(in: 1.2...2.0))
                                .repeatForever(autoreverses: false)
                                .delay(Double(i) * 0.01),
                            value: animate
                        )
                }
            }
            .onAppear { animate = true }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

// If you already defined Color.random elsewhere, remove one of the duplicates.
extension Color {
    static var random: Color {
        Color(.sRGB,
              red: .random(in: 0.2...1),
              green: .random(in: 0.2...1),
              blue: .random(in: 0.2...1),
              opacity: 1)
    }
}
