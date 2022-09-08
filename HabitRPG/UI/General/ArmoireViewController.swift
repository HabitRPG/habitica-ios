//
//  ArmoireViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 24.08.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Kingfisher

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

private class ViewModel: ObservableObject {
    let userRepository = UserRepository()
    let inventoryRepository = InventoryRepository()
    
    @Published var gold: Double = 0
    @Published var text: String = ""
    @Published var type: String = ""
    @Published var key: String = ""
    @Published var value: String = ""
    
    init() {
        userRepository.getUser().on(value: { user in
            if self.gold == 0 {
                self.gold = Double(user.stats?.gold ?? 0)
            }
        }).start()
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
            return "+\(value) \(text)"
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
    
    @State var isAnimating = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(uiImage: HabiticaIcons.imageOfGold)
                Text("\(Int(viewModel.gold))")
                    .foregroundColor(Color.clear)
                    .animatingOverlay(for: viewModel.gold)
                    .animation(.linear(duration: 1))
                    .foregroundColor(Color(UIColor.yellow1))
                    .font(.system(size: 20, weight: .bold))
                    .onAppear {
                        withAnimation {
                            viewModel.gold -= 100
                            isAnimating = true
                        }
                    }
            }
            .frame(height: 32)
            .padding(.horizontal, 10)
            .background(Color(UIColor.yellow100).opacity(0.4))
            .cornerRadius(16)
            .padding(.top, 24)
            Spacer()
            if #available(iOS 14.0, *) {
                Group {
                    KFImage(source: viewModel.icon)
                        .resizable()
                        .animation(.easeOut)
                        .frame(width: viewModel.iconWidth, height: viewModel.iconHeight)
                }
                    .frame(width: 158, height: 158)
                    .background(Color(UIColor.gray700))
                    .cornerRadius(79)
            }
            Text(viewModel.title)
                .foregroundColor(.primaryTextColor)
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.vertical, 16)
                .frame(maxWidth: 310)
                .padding(.horizontal, 32)
            Text(viewModel.subtitle)
                .foregroundColor(.ternaryTextColor)
                .multilineTextAlignment(.center)
                .font(.system(size: 20))
                .frame(maxWidth: 310)
                .padding(.horizontal, 32)
            Spacer()
            VStack {
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
                    .font(.system(size: 14))
                    .padding(.top, 12)
            }
            .padding(.horizontal, 50)
            .padding(.top, 30)
            .frame(minHeight: 300, alignment: .center)
            .frame(maxWidth: .infinity)
            .background(Image(uiImage: Asset.armoireBackground.image).resizable().edgesIgnoringSafeArea(.bottom))
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
    static var previews: some View {
        ArmoireView(viewModel: ViewModel())
    }
}
