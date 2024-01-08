//
//  SubscriptionPage.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.11.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftyStoreKit
import FirebaseAnalytics
import ReactiveSwift
import Habitica_Models
import SwiftUIX

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
    let bubbleTexts: [String]
    
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
                    HStack(spacing: 4) {
                        ForEach(enumerating: bubbleTexts) { bubbleText in
                            Text(bubbleText)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color(isSelected ? UIColor.purple400 : UIColor.purple100))
                                .cornerRadius(16, style: .continuous)
                        }.foregroundColor(Color(isSelected ? UIColor.white : UIColor.purple600))
                            .font(.system(size: 12))
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            tag.offset(y: 10)
        }
        .frame(height: 106)
        .cornerRadius(12)
        .foregroundColor(Color(isSelected ? UIColor.purple300 : UIColor.purple600))
        .padding(.vertical, 3)
    }
}

extension SubscriptionOptionViewUI where Tag == EmptyView {
    init(price: Price, recurring: Recurring, bubbleTexts: [String], isSelected: Bool) {
        self.init(price: price, recurring: recurring, tag: EmptyView(), bubbleTexts: bubbleTexts, isSelected: isSelected)
    }
}

struct SubscriptionOptionStack: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.presentationPoint != .timetravelers {
                SubscriptionOptionViewUI(price: Text(viewModel.priceFor(PurchaseHandler.subscriptionIdentifiers[0])),
                                         recurring: Text(L10n.subscriptionDuration(L10n.month)),
                                         bubbleTexts: [L10n.xGemsMonth(25), L10n.hourglassInXMonths(3)],
                                         isSelected: PurchaseHandler.subscriptionIdentifiers[0] == viewModel.selectedSubscription)
            }
            SubscriptionOptionViewUI(price: Text(viewModel.priceFor(PurchaseHandler.subscriptionIdentifiers[1])),
                                     recurring: Text(L10n.subscriptionDuration(L10n.xMonths(3))),
                                     bubbleTexts: [L10n.xGemsMonth(30), L10n._1Hourglass],
                                     isSelected: PurchaseHandler.subscriptionIdentifiers[1] == viewModel.selectedSubscription)
            if viewModel.presentationPoint == nil {
                SubscriptionOptionViewUI(price: Text(viewModel.priceFor(PurchaseHandler.subscriptionIdentifiers[2])),
                                         recurring: Text(L10n.subscriptionDuration(L10n.xMonths(6))),
                                         bubbleTexts: [L10n.xGemsMonth(35), L10n.xHourglasses(2)],
                                         isSelected: PurchaseHandler.subscriptionIdentifiers[2] == viewModel.selectedSubscription)
            }
            SubscriptionOptionViewUI(price: Text(viewModel.priceFor(PurchaseHandler.subscriptionIdentifiers[3])), recurring: Text(L10n.subscriptionDuration(L10n.xMonths(12))),
                                     tag: HStack(spacing: 0) {
                Image(uiImage: Asset.flagFlap.image.withRenderingMode(.alwaysTemplate)).foregroundColor(Color(hexadecimal: "77F4C7"))
                Text("Save 20%").foregroundColor(Color(UIColor.teal1)).font(.system(size: 12, weight: .semibold))
                    .frame(height: 24)
                    .padding(.horizontal, 4)
                    .background(LinearGradient(colors: [
                        Color(hexadecimal: "77F4C7"),
                        Color(hexadecimal: "72CFFF")
                ], startPoint: .leading, endPoint: .trailing))
            },
                                     bubbleTexts: [L10n.xGemsMonth(45), L10n.xHourglasses(4)],
                                     isSelected: PurchaseHandler.subscriptionIdentifiers[3] == viewModel.selectedSubscription)
        }
    }
}

class SubscriptionViewModel: ObservableObject {
    private let disposable = ScopedDisposable(CompositeDisposable())

    let appleValidator: AppleReceiptValidator
    let itunesSharedSecret = Secrets.itunesSharedSecret
    let userRepository = UserRepository()
    let inventoryRepository = InventoryRepository()
    
    var onSubscriptionSuccessful: (() -> Void)?
    
