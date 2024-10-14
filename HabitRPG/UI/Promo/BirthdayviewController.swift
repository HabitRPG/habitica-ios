//
//  BirthdayviewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 05.01.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import Foundation
import SwiftUI
import Kingfisher
import SwiftyStoreKit
import StoreKit
import ReactiveSwift

private struct BirthdaySection<Title: View, Content: View>: View {
    let title: Title
    @ViewBuilder
    let content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Rectangle()
                    .foregroundColor(.purple50)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                Image(Asset.birthdayTextdeco.name)
                title.font(.system(size: 17, weight: .bold))
                    .fixedSize()
                    .padding(.horizontal, 20)
                Image(Asset.birthdayTextdeco.name)
                    .scaleEffect(x: -1)
                Rectangle()
                    .foregroundColor(.purple50)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
            }.padding(.top, 20)
                .padding(.bottom, 8)
            content
        }.ignoresSafeArea()
            .padding(.horizontal, 20)
    }
}

private struct PotionGrid: View {
    let potions = ["Porcelain",
                   "Vampire",
                   "Aquatic",
                   "StainedGlass",
                   "Celestial",
                   "Glow",
                   "AutumnLeaf",
                   "SandSculpture",
                   "Peppermint",
                   "Shimmer"]

    var body: some View {
        LazyVGrid(columns: [.init(.adaptive(minimum: 68))], alignment: .center) {
            ForEach(potions, id: \.self) { potion in
                PixelArtView(name: "Pet_HatchingPotion_\(potion)")
                    .frame(width: 68, height: 68)
                    .background(Color.purple50)
                    .cornerRadius(8)
            }
        }
    }
}

private struct FourFreeView: View {
    let title: String
    let day: Int
    var imageName: String?
    var image: UIImage?
    
    var body: some View {
        VStack {
            Text(L10n.dayX(day).uppercased())
                .foregroundColor(.yellow50)
                .font(.system(size: 12, weight: .bold))
            Group {
                if let image = image {
                    Image(uiImage: image)
                } else if let imageName = imageName {
                    PixelArtView(name: imageName)
                }
            }
                .frame(width: 121, height: 84)
                .background(.purple100)
                .cornerRadius(4)
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 15))
        }
        .width(153)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(.purple50)
        .cornerRadius(8)
    }
}

struct BirthdayView: View {
    private let dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    private let complexDateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        return formatter
    }()
    @ObservedObject var viewModel: BirthdayViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(alignment: .center) {
                    Button {
                        viewModel.dismiss()
                    } label: {
                        Text(L10n.done).foregroundColor(.white).font(.headline)
                    }.frame(maxWidth: .infinity, alignment: .trailing).padding(.trailing, 20)

                    Image(uiImage: Asset.birthdayHeader.image).resizable(false)
                    HStack {
                        Image(Asset.birthdayGifts.name)
                        VStack {
                            Text(L10n.limitedEvent.uppercased())
                                .foregroundColor(Color.yellow50)
                                .font(.system(size: 12, weight: .bold))
                            Text(L10n.xToY("\(dateFormatter.string(from: viewModel.startDate))", "\(dateFormatter.string(from: viewModel.endDate))"))
                                .font(.system(size: 12, weight: .bold))
                        }.padding(.horizontal, 20)
                        Image(Asset.birthdayGifts.name)
                            .scaleEffect(x: -1)
                    }
                    BirthdaySection(title: Text(L10n.jubilantGryphatrice)) {
                        Group {
                            KFAnimatedImage(ImageManager.buildImageUrl(name: "stable_Pet-Gryphatrice-Jubilant"))
                                .frame(width: 104, height: 104)
                        }
                        .frame(width: 161, height: 129)
                        .background(Color.purple50)
                        .cornerRadius(8)
                        .padding(.top, 12)
                        Text(L10n.limitedEdition.uppercased())
                            .foregroundColor(.yellow50)
                            .font(.system(size: 12, weight: .bold))
                            .padding(.top, 17)
                        Text(L10n.gryphatriceDescription)
                            .font(.system(size: 15))
                            .lineSpacing(3)
                            .padding(.top, 4)
                        if viewModel.ownsGryphatrice {
                            Text(L10n.thanksForYourSupport)
                                .font(.system(size: 15, weight: .semibold))
                                .padding(.vertical, 20)
                            HabiticaButtonUI(label: Text(L10n.equip), color: .white, size: .compact) {
                                viewModel.equip()
                            }
                        } else {
                            Text(L10n.ownTodayFor(viewModel.price, viewModel.gemPrice))
                                .font(.system(size: 15, weight: .semibold))
                                .padding(.vertical, 20)
                            if viewModel.isPurchasing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                HabiticaButtonUI(label: Text(L10n.buyForX(viewModel.price)), color: .white, size: .compact) {
                                    viewModel.purchaseAsIAP()
                                }.padding(.bottom, 20)
                                HabiticaButtonUI(label: HStack {
                                    Text(L10n.buyFor)
                                    Image(Asset.gem.name)
                                    Text("\(viewModel.gemPrice)")
                                }, color: .white, size: .compact) {
                                    viewModel.purchaseWithGems()
                                }
                            }
                        }
                    }
                    BirthdaySection(title: Text(L10n.plentyOfPotions)) {
                        Text(L10n.plentyOfPotionsDescription)
                            .font(.system(size: 15))
                            .lineSpacing(3)
                            .padding(.bottom, 20)
                        PotionGrid()
                            .padding(.bottom, 12)
                        HabiticaButtonUI(label: Text(L10n.visitTheMarket), color: .white, size: .compact) {
                            viewModel.openMarket()
                        }
                    }
                    BirthdaySection(title: Text(L10n.fourForFree)) {
                        Text(L10n.fourForFreeDescription)
                            .font(.system(size: 15))
                            .lineSpacing(3)
                        HStack(spacing: 16) {
                            FourFreeView(title: L10n.partyRobe, day: 1, imageName: "birthday10_robes")
                            FourFreeView(title: L10n.xGems(20), day: 1, image: Asset.birthdayGems.image)
                        }
                        .padding(.vertical, 16)
                        HStack(spacing: 16) {
                            FourFreeView(title: L10n.birthdaySet, day: 5, imageName: "birthday10_hero")
                            FourFreeView(title: L10n.background, day: 10, imageName: "birthday10_background")
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 30)
                .background(LinearGradient(colors: [Color.purple300, Color.purple200], startPoint: .top, endPoint: .bottom))
                VStack(spacing: 7) {
                    Text(L10n.limitations)
                        .font(.system(size: 15, weight: .semibold))
                    Text(L10n.birthdayLimitationsDescription(complexDateFormatter.string(from: viewModel.startDate), complexDateFormatter.string(from: viewModel.endDate)))
                        .font(.system(size: 15))
                        .lineSpacing(3)
                        .padding(.horizontal, 20)
                }
                .foregroundColor(.purple600)
                .padding(.top, 20)
                .padding(.bottom, 40)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(Color.purple50)
            }
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .background(VStack {
            Rectangle()
                .foregroundColor(Color.purple300)
            Rectangle()
                .foregroundColor(Color.purple50)
        }.ignoresSafeArea())
    }
}

