//
//  GiftSubscriptionViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.12.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit
import ReactiveSwift
import Habitica_Models
import SwiftUI

struct GiftSubscriptionPage: View {
    @ObservedObject var viewModel: GiftSubscriptionViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let member = viewModel.giftedUser {
                    AvatarViewUI(avatar: AvatarViewModel(avatar: member), showBackground: false, showMount: false, showPet: false)
                        .frame(width: 97, height: 99)
                } else {
                    Spacer()
                        .frame(width: 97, height: 99)
                }
                Text("@\(viewModel.giftedUser?.username ?? "")").font(.system(size: 17, weight: .semibold)).padding(.bottom, 8)
                Text(L10n.giftSubscriptionPrompt)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 15)).padding(.horizontal, 32).padding(.bottom, 8)
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        ForEach(enumerating: viewModel.availableSubscriptions) { sub in
                            Rectangle()
                                .fill()
                                .foregroundColor(Color(UIColor.purple200))
                                .frame(height: 126)
                                .cornerRadius(12)
                                .padding(.vertical, 4).onTapGesture {
                                    withAnimation {
                                        viewModel.selectedSubscription = sub
                                    }
                                }
                        }
                    }
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(height: 126)
                        .cornerRadius(12)
                        .offset(y: 4.0 + (CGFloat(viewModel.availableSubscriptions.firstIndex(of: viewModel.selectedSubscription) ?? 0) * 134.0))
                        .animation(.interpolatingSpring(stiffness: 500, damping: 55), value: viewModel.selectedSubscription)
                    VStack(spacing: 0) {
                        SubscriptionOptionViewUI(price: Text(viewModel.priceFor(PurchaseHandler.noRenewSubscriptionIdentifiers[0])),
                                                 recurring: Text(viewModel.titleFor(PurchaseHandler.noRenewSubscriptionIdentifiers[0])),
                                                 instantGems: "24",
                                                 isSelected: PurchaseHandler.noRenewSubscriptionIdentifiers[0] == viewModel.selectedSubscription,
                                                 isGift: true)
                        SubscriptionOptionViewUI(price: Text(viewModel.priceFor(PurchaseHandler.noRenewSubscriptionIdentifiers[1])),
                                                 recurring: Text(viewModel.titleFor(PurchaseHandler.noRenewSubscriptionIdentifiers[1])),
                                                 instantGems: "24",
                                                 isSelected: PurchaseHandler.noRenewSubscriptionIdentifiers[1] == viewModel.selectedSubscription,
                                                 isGift: true)
                        SubscriptionOptionViewUI(price: Text(viewModel.priceFor(PurchaseHandler.noRenewSubscriptionIdentifiers[2])),
                                                 recurring: Text(viewModel.titleFor(PurchaseHandler.noRenewSubscriptionIdentifiers[2])),
                                                 instantGems: "24",
                                                 isSelected: PurchaseHandler.noRenewSubscriptionIdentifiers[2] == viewModel.selectedSubscription,
                                                 isGift: true)
                        SubscriptionOptionViewUI(price: Text(viewModel.priceFor(PurchaseHandler.noRenewSubscriptionIdentifiers[3])), recurring: Text(viewModel.titleFor(PurchaseHandler.noRenewSubscriptionIdentifiers[3])),
                                                 tag: HStack(spacing: 0) {
                            Image(uiImage: Asset.flagFlap.image.withRenderingMode(.alwaysTemplate)).foregroundColor(Color(hexadecimal: "77F4C7"))
                            Text("Popular").foregroundColor(Color(UIColor.teal1)).font(.system(size: 12, weight: .semibold))
                                .frame(height: 24)
                                .padding(.horizontal, 8)
                                .background(LinearGradient(colors: [
                                    Color(hexadecimal: "77F4C7"),
                                    Color(hexadecimal: "72CFFF")
                                ], startPoint: .leading, endPoint: .trailing))
                        },
                                                 instantGems: "50",
                                                 isGift: true, isSelected: PurchaseHandler.noRenewSubscriptionIdentifiers[3] == viewModel.selectedSubscription,
                                                 nonSalePrice: viewModel.twelveMonthNonSalePrice,
                                                 gemCapMax: true,
                                                 showHourglassPromo: false)
                    }
                }
                    .padding(.horizontal, 24)
                Group {
                    if viewModel.isSubscribing {
                        ProgressView().habiticaProgressStyle().frame(height: 48)
                    } else {
                        HabiticaButtonUI(label: Text(L10n.giftSubscription).foregroundColor(Color(UIColor.purple100)), color: Color(UIColor.yellow100), size: .compact) {
                            viewModel.subscribeToPlan()
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 32)
                Image(Asset.subscriptionBackground.name)
            }.background(Color.purple300.ignoresSafeArea(.all, edges: .top).padding(.bottom, 4))
        }.foregroundColor(.white)
            .background(Color.purple400.ignoresSafeArea(.all, edges: .bottom).padding(.top, 200))
    }
}

