//
//  test.swift
//  Habitica
//
//  Created by Phillip Thelen on 24.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct SliderTest: View {
    var body: some View {
        VStack {
            Slider(value: .constant(0.5))
        }
            .background(Color.gray)
    }
}

#Preview {
    SliderTest()
}
