//
//  InsufficientCurrencySheet.swift
//  Habitica
//
//  Created by Phillip Thelen on 19.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct InsufficientCurrencySheet<Icon: View, Title: View, Content: View, Buttons: View>: View {
    let backgroundColor: Color
    let circleColor: Color
    let ringColor: Color
    let plusColor: Color
    
    let icon: Icon
    let title: Title
    let content: Content
    @ViewBuilder var buttons: () -> Buttons
    
    var body: some View {
        GamifiedBottomSheet(upperBackgroundColor: backgroundColor, upperContent: VStack {
            ZStack {
                icon
                    .frame(width: 123, height: 123)
                    .background(circleColor)
                    .clipShape(.circle)
                    .padding(8)
                    .background(ringColor)
                    .clipShape(.circle)
                ArmoirePlus(thickness: 3, length: 6, maxSpacing: 2, color: plusColor)
                    .offset(x: -70, y: -60)
                ArmoirePlus(color: plusColor)
                    .offset(x: 80, y: 55)
            }
            title
                .scaledFont(size: 22, weight: .bold)
                .foregroundStyle(.white)
                .padding(.horizontal, 50)
        }.padding(.top, 50), description: content, buttons: buttons)
    }
}

#Preview {
    InsufficientCurrencySheet(
        backgroundColor: .purple400, circleColor: .purple10, ringColor: .purple300, plusColor: .purple500, icon: Image(Asset.insufficientGems.name), title: Text(L10n.moreGemsMessage), content: Text("")) {
            
        }
}
