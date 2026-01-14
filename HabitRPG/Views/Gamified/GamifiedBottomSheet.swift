//
//  GamifiedBottomSheet.swift
//  Habitica
//
//  Created by Phillip Thelen on 13.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI

struct SolidColorView: View {
    let color: Color
    
    var body: some View {
        Rectangle().fill().foregroundStyle(color)
    }
}

struct GamifiedBottomSheet<UpperBackground: View, UpperContent: View, Title: View, Description: View, Buttons: View>: View {
    @ObservedObject var themeService = ThemeService.shared
    @Environment(\.presentationManager)
    var presentationManager

    var upperBackground: UpperBackground
    let upperContent: UpperContent
    var upperContentBottomPadding: CGFloat = 35
    let title: Title
    let description: Description
    @ViewBuilder let buttons: () -> Buttons
    var xButtonBackground: Color?
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .topLeading) {
                upperContent.frame(maxWidth: .infinity)
                    Button {
                        presentationManager.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .scaledFont(size: 24)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.gray10)
                            .frame(width: 44, height: 44)
                    }.buttonStyle(.plain)
                    .background {
                        if let background = xButtonBackground {
                            background
                        } else {
                            Color.gray600.blendMode(.plusDarker)
                        }
                    }
                        .clipShape(.circle)
                        .padding(.top, 16)
                        .padding(.leading, 24)
            }
                .padding(.bottom, upperContentBottomPadding)
                .gamifiedWaveBackground(view: upperBackground)
                .padding(.bottom, 10)
            VStack(spacing: 4) {
                title.scaledFont(size: 20, weight: .semibold)
                description.scaledFont(size: 17)
            }
            .foregroundStyle(Color(themeService.theme.primaryTextColor))
            .padding(.horizontal, 30)
            buttons()
                .padding(.horizontal, 16)
        }
        .multilineTextAlignment(.center)
    }
}

extension GamifiedBottomSheet where UpperBackground == SolidColorView {
    init(upperBackgroundColor: Color = .purple400, upperContent: UpperContent, upperContentBottomPadding: CGFloat = 35, title: Title, description: Description, @ViewBuilder buttons: @escaping () -> Buttons, xButtonBackground: Color? = nil) {
        self.upperContent = upperContent
        self.upperContentBottomPadding = upperContentBottomPadding
        self.title = title
        self.description = description
        self.upperBackground = SolidColorView(color: upperBackgroundColor)
        self.buttons = buttons
        self.xButtonBackground = xButtonBackground
    }
}

extension GamifiedBottomSheet where Description == EmptyView, UpperBackground == SolidColorView {
    init(upperBackgroundColor: Color = .purple400, upperContent: UpperContent, upperContentBottomPadding: CGFloat = 35, title: Title, @ViewBuilder buttons: @escaping () -> Buttons, xButtonBackground: Color? = nil) {
        self.upperContent = upperContent
        self.upperContentBottomPadding = upperContentBottomPadding
        self.title = title
        self.description = EmptyView()
        self.upperBackground = SolidColorView(color: upperBackgroundColor)
        self.buttons = buttons
        self.xButtonBackground = xButtonBackground
    }
}

extension GamifiedBottomSheet where UpperBackground == SolidColorView, Title == EmptyView, Description == EmptyView {
    init(upperBackgroundColor: Color = .purple400, upperContent: UpperContent, upperContentBottomPadding: CGFloat = 35, @ViewBuilder buttons: @escaping () -> Buttons, xButtonBackground: Color? = nil) {
        self.upperContent = upperContent
        self.upperContentBottomPadding = upperContentBottomPadding
        self.title = EmptyView()
        self.description = EmptyView()
        self.upperBackground = SolidColorView(color: upperBackgroundColor)
        self.buttons = buttons
        self.xButtonBackground = xButtonBackground
    }
}

extension GamifiedBottomSheet where UpperBackground == SolidColorView, Title == EmptyView {
    init(upperBackgroundColor: Color = .purple400, upperContent: UpperContent, upperContentBottomPadding: CGFloat = 35, description: Description, @ViewBuilder buttons: @escaping () -> Buttons, xButtonBackground: Color? = nil) {
        self.upperContent = upperContent
        self.upperContentBottomPadding = upperContentBottomPadding
        self.title = EmptyView()
        self.description = description
        self.upperBackground = SolidColorView(color: upperBackgroundColor)
        self.buttons = buttons
        self.xButtonBackground = xButtonBackground
    }
}

// Extensions for custom background view

extension GamifiedBottomSheet where Description == EmptyView {
    init(upperBackground: UpperBackground, upperContent: UpperContent, upperContentBottomPadding: CGFloat = 35, title: Title, @ViewBuilder buttons: @escaping () -> Buttons, xButtonBackground: Color? = nil) {
        self.upperContent = upperContent
        self.upperContentBottomPadding = upperContentBottomPadding
        self.title = title
        self.description = EmptyView()
        self.upperBackground = upperBackground
        self.buttons = buttons
        self.xButtonBackground = xButtonBackground
    }
}

extension GamifiedBottomSheet where Title == EmptyView, Description == EmptyView {
    init(upperBackground: UpperBackground, upperContent: UpperContent, upperContentBottomPadding: CGFloat = 35, @ViewBuilder buttons: @escaping () -> Buttons, xButtonBackground: Color? = nil) {
        self.upperContent = upperContent
        self.upperContentBottomPadding = upperContentBottomPadding
        self.title = EmptyView()
        self.description = EmptyView()
        self.upperBackground = upperBackground
        self.buttons = buttons
        self.xButtonBackground = xButtonBackground
    }
}

extension GamifiedBottomSheet where Title == EmptyView {
    init(upperBackground: UpperBackground, upperContent: UpperContent, upperContentBottomPadding: CGFloat = 35, description: Description, @ViewBuilder buttons: @escaping () -> Buttons, xButtonBackground: Color? = nil) {
        self.upperContent = upperContent
        self.upperContentBottomPadding = upperContentBottomPadding
        self.title = EmptyView()
        self.description = description
        self.upperBackground = upperBackground
        self.buttons = buttons
    }
}

#Preview {
    NavigationStack {
        Text("Background")
    }.sheet(isPresented: .constant(true)) {
        GamifiedBottomSheet(upperBackgroundColor: .yellow100, upperContent: VStack(spacing: 0) {
            FanfareContainer(haloColor: .yellow500, outerRingColor: .yellow500, plusColor: .yellow10) {
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
