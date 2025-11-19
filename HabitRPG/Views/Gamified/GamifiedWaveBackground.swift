//
//  GamifiedWaveBackground.swift
//  Habitica
//
//  Created by Phillip Thelen on 12.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI

func buildGamifiedWavePath(proxy: GeometryProxy, waveScale: CGFloat) -> Path {
    return Path { path in
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: proxy.size.height))
        path.addCurve(to: CGPoint(x: proxy.size.width/2, y: proxy.size.height),
                      control1: CGPoint(x: proxy.size.width/5, y: proxy.size.height - (24 * waveScale)),
                      control2: CGPoint(x: proxy.size.width/4, y: proxy.size.height))
        path.addCurve(to: CGPoint(x: proxy.size.width, y: proxy.size.height),
                      control1: CGPoint(x: (proxy.size.width/6) * 5, y: proxy.size.height),
                      control2: CGPoint(x: (proxy.size.width/16) * 15, y: proxy.size.height - (24 * waveScale)))
        path.addLine(to: CGPoint(x: proxy.size.width, y: 0))
        path.closeSubpath()
    }
}

struct GamifiedWave: Shape {
    var waveScale: CGFloat
    
    public var animatableData: CGFloat {
        get {
            waveScale
        }
        set {
            waveScale = newValue
        }
    }
    
    nonisolated func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: 0, y: rect.size.height))
            path.addCurve(to: CGPoint(x: rect.size.width/2, y: rect.size.height),
                          control1: CGPoint(x: rect.size.width/5, y: rect.size.height - (24 * waveScale)),
                          control2: CGPoint(x: rect.size.width/4, y: rect.size.height))
            path.addCurve(to: CGPoint(x: rect.size.width, y: rect.size.height),
                          control1: CGPoint(x: (rect.size.width/6) * 5, y: rect.size.height),
                          control2: CGPoint(x: (rect.size.width/16) * 15, y: rect.size.height - (24 * waveScale)))
            path.addLine(to: CGPoint(x: rect.size.width, y: 0))
            path.closeSubpath()
        }
    }
}

struct GamifiedWaveBackground<BackgroundView: View>: ViewModifier {
    let view: BackgroundView
    
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content.background(view.clipShape(GamifiedWave(waveScale: (isAnimating ? 1 : 0)))
            .animation(.bouncy.delay(0.2), value: isAnimating)
        ).onAppear {
            isAnimating = true
        }
    }
}

extension View {
    func gamifiedWaveBackground(color: Color) -> some View {
        return modifier(GamifiedWaveBackground(view: Rectangle().foregroundStyle(color)))
    }
    
    func gamifiedWaveBackground<BackgroundView: View>(view: BackgroundView) -> some View {
        return modifier(GamifiedWaveBackground(view: view))
    }
}

#Preview {
    Text("Preview")
        .padding(50)
        .frame(maxWidth: .infinity)
        .gamifiedWaveBackground(color: .purple400)
}

#Preview("Pet Background") {
    Text("Pet background")
        .padding(50)
        .frame(maxWidth: .infinity)
        .gamifiedWaveBackground(view: StableBackgroundView())
}