    @Published var presentationPoint: PresentationPoint?
    @Published var isSubscribed: Bool = false
    @Published var prices = [String: String]()
    @Published var mysteryGear: GearProtocol?
    
    @Published var isSubscribing = false
    @Published var selectedSubscription: String = PurchaseHandler.subscriptionIdentifiers[0]
    @Published var availableSubscriptions = PurchaseHandler.subscriptionIdentifiers
    
    init(presentationPoint: PresentationPoint?) {
        #if DEBUG
            appleValidator = AppleReceiptValidator(service: .production, sharedSecret: itunesSharedSecret)
        #else
            appleValidator = AppleReceiptValidator(service: .production, sharedSecret: itunesSharedSecret)
        #endif
        self.presentationPoint = presentationPoint
        
        if presentationPoint != nil {
            availableSubscriptions.remove(at: 2)
        }
        if presentationPoint == .timetravelers {
            availableSubscriptions.remove(at: 0)
            selectedSubscription = PurchaseHandler.subscriptionIdentifiers[1]
        }
        
        disposable.inner.add(inventoryRepository.getLatestMysteryGear().on(value: { gear in
            self.mysteryGear = gear
        }).start())
        
        retrieveProductList()
    }
    
    func retrieveProductList() {
        SwiftyStoreKit.retrieveProductsInfo(Set(PurchaseHandler.subscriptionIdentifiers)) { (result) in
            var prices = [String: String]()
            for product in result.retrievedProducts {
                prices[product.productIdentifier] = product.localizedPrice
            }
            self.prices = prices
        }
    }
    
    func priceFor(_ identifier: String) -> String {
        return prices[identifier] ?? ""
    }
    
    func subscribeTapped() {
        if !PurchaseHandler.shared.isAllowedToMakePurchases() {
            return
        }
        isSubscribing = true
        SwiftyStoreKit.purchaseProduct(selectedSubscription, atomically: false) { result in
            self.isSubscribing = false
            switch result {
            case .success(let product):
                self.verifyAndSubscribe(product)
                logger.log("Purchase Success: \(product.productId)")
            case .error(let error):
                Analytics.logEvent("purchase_failed", parameters: ["error": error.localizedDescription, "code": error.errorCode])

                logger.log("Purchase Failed: \(error)", level: .error)
            case .deferred:
                return
            }
        }
    }
    
    func verifyAndSubscribe(_ product: PurchaseDetails) {
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: true) { result in
            switch result {
            case .success(let receipt):
                // Verify the purchase of a Subscription
                if self.isValidSubscription(product.productId, receipt: receipt) {
                    self.activateSubscription(product.productId, receipt: receipt) { status in
                        if status {
                            if product.needsFinishTransaction {
                                SwiftyStoreKit.finishTransaction(product.transaction)
                            }
                        }
                        self.dismiss()
                    }
                }
            case .error(let error):
                logger.log("Receipt verification failed: \(error)", level: .error)
            }
        }
    }
    
    private func dismiss() {
        if let action = self.onSubscriptionSuccessful {
            action()
        }
    }
    
    func isSubscription(_ identifier: String) -> Bool {
        return  PurchaseHandler.subscriptionIdentifiers.contains(identifier)
    }

    func isValidSubscription(_ identifier: String, receipt: ReceiptInfo) -> Bool {
        if !isSubscription(identifier) {
            return false
        }
        let purchaseResult = SwiftyStoreKit.verifySubscription(
            ofType: .autoRenewable,
            productId: identifier,
            inReceipt: receipt,
            validUntil: Date()
        )
        switch purchaseResult {
        case .purchased:
            return true
        case .expired:
            return false
        case .notPurchased:
            return false
        }
    }
    
    func activateSubscription(_ identifier: String, receipt: ReceiptInfo, completion: @escaping (Bool) -> Void) {
        if let lastReceipt = receipt["latest_receipt"] as? String {
            userRepository.subscribe(sku: identifier, receipt: lastReceipt).observeResult { (result) in
                switch result {
                case .success:
                    completion(true)
                    self.isSubscribed = true
                case .failure:
                    completion(false)
                }
            }
        }
    }
}

