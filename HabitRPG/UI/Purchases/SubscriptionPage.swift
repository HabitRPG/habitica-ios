//
//  SubscriptionPage.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.11.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import Foundation
import SwiftUI

enum PresentationPoint {
    case armoire
    case faint
    case timetravelers
    case gemForGold
    
    var headerText: String {
        switch self {
        case .armoire: 
            return L10n.Subscription.armoreHeader
        case .faint:
            return L10n.Subscription.faintHeader
        case .gemForGold:
            return L10n.Subscription.gemForGoldHeader
        case .timetravelers:
            return L10n.Subscription.hourglassesHeader
        }
    }
}

struct SubscriptionBenefitView<Icon: View, Title: View, Description: View>: View {
    let icon: Icon
    let title: Title
    let description: Description
    
    var body: some View {
        HStack(spacing: 12) {
            icon
                .frame(width: 68, height: 68)
                .background(Color(UIColor.purple200))
                .cornerRadius(8)
            VStack(alignment: .leading, spacing: 4) {
                title.font(.system(size: 15, weight: .semibold))
                description.font(.system(size: 13))
            }.frame(maxWidth: .infinity, alignment: .leading)
        }.padding(.horizontal, 16)
            .padding(.vertical, 6)
    }
}

struct SubscriptionOptionViewUI<Price: View, Recurring: View, Tag: View>: View {
    let price: Price
    let recurring: Recurring
    let tag: Tag
    
    var isSelected: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack {
                ZStack {
                    Circle().stroke(lineWidth: 3)
                    if isSelected {
                        Circle().fill().frame(width: 12, height: 12).transition(.scale)
                            .animation(.interpolatingSpring(stiffness: 500, damping: 25), value: isSelected)
                    }
                }
                .foregroundColor(Color(UIColor.purple400))
                .frame(width: 20, height: 20)
                .padding(.leading, 8)
                .padding(.trailing, 24)
                VStack(alignment: .leading, spacing: 4) {
                    price.font(.system(size: 20, weight: .semibold))
                    recurring.font(.system(size: 13, weight: .semibold))
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            tag.offset(y: 10)
        }
        .frame(height: 106)
        .cornerRadius(12)
        .foregroundColor(Color(isSelected ? UIColor.purple300 : UIColor.purple600))
        .padding(.vertical, 3)
        .animation(.interpolatingSpring)
    }
}

extension SubscriptionOptionViewUI where Tag == EmptyView {
    init(price: Price, recurring: Recurring, isSelected: Bool) {
        self.init(price: price, recurring: recurring, tag: EmptyView(), isSelected: isSelected)
    }
}

struct SubscriptionPage: View {
    var presentationPoint: PresentationPoint?
    var isSubscribed: Bool = false
    
    var backgroundColor: Color = Color(UIColor.purple300)
    var textColor: Color = .white
    
