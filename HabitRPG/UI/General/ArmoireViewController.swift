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

private struct ArmoirePlus: View {
    var thickness: CGFloat = 6
    var length: CGFloat = 12
    var maxSpacing: CGFloat = 4
    var color = Color(ThemeService.shared.theme.tintColor)
    
    @State private var isAnimating = false
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            color
                .frame(width: thickness, height: length)
                .cornerRadius(thickness/2)
                .offset(x: 0, y: isAnimating ? -maxSpacing : 0)
            HStack(spacing: 0) {
                color
                    .frame(width: length, height: thickness)
                    .cornerRadius(thickness/2)
                    .offset(x: isAnimating ? -maxSpacing : 0, y: 0)
                Spacer()
                    .frame(width: thickness)
                color
                    .frame(width: length, height: thickness)
                    .cornerRadius(thickness/2)
                    .offset(x: isAnimating ? maxSpacing : 0, y: 0)
            }
            color
                .frame(width: thickness, height: length)
                .cornerRadius(thickness/2)
                .offset(x: 0, y: isAnimating ? maxSpacing : 0)
        }
        .animation(.easeInOut(duration: Double.random(in: 3...4)).repeatForever(autoreverses: true))
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
}

private class ViewModel: ObservableObject {
    let userRepository = UserRepository()
    let inventoryRepository = InventoryRepository()
    
    @Published var gold: Double = 0
    @Published var initialGold: Double = 0
    @Published var text: String = ""
    @Published var type: String = ""
    @Published var key: String = ""
    @Published var value: String = ""
    @Published var remainingCount = 0
    
    init(gold: Double? = nil) {
        if let gold = gold {
            self.gold = gold
            self.initialGold = gold
        } else {
            userRepository.getUser().on(value: { user in
                if self.gold == 0 {
                    self.initialGold = Double(user.stats?.gold ?? 0)
                    self.gold = Double(user.stats?.gold ?? 0)
                }
            }).start()
            
            inventoryRepository.getArmoireRemainingCount().on(value: {gear in
                self.remainingCount = gear.value.count
            }).start()
        }
    }
    
    var icon: Source? {
        switch type {
        case "gear":
            if let url = ImageManager.buildImageUrl(name: "shop_\(key)") {
                return Source.network(ImageResource(downloadURL: url))
            }
        case "food":
            if let url = ImageManager.buildImageUrl(name: "Pet_Food_\(key)") {
                return Source.network(ImageResource(downloadURL: url))
            }
        default:
            if let data = Asset.armoireExperience.image.pngData() {
                return Source.provider(RawImageDataProvider(data: data, cacheKey: "armoireExperience"))
            }
        }
        return nil
    }
    
    var title: String {
        switch type {
        case "experience":
            return "+\(Int(value) ?? 0) Experience"
        default:
            return text
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
}

struct ArmoireView: View {
    var onDismiss: (() -> Void) = {}
    fileprivate var viewModel: ViewModel
    
    @State var isBobbing = false
    @State var confettiCounter = 0
    @State var showArmoireAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
                Image(uiImage: HabiticaIcons.imageOfGold)
                Text("\(Int(viewModel.initialGold))")
                    .padding(.horizontal, 12)
                    .foregroundColor(Color.clear)
                    .animatingOverlay(for: viewModel.gold)
                    .animation(.linear(duration: 2))
                    .foregroundColor(Color(UIColor.yellow1))
                    .font(.system(size: 20, weight: .bold))
                    .onAppear {
                        viewModel.gold -= 100
                        confettiCounter = 1
                        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                            isBobbing = true
                        }
                    }
            }
            .frame(height: 32)
            .padding(.leading, 12)
            .background(Color(UIColor.yellow100).opacity(0.4))
            .cornerRadius(16)
            .padding(.top, 24)
            .padding(.bottom, 16)
            Spacer()
            
