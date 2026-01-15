//
//  FanfareContainer.swift
//  Habitica
//
//  Created by Phillip Thelen on 12.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct FanfareContainer<Content: View>: View {
    var haloColor: Color
    var circleColor: Color = .white
    var outerRingColor: Color
    var plusColor: Color
    @ViewBuilder let content: () -> Content
    
    @State private var animating = false
    
    var body: some View {
        ZStack {
            Image(.fanfareStar).foregroundStyle(haloColor)
                .rotationEffect(.degrees(animating ? 359 : 0))
                .animation(.linear(duration: 30).repeatForever(autoreverses: false), value: animating)
            Image(.fanfareRadial).foregroundStyle(haloColor)
            content()
                .offset(y: animating ? 2 : -2)
                .animation(.linear(duration: 4).repeatForever(autoreverses: true), value: animating)
                .frame(width: 123, height: 123)
                .background(circleColor)
                .clipShape(.circle)
                .padding(8)
                .background(outerRingColor)
                .clipShape(.circle)
            ArmoirePlus(thickness: 3, length: 6, maxSpacing: 2, color: plusColor)
                .offset(x: -70, y: -60)
            ArmoirePlus(color: plusColor)
                .offset(x: 80, y: 55)
        }.onAppear {
            animating = true
        }
    }
}

#Preview {
    FanfareContainer(haloColor: .blue500, circleColor: .systemBackground, outerRingColor: .blue500, plusColor: .blue100) {
        Image(Asset.giantGem.name)
    }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.blue100)
}