struct SubscriptionPage: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    
    var backgroundColor: Color = Color(UIColor.purple300)
    var textColor: Color = .white
    
    var body: some View {
            LazyVStack(spacing: 0) {
                if let point = viewModel.presentationPoint {
                    Text(point.headerText)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 17, weight: .semibold))
                } else {
                    if viewModel.isSubscribed {
                        Image(backgroundColor.uiColor().isLight() ? Asset.subscriberHeader.name : Asset.subscriberHeaderDark.name)
                    } else {
                        Image(backgroundColor.uiColor().isLight() ? Asset.subscribeHeader.name : Asset.subscribeHeaderDark.name)
                    }
                }
                HStack(spacing: 20) {
                    Rectangle().fill().frame(maxWidth: .infinity).height(1)
                    Image(Asset.separatorFancyIcon.name).padding(.vertical, 20)
                    Rectangle().fill().frame(maxWidth: .infinity).height(1)
                }.foregroundColor(Color(UIColor.purple400))
                if viewModel.presentationPoint != .gemForGold {
                    SubscriptionBenefitView(icon: Image(Asset.subBenefitsGems.name), title: Text(L10n.subscriptionInfo1Title), description: Text(L10n.subscriptionInfo1Description))
                }
                if viewModel.presentationPoint != .armoire {
                    SubscriptionBenefitView(icon: Image(Asset.subBenefitsArmoire.name), title: Text(L10n.Subscription.infoArmoireTitle), description: Text(L10n.Subscription.infoArmoireDescription))
                }
                if viewModel.presentationPoint != .timetravelers {
                    SubscriptionBenefitView(icon: Image(Asset.subBenefitsHourglasses.name), title: Text(L10n.subscriptionInfo2Title), description: Text(L10n.subscriptionInfo2Description))
                }
                SubscriptionBenefitView(icon: PixelArtView(name: "shop_set_mystery_\(viewModel.mysteryGear?.key?.split(separator: "_").last ?? "")"), title: Text(L10n.subscriptionInfo3Title), description: Text(L10n.subscriptionInfo3Description))
                if viewModel.presentationPoint != .faint {
                    SubscriptionBenefitView(icon: Image(Asset.subBenefitsFaint.name), title: Text(L10n.Subscription.infoFaintTitle), description: Text(L10n.Subscription.infoFaintDescription))
                }
                SubscriptionBenefitView(icon: Image(Asset.subBenefitsPet.name), title: Text(L10n.subscriptionInfo4Title), description: Text(L10n.subscriptionInfo4Description))
                SubscriptionBenefitView(icon: Image(Asset.subBenefitDrops.name), title: Text(L10n.subscriptionInfo5Title), description: Text(L10n.subscriptionInfo5Description)).padding(.bottom, 20)
                
                if !viewModel.isSubscribed {
                    ZStack(alignment: .top) {
                        VStack(spacing: 0) {
                            ForEach(enumerating: viewModel.availableSubscriptions) { sub in
                                Rectangle()
                                    .fill()
                                    .foregroundColor(Color(UIColor.purple200))
                                    .frame(height: 106)
                                    .cornerRadius(12)
                                    .padding(.vertical, 3).onTapGesture {
                                        withAnimation {
                                            viewModel.selectedSubscription = sub
                                        }
                                    }
                            }
                        }
                        Rectangle()
                            .frame(height: 106)
                            .cornerRadius(12)
                            .offset(y: 3.0 + (CGFloat(viewModel.availableSubscriptions.firstIndex(of: viewModel.selectedSubscription) ?? 0) * 112.0))
                            .animation(.interpolatingSpring(stiffness: 500, damping: 25), value: viewModel.selectedSubscription)
                        SubscriptionOptionStack(viewModel: viewModel)
                    }
                }
                Group {
                    if viewModel.isSubscribing {
                        ProgressView().habiticaProgressStyle().frame(height: 48)
                    } else {
                        HabiticaButtonUI(label: Text(L10n.subscribe).foregroundColor(Color(UIColor.purple100)), color: Color(UIColor.yellow100), size: .compact) {
                            viewModel.subscribeTapped()
                        }
                    }
                }.padding(.vertical, 13)
                Text(L10n.subscriptionSupportDevelopers).foregroundColor(Color(UIColor.purple600)).font(.system(size: 15)).multilineTextAlignment(.center)
                
                HStack(spacing: 20) {
                    Rectangle().fill().frame(maxWidth: .infinity).height(1)
                    Image(Asset.separatorFancyIcon.name)
                    Rectangle().fill().frame(maxWidth: .infinity).height(1)
                }.foregroundColor(Color(UIColor.purple400))
                    .padding(.vertical, 20)
                Text("Once we’ve confirmed your purchase, the payment will be charged to your Apple ID.\n\nSubscriptions automatically renew unless auto-renewal is turned off at least 24-hours before the end of the current period. You can manage subscription renewal from your Apple ID Settings. If you have an active subscription, your account will be charged for renewal within 24-hours prior to the end of your current subscription period and you will be charged the same price you initially paid.")
                    .font(.system(size: 11))
                    .foregroundColor(Color(UIColor.gray500))
                HStack(spacing: 0) {
                    Text("By continuing you accept the ")
                    // swiftlint:disable force_unwrapping
                    Link("Terms of Use", destination: URL(string: "https://habitica.com/static/terms")!).font(.system(size: 11, weight: .semibold)).foregroundColor(Color(UIColor.purple600))
                    Text(" and ")
                    Link("Privacy Policy", destination: URL(string: "https://habitica.com/static/privacy")!).font(.system(size: 11, weight: .semibold)).foregroundColor(Color(UIColor.purple600))
                }
                .font(.system(size: 11))
                    .foregroundColor(Color(UIColor.gray500))
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundColor(textColor)
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
            .padding(.top, 16)
            .background(backgroundColor.ignoresSafeArea())
        .background(backgroundColor)
        .cornerRadius([.topLeading, .topTrailing], 12)
    }
}

