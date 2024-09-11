//
//  G1G1Banner.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.09.24.
//  Copyright © 2024 HabitRPG Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct G1G1Banner: View {
    var endDate: Date
    
    private let formatter = DateFormatter()
    
    var body: some View {
        HStack {
            Image(Asset.promoGiftsLeft.name)
            VStack {
                Text(L10n.giftOneGetOneTitle)
                    .font(.system(size: 22, weight: .bold))
                Text(L10n.giftOneGetOneDescriptionDate(formatter.string(from: endDate)))
                    .font(.system(size: 16, weight: .semibold))
                    .multilineTextAlignment(.center)
            }
            Image(Asset.promoGiftsRight.name)
        }.background(LinearGradient(colors: [Color("#3BCAD7"), Color("#925CF3")], startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

#Preview {
    G1G1Banner(endDate: Date())
}
