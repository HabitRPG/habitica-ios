//
//  FanfareContainer.swift
//  Habitica
//
//  Created by Phillip Thelen on 12.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct FanfareContainer<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        ZStack {
            content()
        }
    }
}

#Preview {
    FanfareContainer {
        Image(Asset._4Gems.name)
            .frame(width: 123, height: 123)
            .background(.white)
            .clipShape(.circle)
            .padding(8)
            .background(.white.opacity(0.7))
            .clipShape(.circle)
    }.frame(width: 300, height: 200)
        .background(.blue100)
}
