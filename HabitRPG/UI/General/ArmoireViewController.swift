//
//  ArmoireViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 24.08.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Kingfisher
import ConfettiSwiftUI
import ReactiveSwift

struct AnimatableNumberModifier: AnimatableModifier {
    var number: Double
    
    var animatableData: Double {
        get { number }
        set { number = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Text("\(Int(number))")
            )
    }
}

extension View {
    func animatingOverlay(for number: Double) -> some View {
        modifier(AnimatableNumberModifier(number: number))
    }
}

struct ArmoirePlus: View {
    @ObservedObject var themeService = ThemeService.shared
    var thickness: CGFloat = 6
    var length: CGFloat = 12
    var maxSpacing: CGFloat = 3
    var color = Color(ThemeService.shared.theme.tintColor)
    
    @State private var isAnimating = false
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            color
                .frame(width: thickness, height: length)
                .clipShape(.capsule)
                .offset(x: 0, y: isAnimating ? -maxSpacing : 0)
            HStack(spacing: 0) {
                color
                    .frame(width: length, height: thickness)
                    .clipShape(.capsule)
                    .offset(x: isAnimating ? -maxSpacing : 0, y: 0)
                Spacer()
                    .frame(width: thickness)
                color
                    .frame(width: length, height: thickness)
                    .clipShape(.capsule)
                    .offset(x: isAnimating ? maxSpacing : 0, y: 0)
            }
            color
                .frame(width: thickness, height: length)
                .clipShape(.capsule)
                .offset(x: 0, y: isAnimating ? maxSpacing : 0)
        }
        .animation(.easeInOut(duration: Double.random(in: 3...6)).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
}

private class ArmoireViewModel: ViewModel {
    let userRepository = UserRepository()
    let inventoryRepository = InventoryRepository()
    
    var showSubPage: (() -> Void)?
    
    @Published var gold: Double = 0
    @Published var initialGold: Double = 0
    @Published var text: String = ""
    @Published var type: String?
    @Published var key: String = ""
    @Published var value: Float = 0
    @Published var remainingCount = 0
    @Published var isSubscribed = false
    @Published var isUsingPerk = false
    @Published var hideGold = false
    @Published var usedPerk = false
    
    init(gold: Double? = nil) {
        super.init()
        if let gold = gold {
            self.gold = gold
            self.initialGold = gold
        } else {
            disposable.add(userRepository.getUser().on(value: { user in
                self.isSubscribed = user.isSubscribed
                if self.gold == 0 {
                    self.initialGold = Double(user.stats?.gold ?? 0) + 100
                    self.gold = Double(user.stats?.gold ?? 0) + 100
                }
            }).start())
            
            disposable.add(inventoryRepository.getArmoireRemainingCount().on(value: {gear in
                self.remainingCount = gear.value.count
            }).start())
        }
    }
    
    var icon: Source? {
        switch type {
        case "gear":
            if let url = ImageManager.buildImageUrl(name: "shop_\(key)") {
                return Source.network(KF.ImageResource(downloadURL: url))
            }
        case "food":
            if let url = ImageManager.buildImageUrl(name: "Pet_Food_\(key)") {
                return Source.network(KF.ImageResource(downloadURL: url))
            }
        case "experience":
            if let data = Asset.armoireExperience.image.pngData() {
                return Source.provider(RawImageDataProvider(data: data, cacheKey: "armoireExperience"))
            }
        default:
            return nil
        }
        return nil
    }
    
    var title: String {
        switch type {
        case "experience":
            return "+\(Int(value)) Experience"
        default:
            return text.localizedCapitalized
        }
    }
    
    var subtitle: String {
        switch type {
        case "gear":
            return L10n.Armoire.equipment
        case "food":
            return L10n.Armoire.food
        case "experience":
            return L10n.Armoire.experience
        default:
            return ""
        }
    }
    
    var iconWidth: CGFloat {
        if type == "experience" {
            return 108
        } else {
            return 136
        }
    }
    
    var iconHeight: CGFloat {
        if type == "experience" {
            return 122
        } else {
            return 136
        }
    }
    