class BirthdayViewModel: ObservableObject {
    @Published var ownsGryphatrice: Bool = false
    @Published var price: String = ""
    @Published var gemPrice: Int = 60
    @Published var startDate: Date
    @Published var endDate: Date
    
    @Published var isPurchasing = false
    
    private let inventoryRepository = InventoryRepository()
    private let userRepository = UserRepository()
    
    var onDismiss: (() -> Void)?
    var inAppProduct: SKProduct? {
        didSet {
            price = inAppProduct?.localizedPrice ?? ""
        }
    }
    
    init() {
        startDate = Date.with(year: 2023, month: 1, day: 23)
        endDate = Date.with(year: 2023, month: 2, day: 1)
    }
    
    func openMarket() {
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            RouterHandler.shared.handle(urlString: "/inventory/market")
        }
    }
    
    func dismiss() {
        if let function = onDismiss {
            function()
        }
    }
    
    func purchaseWithGems() {
        isPurchasing = true
        let alert = HabiticaAlertController(title: L10n.purchaseGryphatriceConfirmation(gemPrice))
        alert.addAction(title: L10n.buyForX("\(gemPrice) Gems"), isMainAction: true) {[weak self] _ in
            self?.inventoryRepository.purchaseItem(purchaseType: "pets", key: "Gryphatrice-Jubilant", value: 15, quantity: 1, text: L10n.jubilantGryphatrice)
                .flatMap(.latest) { _ in
                    return self?.userRepository.retrieveUser() ?? Signal.empty
                }.observeCompleted {
                    self?.isPurchasing = false
                }
        }
        alert.addCloseAction {[weak self] _ in
            self?.isPurchasing = false
        }
        alert.show()
    }
    
    func purchaseAsIAP() {
        isPurchasing = true
        PurchaseHandler.shared.purchaseGems(PurchaseHandler.gryphatriceIdentifier, applicationUsername: "") {[weak self] success in
            self?.isPurchasing = false
            if success {
                self?.userRepository.retrieveUser().observeCompleted {
                }
            }
        }
    }
    
    func equip() {
        inventoryRepository.equip(type: "pet", key: "Gryphatrice-Jubilant").observeCompleted {
            ToastManager.show(text: L10n.equippedX(L10n.jubilantGryphatrice), color: .green)
        }
    }
}

class BirthdayViewController: UIHostingController<BirthdayView> {
    let viewModel = BirthdayViewModel()
    let stableRepository = StableRepository()
    
    init() {
        super.init(rootView: BirthdayView(viewModel: viewModel))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: BirthdayView(viewModel: viewModel))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.onDismiss = {[weak self] in
            self?.dismiss(animated: true)
        }
        
        stableRepository.getOwnedPets(query: "key == 'Gryphatrice-Jubilant'")
            .on(value: {[weak self] pets in
                self?.viewModel.ownsGryphatrice = (pets.value.first?.trained ?? 0) >= 5
            })
            .start()
        
        let event = ConfigRepository.shared.getBirthdayEvent()
        if let start = event?.start {
            viewModel.startDate = start
        }
        if let end = event?.end {
            viewModel.endDate = end
        }
        
        SwiftyStoreKit.retrieveProductsInfo(Set(arrayLiteral: PurchaseHandler.gryphatriceIdentifier)) { (result) in
            self.viewModel.inAppProduct = result.retrievedProducts.first
        }
    }
}

struct BirthdayViewPreview: PreviewProvider {
    static var previews: some View {
        BirthdayView(viewModel: BirthdayViewModel())
    }
}