struct SubscriptionPagePreview: PreviewProvider {
    static var previews: some View {
        SubscriptionPage(viewModel: SubscriptionViewModel(presentationPoint: nil))
        SubscriptionPage(viewModel: SubscriptionViewModel(presentationPoint: nil)).previewDisplayName("Subscribed")
        SubscriptionPage(viewModel: SubscriptionViewModel(presentationPoint: .armoire)).previewDisplayName("Armoire")
        SubscriptionPage(viewModel: SubscriptionViewModel(presentationPoint: .faint)).previewDisplayName("Faint")
        SubscriptionPage(viewModel: SubscriptionViewModel(presentationPoint: .gemForGold)).previewDisplayName("Gem for Gold")
        SubscriptionPage(viewModel: SubscriptionViewModel(presentationPoint: .timetravelers)).previewDisplayName("Time Travelers")
    }
}

class SubscriptionModalViewController: HostingPanModal<SubscriptionPage> {
    let viewModel: SubscriptionViewModel
    let userRepository = UserRepository()
    
    init(presentationPoint: PresentationPoint?) {
        viewModel = SubscriptionViewModel(presentationPoint: presentationPoint)
        super.init(nibName: nil, bundle: nil)
        viewModel.onSubscriptionSuccessful = {
            self.dismiss()
        }
        
        switch presentationPoint {
        case .faint:
            HabiticaAnalytics.shared.log("View death sub CTA")
        case .armoire:
            HabiticaAnalytics.shared.log("View armoire sub CTA")
        case .gemForGold:
            HabiticaAnalytics.shared.log("View gems for gold CTA")
        case .timetravelers:
            return
        case .none:
            return
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        viewModel = SubscriptionViewModel(presentationPoint: nil)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        hostingView = UIHostingView(rootView: SubscriptionPage(viewModel: viewModel))
        super.viewDidLoad()
        view.backgroundColor = .purple300
        scrollView.backgroundColor = .purple300
        
        userRepository.getUser().on(value: {[weak self] user in
            self?.viewModel.isSubscribed = user.isSubscribed
        }).start()
    }
}