            ZStack {
                    KFImage(source: viewModel.icon)
                        .resizable()
                        .frame(width: viewModel.iconWidth, height: viewModel.iconHeight)
                        .offset(y: isBobbing ? 5 : -5)
                    .frame(width: 158, height: 158)
                    .background(Color(UIColor.gray700))
                    .cornerRadius(79)
                    .confettiCannon(counter: $confettiCounter,
                                    num: 5,
                                    confettis: [.shape(.slimRectangle)],
                                    colors: [Color(UIColor.yellow100), Color(UIColor.red100), Color(UIColor.blue100), Color(UIColor.purple400)],
                                    rainHeight: 800,
                                    radius: 400,
                                    repetitions: 20,
                                    repetitionInterval: 0.1)
                ArmoirePlus()
                    .offset(x: -70, y: -60)
                ArmoirePlus()
                    .offset(x: 60, y: 70)
            }
            Text(viewModel.title)
                .foregroundColor(.primaryTextColor)
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.top, 24)
                .padding(.bottom, 8)
                .frame(maxWidth: 310)
                .padding(.horizontal, 32)
            Text(viewModel.subtitle)
                .foregroundColor(.ternaryTextColor)
                .multilineTextAlignment(.center)
                .font(.system(size: 22))
                .frame(maxWidth: 310)
                .padding(.horizontal, 32)
            Spacer()
            VStack {
                Text(L10n.Armoire.equipmentRemaining(viewModel.remainingCount))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                HStack {
                    if viewModel.type == "gear" {
                        HabiticaButtonUI(label: Text(L10n.equip), color: .white) {
                            viewModel.inventoryRepository.equip(type: "equipped", key: viewModel.key).observeCompleted {
                                onDismiss()
                            }
                        }
                    }
                    HabiticaButtonUI(label: Text(L10n.close), color: .white, onTap: {
                        onDismiss()
                    })
                }
                Text(L10n.Armoire.dropRate)
                    .foregroundColor(Color(UIColor.purple600))
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.top, 12)
                    .onTapGesture {
                        showArmoireAlert = true
                    }
            }
            .padding(.horizontal, 50)
            .padding(.top, 30)
            .frame(minHeight: UIScreen.main.bounds.height > 700 ? 300 : 220, alignment: .center)
            .frame(maxWidth: .infinity)
            .background(Image(uiImage: Asset.armoireBackground.image).resizable().edgesIgnoringSafeArea(.bottom))
        }.sheet(isPresented: $showArmoireAlert) {
            NavigationView {
                VStack(alignment: .leading) {
                    Text(L10n.Armoire.enchantedArmoireDropRates)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.bottom, 18)
                    Text(L10n.Armoire.rateEquipmentTitle)
                        .foregroundColor(Color(ThemeService.shared.theme.primaryTextColor))
                        .font(.system(size: 16))
                    Text(L10n.Armoire.rateEquipmentDescription)
                        .font(.system(size: 12))
                        .padding(.bottom, 18)
                    Text(L10n.Armoire.rateFoodTitle)
                        .foregroundColor(Color(ThemeService.shared.theme.primaryTextColor))
                        .font(.system(size: 16))
                    Text(L10n.Armoire.rateFoodDescription)
                        .font(.system(size: 12))
                        .padding(.bottom, 18)
                    Text(L10n.Armoire.rateExperienceTitle)
                        .foregroundColor(Color(ThemeService.shared.theme.primaryTextColor))
                        .font(.system(size: 16))
                    Text(L10n.Armoire.rateExperienceDescription)
                        .font(.system(size: 12))
                    Spacer()
                }
                .foregroundColor(Color(ThemeService.shared.theme.ternaryTextColor))
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
    fileprivate let viewModel = ViewModel()
    
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
            viewModel.value = "\(value)"
        }
    }
    
    func show() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
    
    private static func makeViewModel(type: String) -> ViewModel {
        let model = ViewModel(gold: 5000)
        model.type = type
        model.text = "Meat"
        model.key = "Meat"
        return model
    }
    
    static var previews: some View {
        ArmoireView(viewModel: makeViewModel(type: "experience"))
            .previewDevice("iPhone 13 Pro")
        ArmoireView(viewModel: makeViewModel(type: "food"))
            .previewDevice("iPhone SE (3rd generation)")
    }
}
