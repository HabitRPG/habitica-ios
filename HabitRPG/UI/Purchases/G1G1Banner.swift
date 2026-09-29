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
    
    private let formatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    var body: some View {
        ZStack(alignment: .center) {
            HStack {
                Image(Asset.subScreenG1g1PresentsLeft.name)
                Spacer()
                Image(Asset.subScreenG1g1PresentsRight.name)
            }
            .background(G1G1GradientBackground())
            Text(L10n.giftOneGetOneDescriptionDate(formatter.string(from: endDate)))
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .lineSpacing(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 80)
        }
        .onTapGesture {
            RouterHandler.shared.handle(.promoInfo)
        }
    }
}

private struct G1G1GradientBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> GradientView {
        let view = GradientView()
        view.startColor = UIColor("#3BCAD7")
        view.endColor = UIColor("#925CF3")
        view.startLocation = 0
        view.endLocation = 1
        view.diagonalMode = true
        return view
    }
    
    func updateUIView(_ uiView: GradientView, context: Context) {
    }
}

#Preview {
    G1G1Banner(endDate: Date())
}