    func useSubBenefit(_ onCompleted: @escaping () -> Void) {
        type = nil
        text = ""
        key = ""
        HabiticaAnalytics.shared.log("Free armoire perk")
        userRepository.updateUser(key: "stats.gp", value: gold + 100)
            .flatMap(.latest, { _ in
                return self.inventoryRepository.buyObject(key: "armoire", quantity: 1, price: 0, text: "", openArmoireView: false)
            }).on(value: {response in
                self.type = response?.armoire?.type
                self.text = response?.armoire?.dropText ?? ""
                self.key = response?.armoire?.dropKey ?? ""
                self.value = response?.armoire?.value ?? 0
                if self.type == "gear" {
                    self.remainingCount -= 1
                }
                onCompleted()
            })
            .flatMap(.latest, { _ in
                return self.userRepository.retrieveInAppRewards()
            })
            .flatMap(.latest, { _ in
                return self.userRepository.retrieveUser(forced: true)
            })
            .observeValues({ _ in
            })
    }
}

struct ArmoireView: View {
    @ObservedObject var themeService = ThemeService.shared
    var onDismiss: (() -> Void) = {}
    @ObservedObject fileprivate var viewModel: ArmoireViewModel
    
    @State var isBobbing = false
    @State var confettiCounter = 0
    @State var showArmoireAlert = false
    
    private var paddingScaling: CGFloat {
        if UIScreen.main.bounds.height <= 667 {
            return 0.85
        } else {
            return 1
        }
    }
    