    @State var selectedSubscription: String = PurchaseHandler.subscriptionIdentifiers[0]
    @State var availableSubscriptions = PurchaseHandler.subscriptionIdentifiers
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if let point = presentationPoint {
                    Text(point.headerText)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 20, weight: .semibold))
                } else {
                    if isSubscribed {
                        Image(backgroundColor.uiColor().isLight() ? Asset.subscriberHeader.name : Asset.subscriberHeaderDark.name)
                    } else {
                        Image(backgroundColor.uiColor().isLight() ? Asset.subscribeHeader.name : Asset.subscribeHeaderDark.name)
                    }
                }
                Image(Asset.separatorFancy.name).padding(.vertical, 20)
                if presentationPoint != .gemForGold {
                    SubscriptionBenefitView(icon: Image(Asset.subBenefitsGems.name), title: Text(L10n.subscriptionInfo1Title), description: Text(L10n.subscriptionInfo1Description))
                }
                if presentationPoint != .armoire {
                    SubscriptionBenefitView(icon: Image(Asset.subBenefitsArmoire.name), title: Text(L10n.Subscription.infoArmoireTitle), description: Text(L10n.Subscription.infoArmoireDescription))
                }
                if presentationPoint != .timetravelers {
                    SubscriptionBenefitView(icon: Image(Asset.subBenefitsHourglasses.name), title: Text(L10n.subscriptionInfo2Title), description: Text(L10n.subscriptionInfo2Description))
                }
                SubscriptionBenefitView(icon: Image(Asset.subBenefitsHourglasses.name), title: Text(L10n.subscriptionInfo3Title), description: Text(L10n.subscriptionInfo3Description))
                if presentationPoint != .faint {
                    SubscriptionBenefitView(icon: Image(Asset.subBenefitsFaint.name), title: Text(L10n.Subscription.infoFaintTitle), description: Text(L10n.Subscription.infoFaintDescription))
                }
                SubscriptionBenefitView(icon: Image(Asset.subBenefitsPet.name), title: Text(L10n.subscriptionInfo4Title), description: Text(L10n.subscriptionInfo4Description))
                SubscriptionBenefitView(icon: Image(Asset.subBenefitDrops.name), title: Text(L10n.subscriptionInfo5Title), description: Text(L10n.subscriptionInfo5Description)).padding(.bottom, 20)
                
                if !isSubscribed {
                    ZStack(alignment: .top) {
                        VStack(spacing: 0) {
                            ForEach(enumerating: availableSubscriptions) { sub in
                                Rectangle()
                                    .fill()
                                    .foregroundColor(Color(UIColor.purple200))
                                    .frame(height: 106)
                                    .cornerRadius(12)
                                    .padding(.vertical, 3).onTapGesture {
                                        withAnimation {
                                            selectedSubscription = sub
                                        }
                                    }
                            }
                        }
                        Rectangle()
                            .frame(height: 106)
                            .cornerRadius(12)
                            .offset(y: 3.0 + (CGFloat(availableSubscriptions.firstIndex(of: selectedSubscription) ?? 0) * 112.0))
                            .animation(.interpolatingSpring(stiffness: 500, damping: 25), value: selectedSubscription)
                        VStack(spacing: 0) {
                            if presentationPoint != .timetravelers {
                                SubscriptionOptionViewUI(price: Text("$4.99"), recurring: Text(L10n.subscriptionDuration(L10n.month)),
                                                         isSelected: PurchaseHandler.subscriptionIdentifiers[0] == selectedSubscription)
                            }
                            SubscriptionOptionViewUI(price: Text("$14.99"), recurring: Text(L10n.subscriptionDuration(L10n.xMonths(3))),
                                                     isSelected: PurchaseHandler.subscriptionIdentifiers[1] == selectedSubscription)
                            if presentationPoint == nil {
                                SubscriptionOptionViewUI(price: Text("$29.99"), recurring: Text(L10n.subscriptionDuration(L10n.xMonths(6))),
                                                         isSelected: PurchaseHandler.subscriptionIdentifiers[2] == selectedSubscription)
                            }
                            SubscriptionOptionViewUI(price: Text("$47.99"), recurring: Text(L10n.subscriptionDuration(L10n.xMonths(12))),
                                                     tag: HStack(spacing: 0) {
                                Image(uiImage: Asset.flagFlap.image.withRenderingMode(.alwaysTemplate)).foregroundColor(Color(hexadecimal: "77F4C7"))
                                Text("Save 20%").foregroundColor(Color(UIColor.teal1)).font(.system(size: 12, weight: .semibold))
                                    .frame(height: 24)
                                    .padding(.horizontal, 4)
                                    .background(LinearGradient(colors: [
                                        Color(hexadecimal: "77F4C7"),
                                        Color(hexadecimal: "72CFFF")
                                ], startPoint: .leading, endPoint: .trailing))
                            }, isSelected: PurchaseHandler.subscriptionIdentifiers[3] == selectedSubscription)
                        }
                    }
                }
                HabiticaButtonUI(label: Text(L10n.subscribe).foregroundColor(Color(UIColor.purple100)), color: Color(UIColor.yellow100), size: .compact) {
                    
                }.padding(.vertical, 13)
                Text(L10n.subscriptionSupportDevelopers).foregroundColor(Color(UIColor.purple600)).font(.system(size: 15)).multilineTextAlignment(.center)
                Image(Asset.separatorFancy.name).padding(.vertical, 20)
                GeometryReader { reader in
                    DisclaimerView(fixedWidth: reader.size.width)
                }.frame(height: 160)
            }
            .foregroundColor(textColor)
            .padding(.horizontal, 20)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(backgroundColor.ignoresSafeArea())
        .onAppear {
            if presentationPoint != nil {
                availableSubscriptions.remove(at: 2)
            }
            if presentationPoint == .timetravelers {
                availableSubscriptions.remove(at: 0)
                selectedSubscription = PurchaseHandler.subscriptionIdentifiers[1]
            }
        }
    }
}

struct DisclaimerView: UIViewRepresentable {

    var fixedWidth = 0.0
    func makeUIView(context: UIViewRepresentableContext<DisclaimerView>) -> UITextView {
        let label = UITextView()
        let termsAttributedText = NSMutableAttributedString(string: "Once we’ve confirmed your purchase, the payment will be charged to your Apple ID.\n\nSubscriptions automatically renew unless auto-renewal is turned off at least 24-hours before the end of the current period. You can manage subscription renewal from your Apple ID Settings. If you have an active subscription, your account will be charged for renewal within 24-hours prior to the end of your current subscription period and you will be charged the same price you initially paid.\n\nBy continuing you accept the Terms of Use and Privacy Policy.")
        termsAttributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray500, range: NSRange(location: 0, length: termsAttributedText.length))
        termsAttributedText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 11), range: NSRange(location: 0, length: termsAttributedText.length))
        let termsRange = termsAttributedText.mutableString.range(of: "Terms of Use")
        termsAttributedText.addAttributes([NSAttributedString.Key.link: "https://habitica.com/static/terms"], range: termsRange)
        let privacyRange = termsAttributedText.mutableString.range(of: "Privacy Policy")
        termsAttributedText.addAttributes([NSAttributedString.Key.link: "https://habitica.com/static/privacy"], range: privacyRange)
        label.attributedText = termsAttributedText
        label.isSelectable = false
        label.isUserInteractionEnabled = false
        label.isScrollEnabled = false
        label.backgroundColor = .clear
        label.linkTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.purple500
        ]
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalToConstant: fixedWidth).isActive = true
        return label
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<DisclaimerView>) { }
}

struct SubscriptionPagePreview: PreviewProvider {
    static var previews: some View {
        SubscriptionPage()
        SubscriptionPage(isSubscribed: true).previewDisplayName("Subscribed")
        SubscriptionPage(presentationPoint: .armoire).previewDisplayName("Armoire")
        SubscriptionPage(presentationPoint: .faint).previewDisplayName("Faint")
        SubscriptionPage(presentationPoint: .gemForGold).previewDisplayName("Gem for Gold")
        SubscriptionPage(presentationPoint: .timetravelers).previewDisplayName("Time Travelers")
    }
}

class SubscriptionModalViewController: HostingBottomSheetController<SubscriptionPage> {
    
}
