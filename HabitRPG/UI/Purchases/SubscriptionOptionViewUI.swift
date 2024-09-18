//
//  SubscriptionOptionViewUI.swift
//  Habitica
//
//  Created by Phillip Thelen on 29.08.24.
//  Copyright © 2024 HabitRPG Inc. All rights reserved.
//
import SwiftUI

struct HourglassPromo: View {
    @State private var animatePromoGradient = false

    private var content: some View {
        let offset = animatePromoGradient ? 0.5 : -0.5
        return Group {
            Text("Get ") +
            Text("12 Mystic Hourglasses").fontWeight(.bold) +
            Text(" immediately after your first 12 month subscription!")
        }
        .font(.system(size: 15, weight: .medium))
        .foregroundColor(.teal1)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity)
        .frame(height: 65)
        .background(LinearGradient(stops: [Gradient.Stop(color: Color(hexadecimal: "77F4C7"), location: offset + 0.0),
                                           Gradient.Stop(color: Color(hexadecimal: "72CFFF"), location: offset + 1.0)],
                                   startPoint: .leading,
                                   endPoint: .trailing))
    }
    
    var body: some View {
        if #available(iOS 15.0, *) {
            content
                .task {
                    withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                        animatePromoGradient = true
                    }
                }
        } else {
            content
        }
    }
}

struct SubscriptionOptionViewUI<Price: View, Recurring: View, Tag: View>: View {
    let price: Price
    let recurring: Recurring
    let tag: Tag
    let instantGems: String
    var isGift = false
    
    var isSelected: Bool
    var nonSalePrice: String?
    var gemCapMax = false
    var showHourglassPromo = false
    
    @State var isVisible = false
    
    var selectedColor: Color {
        return nonSalePrice != nil ? Color.teal1 : .purple300
    }
        
    var body: some View {
        ZStack(alignment: .topLeading) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Group {
                                if nonSalePrice != nil {
                                    if #available(iOS 17.0, *) {
                                        if isSelected {
                                            price.foregroundStyle(
                                                LinearGradient(colors: [.blue10, .teal100], startPoint: .leading, endPoint: .trailing)
                                            )
                                        } else {
                                            price.foregroundStyle(
                                                LinearGradient(colors: [.blue100, .teal100], startPoint: .leading, endPoint: .trailing)
                                            )
                                        }
                                    } else {
                                        price
                                    }
                                } else {
                                    price
                                }
                            }.font(.system(size: 22, weight: .bold))
                            if let nonSalePrice = nonSalePrice {
                                Text(nonSalePrice).overlay {
                                    Rectangle().frame(height: 2).fill()
                                }
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(isSelected ? .gray400 : .purple600)
                            }
                        }
                        recurring.font(.system(size: 13, weight: .semibold))
                        HStack(spacing: 8) {
                            Image(Asset.plus.name).renderingMode(.template).foregroundColor(isSelected ? Color.yellow100 : .purple400)
                            Group {
                                Text(isGift ? "Unlocks " : "Unlock ") +
                                Text("\(instantGems) Gems").fontWeight(.bold).foregroundColor(isSelected ? Color.yellow5 : .white) +
                                Text(" per month instantly")
                            }.multilineTextAlignment(.leading)
                        }.font(.caption)
                            .padding(.top, 8)
                        HStack(spacing: 8) {
                            Image(Asset.plus.name).renderingMode(.template).foregroundColor(isSelected ? Color.yellow100 : .purple400)
                            if gemCapMax {
                                Group {
                                    Text("Max ") +
                                    Text("Gem Cap").fontWeight(.bold).foregroundColor(isSelected ? Color.yellow5 : .white)
                                }.multilineTextAlignment(.leading)
                            } else {
                                Group {
                                    Text(isGift ? "Earns" : "Earn ") +
                                    Text("+2 Gems").fontWeight(.bold).foregroundColor(isSelected ? Color.yellow5 : .white) +
                                    Text(isGift ? " every month they're subscribed" : " every month you're subscribed")
                                }.multilineTextAlignment(.leading)
                            }
                        }.font(.caption)
                            .padding(.top, 4)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 16)
                        .padding(.leading, 30)
                    
                    Spacer()
                    if showHourglassPromo {
                        HourglassPromo()
                    }
                }
                tag.offset(y: 16)
            }
            .frame(height: showHourglassPromo ? 186 : 126)
            .zIndex(1)
            if isSelected && isVisible {
                Image(Asset.subscriptionSelectionIndicator.name)
                    .zIndex(300)
                    .frame(width: 40, height: 40)
                    .animation(.snappy(duration: 0.2).delay(0.5))
                    .asymmetricTransition(insertion: .slide, removal: .opacity.animation(.easeInOut(duration: 0.15)))
            }
        }
        .frame(height: showHourglassPromo ? 186 : 126)
        .cornerRadius(12)
        .foregroundColor(isSelected ? selectedColor : Color.purple600)
        .padding(.vertical, 4)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

extension SubscriptionOptionViewUI where Tag == EmptyView {
    init(price: Price, recurring: Recurring, instantGems: String, isSelected: Bool, isGift: Bool = false) {
        self.init(price: price, recurring: recurring, tag: EmptyView(), instantGems: instantGems, isGift: isGift, isSelected: isSelected)
    }
}

#Preview {
    SubscriptionOptionViewUI(price: Text("$47.99"), recurring: Text(""), instantGems: "24", isSelected: true)
}