    var body: some View {
        let paddingScaling = paddingScaling
        VStack(spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
                Image(uiImage: HabiticaIcons.imageOfGold)
                Text("\(Int(viewModel.initialGold))")
                    .padding(.horizontal, 12)
                    .foregroundStyle(Color.clear)
                    .animatingOverlay(for: viewModel.gold)
                    .animation(.linear(duration: 2), value: viewModel.gold)
                    .onAppear {
                        viewModel.gold -= 100
                        confettiCounter = 1
                    }
            }
            .foregroundStyle(Color(themeService.theme.isDark ? UIColor.yellow500 : UIColor.yellow1))
            .font(.system(size: 20, weight: .bold))
            .frame(height: 32)
            .padding(.leading, 12)
            .background(Color(UIColor.yellow100).opacity(0.4))
            .opacity(viewModel.hideGold ? 0.0 : 1.0)
            .animation(.linear(duration: 0.1), value: viewModel.hideGold)
            .clipShape(.capsule)
            .padding(.top, 24 * paddingScaling)
            .padding(.bottom, 16 * paddingScaling)
            Spacer()
            
            ZStack {
                if !viewModel.isUsingPerk || viewModel.usedPerk {
                    EmptyView()
                        .confettiCannon(trigger: $confettiCounter,
                                        num: 5,
                                        confettis: [.image(Asset.confettiPill.name)],
                                        colors: [.yellow100, .red100, .blue100, .purple400], confettiSize: 10,
                                        rainHeight: UIScreen.main.bounds.height, fadesOut: false,
                                        openingAngle: .degrees(30),
                                        closingAngle: .degrees(150), radius: 400,
                                        repetitions: 20,
                                        repetitionInterval: 0.1)
                }
                    PixelArtView(source: viewModel.icon)
                        .frame(width: viewModel.iconWidth, height: viewModel.iconHeight)
                        .opacity(1)
                        .offset(y: isBobbing ? 5 : -5)
                    .frame(width: 158, height: 158)
                    .background(Color(UIColor.gray700))
                    .clipShape(.circle)
                ArmoirePlus()
                    .offset(x: -70, y: -60)
                ArmoirePlus()
                    .offset(x: 60, y: 70)
            }
            .opacity(viewModel.type != nil ? 1.0 : 0.0)
            Text(viewModel.title)
                .foregroundStyle(Color(themeService.theme.primaryTextColor))
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.top, 24 * paddingScaling)
                .padding(.bottom, 8)
                .frame(maxWidth: 310)
                .padding(.horizontal, 32)
                .opacity(viewModel.type != nil ? 1.0 : 0.0)
                    .animation(.linear, value: viewModel.type)
            if paddingScaling >= 1 {
                Text(viewModel.subtitle)
                    .foregroundStyle(Color(themeService.theme.ternaryTextColor))
                    .multilineTextAlignment(.center)
                    .font(.system(size: 22))
                    .frame(maxWidth: 310)
                    .padding(.horizontal, 32)
                    .opacity(viewModel.type != nil ? 1.0 : 0.0)
                    .animation(.linear, value: viewModel.type)
            }
            Spacer()
            VStack {
                Text(L10n.Armoire.equipmentRemaining(viewModel.remainingCount))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                HStack {
                    if viewModel.type == "gear" {
                        HabiticaButtonUI(label: Text(L10n.equip), color: .white) {
                            viewModel.inventoryRepository.equip(type: "equipped", key: viewModel.key).observeCompleted {
                                onDismiss()
                            }
                        }.padding(.trailing, 16)
                    }
                    HabiticaButtonUI(label: Text(L10n.close), color: .white, onTap: {
                        onDismiss()
                    })
                }
                .frame(maxWidth: 600)
                .padding(.horizontal, 24)
                let gradientColors: [Color] = [Color(hexadecimal: "72CFFF"),
                                      Color(hexadecimal: "77F4C7")]
                if viewModel.isSubscribed {
                        Button(action: {
                            if viewModel.isUsingPerk || viewModel.usedPerk {
                                return
                            }
                            viewModel.hideGold = true
                            viewModel.isUsingPerk = true
                            viewModel.useSubBenefit {
                                viewModel.usedPerk = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                    confettiCounter += 1
                                })
                            }
                        }, label: {
                            Group {
                                if viewModel.isUsingPerk {
                                    ProgressView().habiticaProgressStyle().frame(width: 28, height: 28)
                                } else {
                                    Text(L10n.Armoire.subbedButtonPrompt)
                                }
                            }
                                .foregroundStyle(Color(UIColor.green1))
                                .font(.headline)
                                .padding(.vertical, 6)
                                .frame(minHeight: 60)
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(colors: gradientColors, startPoint: .leading, endPoint: .trailing))
                                .overlay(RoundedRectangle(cornerRadius: UIConstants.largeCornerRadius).stroke(LinearGradient(colors: gradientColors, startPoint: .trailing, endPoint: .leading), lineWidth: 3))
                                .cornerRadius(UIConstants.largeCornerRadius)
                        })
                        .frame(maxWidth: 600)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 8)
                        .opacity(viewModel.usedPerk ? 0.0 : 1.0)
                        .animation(.linear, value: viewModel.usedPerk)
                        Text(L10n.Armoire.subbedFooter)
                            .foregroundStyle(.white)
                            .font(.system(size: 15, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 36)
                } else {
                    VStack(alignment: .center, spacing: 8) {
                        HabiticaButtonUI(label: Text(L10n.Armoire.unsubbedButtonPrompt).foregroundStyle(Color(UIColor.teal10)), color: .white) {
                            HabiticaApplication.shared.topmostViewController?.present(SubscriptionModalViewController(presentationPoint: .armoire), animated: true)
                        }.frame(maxWidth: 600)
                        Text(L10n.Armoire.unsubbedFooter)
                            .foregroundStyle(Color(UIColor.teal1))
                            .font(.system(size: 15, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(L10n.Armoire.dropRate)
                            .foregroundStyle(Color(UIColor.teal1))
                            .opacity(0.75)
                            .font(.system(size: 15))
                            .onTapGesture {
                                showArmoireAlert = true
                            }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, (UIApplication.shared.findKeyWindow()?.safeAreaInsets.bottom ?? 0) + 12)
                    .frame(maxWidth: .infinity)
                    .edgesIgnoringSafeArea(.bottom)
                    .background(RotatingLinearGradient(colors: gradientColors, animationDuration: 20.0).edgesIgnoringSafeArea(.bottom))
                    .cornerRadius([.topLeading, .topTrailing], UIConstants.largeCornerRadius)
                    .padding(.top, 8)
                }
            }
            .padding(.top, 90)
            .frame(minHeight: UIScreen.main.bounds.height > 700 ? 330 : 250, alignment: .center)
            .frame(maxWidth: .infinity)
            .edgesIgnoringSafeArea(.bottom)
            .background(Image(uiImage: Asset.armoireBackground.image).resizable()
                .edgesIgnoringSafeArea(.bottom))
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                isBobbing = true
            }
        }
        .sheet(isPresented: $showArmoireAlert) {
            NavigationView {
                VStack(alignment: .leading) {
                    Text(L10n.Armoire.enchantedArmoireDropRates)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.bottom, 18)
                    Text(L10n.Armoire.rateEquipmentTitle)
                        .foregroundStyle(Color(themeService.theme.primaryTextColor))
                        .font(.system(size: 16))
                    Text(L10n.Armoire.rateEquipmentDescription)
                        .font(.system(size: 12))
                        .padding(.bottom, 18)
                    Text(L10n.Armoire.rateFoodTitle)
                        .foregroundStyle(Color(themeService.theme.primaryTextColor))
                        .font(.system(size: 16))
                    Text(L10n.Armoire.rateFoodDescription)
                        .font(.system(size: 12))
                        .padding(.bottom, 18)
                    Text(L10n.Armoire.rateExperienceTitle)
                        .foregroundStyle(Color(themeService.theme.primaryTextColor))
                        .font(.system(size: 16))
                    Text(L10n.Armoire.rateExperienceDescription)
                        .font(.system(size: 12))
                    Spacer()
                }
                .foregroundStyle(Color(themeService.theme.ternaryTextColor))
                .padding(.horizontal, 30)
                .padding(.vertical, 16)
                .toolbar {
                    ToolbarItem {
                        Button {
                            showArmoireAlert = false
                        } label: {
                            Text(L10n.close)
                        }

                    }
                }
            }
        }

    }
}

