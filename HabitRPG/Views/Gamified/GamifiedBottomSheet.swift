//
//  GamifiedBottomSheet.swift
//  Habitica
//
//  Created by Phillip Thelen on 13.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct GamifiedBottomSheet<UpperContent: View, Title: View, Description: View, Buttons: View>: View {
    var upperBackgroundColor: Color = .purple400
    let upperContent: UpperContent
    let title: Title
    let description: Description
    @ViewBuilder let buttons: Buttons
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .topLeading) {
                upperContent.frame(maxWidth: .infinity)
                Button {
                    
                } label: {
                    Image(systemName: "xmark")
                        .scaledFont(size: 24)
                        .frame(width: 24, height: 24)
                }.buttonStyle(.bordered)
                    .tint(.gray10)
                    .clipShape(.circle)
                    .padding(.top, 16)
                    .padding(.leading, 12)
            }
                .padding(.bottom, 35)
                .background(GamifiedWaveBackground(color: upperBackgroundColor))
                .padding(.bottom, 10)
            VStack(spacing: 4) {
                title.scaledFont(size: 20, weight: .semibold)
                description.scaledFont(size: 17)
            }.padding(.horizontal, 30)
                .multilineTextAlignment(.center)
            buttons
                .padding(.horizontal, 16)
        }
    }
}

extension GamifiedBottomSheet where Description == EmptyView {
    init(upperBackgroundColor: Color = .purple400, upperContent: UpperContent, title: Title, buttons: Buttons) {
        self.upperContent = upperContent
        self.title = title
        self.description = EmptyView()
        self.upperBackgroundColor = upperBackgroundColor
        self.buttons = buttons
    }
}

extension GamifiedBottomSheet where Title == EmptyView, Description == EmptyView {
    init(upperBackgroundColor: Color = .purple400, upperContent: UpperContent, buttons: Buttons) {
        self.upperContent = upperContent
        self.title = EmptyView()
        self.description = EmptyView()
        self.upperBackgroundColor = upperBackgroundColor
        self.buttons = buttons
    }
}

extension GamifiedBottomSheet where Title == EmptyView {
    init(upperBackgroundColor: Color = .purple400, upperContent: UpperContent, description: Description, buttons: Buttons) {
        self.upperContent = upperContent
        self.title = EmptyView()
        self.description = description
        self.upperBackgroundColor = upperBackgroundColor
        self.buttons = buttons
    }
}

#Preview {
    NavigationStack {
        Text("Background")
    }.sheet(isPresented: .constant(true)) {
        GamifiedBottomSheet(upperBackgroundColor: .yellow100, upperContent: VStack(spacing: 0) {
            FanfareContainer(haloColor: .yellow500, circleColor: .white, outerRingColor: .yellow500, plusColor: .yellow10) {
                PixelArtView(name: "achievement-alien2x")
                    .frame(width: 56, height: 56)
            }
            Text("You got an Achievement!")
                .foregroundStyle(Color.yellow1)
                .scaledFont(size: 22, weight: .bold)
        }, title: Text("Purchase Equipment"), description: Text("Equipment can be practical or just fashionable. Raise your stats to get all sorts of benefits to your avatar.")) {
            HabiticaButtonUI(label: Text(L10n.onwards), color: .purple400) {
                
            }
        }
        .presentationDetents([.fraction(0.631)])
    }
}
