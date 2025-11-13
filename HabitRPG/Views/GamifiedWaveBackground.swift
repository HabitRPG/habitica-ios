//
//  GamifiedWaveBackground.swift
//  Habitica
//
//  Created by Phillip Thelen on 12.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct GamifiedWaveBackground: View {
    let color: Color
    
    var body: some View {
        GeometryReader(content: { proxy in
            Path { path in
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: 0, y: proxy.size.height))
                path.addCurve(to: CGPoint(x: proxy.size.width/2, y: proxy.size.height - 2),
                              control1: CGPoint(x: proxy.size.width/5, y: proxy.size.height - 24),
                              control2: CGPoint(x: proxy.size.width/4, y: proxy.size.height - 2))
                path.addCurve(to: CGPoint(x: proxy.size.width, y: proxy.size.height),
                              control1: CGPoint(x: (proxy.size.width/6) * 5, y: proxy.size.height - 2),
                              control2: CGPoint(x: (proxy.size.width/16) * 15, y: proxy.size.height - 24))
                path.addLine(to: CGPoint(x: proxy.size.width, y: 0))
                path.closeSubpath()
            }.fill().foregroundStyle(color)
        })
    }
}

#Preview {
    Text("Preview")
        .padding(50)
        .background(    GamifiedWaveBackground(color: .purple400))
}