class ArmoireViewController: UIHostingController<ArmoireView> {
    fileprivate let viewModel = ArmoireViewModel()
    
    init() {
        super.init(rootView: ArmoireView(viewModel: viewModel))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: ArmoireView(viewModel: viewModel))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.onDismiss = {[weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    func configure(type: String, text: String, key: String?, value: Float?) {
        viewModel.type = type
        viewModel.text = text
        viewModel.key = key ?? ""
        if let value = value {
            viewModel.value = value
        }
    }
    
    func show() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            if var topController = UIApplication.topViewController() {
                if let tabBarController = topController.tabBarController {
                    topController = tabBarController
                }
                self.modalTransitionStyle = .crossDissolve
                self.modalPresentationStyle = .overCurrentContext
                topController.present(self, animated: true) {
                }
            }
        }
    }
}

struct ArmoireView_Previews: PreviewProvider {
    
    private static func makeViewModel(type: String, isSubscribed: Bool) -> ArmoireViewModel {
        let model = ArmoireViewModel(gold: 5000)
        model.type = type
        model.text = "Meat"
        model.key = "Meat"
        model.isSubscribed = isSubscribed
        return model
    }
    
    static var previews: some View {
        ArmoireView(viewModel: makeViewModel(type: "experience", isSubscribed: true))
            .previewDevice("iPhone 14 Pro")
            .previewDisplayName("Experience, Subbed")
        ArmoireView(viewModel: makeViewModel(type: "food", isSubscribed: true))
            .previewDevice("iPhone SE (3rd generation)")
            .previewDisplayName("Food, Subbed")
        ArmoireView(viewModel: makeViewModel(type: "experience", isSubscribed: false))
            .previewDevice("iPhone SE (3rd generation)")
            .previewDisplayName("Experience, Unsubbed")
        ArmoireView(viewModel: makeViewModel(type: "food", isSubscribed: false))
            .previewDevice("iPhone SE (3rd generation)")
            .previewDisplayName("Food, Unsubbed")
    }
}