class GiftSubscriptionViewModel: BaseSubscriptionViewModel {
    @Published var giftedUser: MemberProtocol?
    @Published var selectedSubscription: String = PurchaseHandler.noRenewSubscriptionIdentifiers[3]
    @Published var availableSubscriptions = PurchaseHandler.noRenewSubscriptionIdentifiers

    var onSuccessfulSubscribe: (() -> Void)?
    
    override init() {
        super.init()
        retrieveProductList()
    }
    
    func retrieveProductList() {
        SwiftyStoreKit.retrieveProductsInfo(Set(PurchaseHandler.noRenewSubscriptionIdentifiers)) { (result) in
            var prices = [String: String]()
            var titles = [String: String]()
            for product in result.retrievedProducts {
                prices[product.productIdentifier] = product.localizedPrice
                titles[product.productIdentifier] = product.localizedTitle
                if product.productIdentifier == PurchaseHandler.noRenewSubscriptionIdentifiers[1] {
                    self.calculateNonSalePrice(product.price, locale: product.priceLocale)
                }
            }
            self.prices = prices
            self.titles = titles
        }
    }
    
    func subscribeToPlan() {
        if !PurchaseHandler.shared.isAllowedToMakePurchases() || isSubscribing {
            return
        }
        isSubscribing = true

        PurchaseHandler.shared.pendingGifts[selectedSubscription] = self.giftedUser?.id
        SwiftyStoreKit.purchaseProduct(selectedSubscription, atomically: false) { result in
            self.isSubscribing = false
            switch result {
            case .success(let product):
                if let action = self.onSuccessfulSubscribe {
                    action()
                }
                logger.log("Purchase Success: \(product.productId)")
            case .error(let error):
                logger.log("Purchase Failed: \(error)", level: .error)
            case .deferred:
                return
            }
        }
    }
}

class GiftSubscriptionViewController: UIHostingController<GiftSubscriptionPage> {
    let viewModel: GiftSubscriptionViewModel = GiftSubscriptionViewModel()
    
    private let socialRepository = SocialRepository()
    private let userRepository = UserRepository()
    private let configRepository = ConfigRepository.shared
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    private var activePromo: HabiticaPromotion?

    public var giftRecipientUsername: String?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: GiftSubscriptionPage(viewModel: viewModel))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let username = giftRecipientUsername {
            let signal: Signal<MemberProtocol?, Never>
            if UUID(uuidString: username) != nil {
                signal = socialRepository.retrieveMember(userID: username)
            } else {
                signal = socialRepository.retrieveMemberWithUsername(username)
            }
            disposable.inner.add(signal.observeValues({[weak self] member in
                self?.viewModel.giftedUser = member
            }))
        }

        activePromo = configRepository.activePromotion()
        
        view.backgroundColor = .purple300
        navigationController?.navigationBar.backgroundColor = .purple300
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.barTintColor = .purple300
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        viewModel.onSuccessfulSubscribe = {[weak self] in
            self?.displayConfirmationDialog()
        }
    }

    private func selectedDurationString() -> String {
        switch viewModel.selectedSubscription {
        case PurchaseHandler.noRenewSubscriptionIdentifiers[0]:
            return "1"
        case PurchaseHandler.noRenewSubscriptionIdentifiers[1]:
            return "3"
        case PurchaseHandler.noRenewSubscriptionIdentifiers[2]:
            return "6"
        case PurchaseHandler.noRenewSubscriptionIdentifiers[3]:
            return "12"
        default:
            return ""
        }
    }
    
    func displayConfirmationDialog() {
        var body = L10n.giftConfirmationBody(viewModel.giftedUser?.profile?.name ?? "", selectedDurationString())
        if activePromo?.identifier == "g1g1" {
            body = L10n.giftConfirmationBodyG1g1(viewModel.giftedUser?.profile?.name ?? "", selectedDurationString())
        }
        let alertController = HabiticaAlertController(title: L10n.giftConfirmationTitle, message: body)
        alertController.addCloseAction { _ in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                self.performSegue(withIdentifier: "unwindToList", sender: self)
            }
        }
        alertController.show()
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
