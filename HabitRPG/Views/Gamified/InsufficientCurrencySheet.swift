//
//  InsufficientCurrencySheet.swift
//  Habitica
//
//  Created by Phillip Thelen on 19.11.25.
//  Copyright © 2025 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import SwiftyStoreKit

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
                ArmoirePlus(thickness: 4, length: 9, maxSpacing: 3, color: plusColor)
                    .offset(x: 80, y: 55)
            }
            title
                .scaledFont(size: 22, weight: .bold)
                .foregroundStyle(.white)
                .padding(.horizontal, 50)
        }.padding(.top, 50), description: content.frame(maxWidth: 320), buttons: buttons)
    }
}

struct InsufficientGemsSheet: View {
    @Environment(\.presentationManager)
    var presentationManager
    
    @State var price: String = ""

    var body: some View {
        InsufficientCurrencySheet(backgroundColor: .purple400,
                                              circleColor: .purple100,
                                              ringColor: .purple300,
                                              plusColor: .purple500,
                                              icon: Image(Asset.insufficientGems.name),
                                              title: Text(L10n.moreGemsMessage),
                                              content: Text(L10n.gemsSupportDevelopers)) {
            HabiticaButtonUI(label: Text(price.isEmpty ? L10n.loading : L10n.xGemsForY(4, price)), color: Color(ThemeService.shared.theme.tintColor)) {
                presentationManager.dismiss()
                RouterHandler.shared.handle(.purchaseGems)
            }.disabled(price.isEmpty)
            HabiticaButtonUI(label: Text(L10n.moreGemPacks).foregroundStyle(Color(ThemeService.shared.theme.primaryTextColor)), color: Color(ThemeService.shared.theme.windowBackgroundColor)) {
                presentationManager.dismiss()
                RouterHandler.shared.handle(.purchaseGems)
            }
        }.task {
            SwiftyStoreKit.retrieveProductsInfo(Set([PurchaseHandler.IAPIdentifiers[0]])) { (result) in
                if let product = result.retrievedProducts.first, let price = product.localizedPrice {
                    self.price = price
                }
            }
        }
    }
}

struct InsufficientHourglassesSheet: View {
    @Environment(\.presentationManager)
    var presentationManager
    
    let isSubscribed: Bool

    var body: some View {
        InsufficientCurrencySheet(backgroundColor: .blue100,
                                              circleColor: Color(ThemeService.shared.theme.contentBackgroundColor),
                                              ringColor: .blue500,
                                              plusColor: .blue10,
                                              icon: Image(Asset.insufficientHourglasses.name),
                                              title: Text(L10n.notEnoughHourglasses),
                                              content: Text(isSubscribed ? L10n.insufficientHourglassesMessageSubscriber : L10n.insufficientHourglassesMessage)) {
            HabiticaButtonUI(label: Text(L10n.learnMore), color: Color(ThemeService.shared.theme.tintColor)) {
                presentationManager.dismiss()
                RouterHandler.shared.handle(.subscription)
            }
        }
    }
}
