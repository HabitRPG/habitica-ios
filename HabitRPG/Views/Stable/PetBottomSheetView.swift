//
//  PetBottomSheetView.swift
//  Habitica
//
//  Created by Phillip Thelen on 18.09.23.
//  Copyright © 2023 HabitRPG Inc. All rights reserved.
//

import SwiftUI
import Habitica_Models
import Kingfisher

struct PetView: View {
    var pet: AnimalProtocol
    
    var body: some View {
        PixelArtView(name: "stable_Pet-\(pet.key ?? "")").frame(width: 70, height: 70)
    }
}

struct PetBottomSheetView: View, Dismissable {
    @ObservedObject var themeService = ThemeService.shared
    var dismisser: Dismisser = Dismisser()
    
    let pet: PetProtocol
    let trained: Int
    let canRaise: Bool
    let isCurrentPet: Bool
    let onEquip: () -> Void
    
    private let inventoryRepository = InventoryRepository()
    @State private var isShowingFeeding = false
    @State private var isUsingSaddle = false
    @State private var image: UIImage?
    
    @State private var showFeedResponse = false
    @State private var feedMessage: String?
    @State private var feedValue: Float?
    
    private func getFoodName() -> String {
        switch pet.potion {
        case "Base":
            return Asset.feedBase.name
        case "CottonCandyBlue":
            return Asset.feedBlue.name
        case "Desert":
            return Asset.feedDesert.name
        case "Golden":
            return Asset.feedGolden.name
        case "CottonCandyPink":
            return Asset.feedPink.name
        case "Red":
            return Asset.feedRed.name
        case "Shade":
            return Asset.feedShade.name
        case "Skeleton":
            return Asset.feedSkeleton.name
        case "White":
            return Asset.feedWhite.name
        case "Zombie":
            return Asset.feedZombie.name
        default:
            return Asset.feedBase.name
        }
    }
    
    var body: some View {
        let theme = themeService.theme
        BottomSheetView(dismisser: dismisser, title: Text(pet.text ?? ""), content: VStack(spacing: 16) {
            ZStack(alignment: .top) {
                StableBackgroundView(content: PetView(pet: pet).padding(.top, 40), animateFlying: false)
                    .clipShape(.rect(cornerRadius: UIConstants.largeCornerRadius))
                if showFeedResponse, let message = feedMessage {
                    Text(message)
                        .font(.system(size: 12))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(theme.primaryTextColor))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 3)
                        .background(Color(theme.contentBackgroundColor))
                        .clipShape(.capsule)
                        .transition(.opacity)
                        .padding(.horizontal, 4)
                        .padding(.bottom, 8)
                        .frame(height: 124, alignment: .bottom)
                        .zIndex(3)
                    ProgressView(value: (feedValue ?? Float(trained)) / 50)
                        .tint(Color(theme.successColor))
                        .animation(.smooth, value: feedValue)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 3)
                        .background(Color(theme.contentBackgroundColor))
                        .clipShape(.capsule)
                        .frame(width: 200)
                        .transition(.opacity)
                        .padding(.top, 6)
                        .zIndex(4)
                }
            }
            let buttonBackground = Color(theme.offsetBackgroundColor)
            if trained > 0 && pet.type != "special" && canRaise {
                HStack(spacing: 16) {
                    Button(action: {
                        isUsingSaddle = true
                        dismisser.dismiss()
                        inventoryRepository.feed(pet: pet, food: "Saddle")
                            .observeCompleted {
                            isUsingSaddle = false
                        }
                    }, label: {
                        VStack {
                            if isUsingSaddle {
                                ProgressView().habiticaProgressStyle(strokeWidth: 6)
                            } else {
                                Image(Asset.feedSaddle.name).interpolation(.none)
                                Text(L10n.Stable.useSaddle).font(.system(size: 16, weight: .semibold)).foregroundStyle(Color(theme.primaryTextColor)).underline(UIAccessibility.buttonShapesEnabled)
                            }
                        }
                    }).buttonStyle { configuration in
                        let conf = configuration.label
                            .frame(height: 101)
                            .maxWidth(.infinity)
                        if #available(iOS 26.0, *) {
                            conf.glassEffect(.regular.interactive().tint(buttonBackground.opacity(0.9)), in: RoundedRectangle(cornerRadius: UIConstants.largeCornerRadius))
                        } else {
                            conf
                                .background(buttonBackground)
                                .clipShape(.rect(cornerRadius: UIConstants.largeCornerRadius))
                        }
                    }
                    Button(action: {
                        isShowingFeeding = true
                    }, label: {
                        VStack {
                            Image(getFoodName()).interpolation(.none)
                            Text(L10n.Stable.feed).font(.system(size: 16, weight: .semibold)).foregroundStyle(Color(theme.primaryTextColor)).underline(UIAccessibility.buttonShapesEnabled)
                        }
                    }).buttonStyle { configuration in
                        let conf = configuration.label
                            .frame(height: 101)
                            .maxWidth(.infinity)
                        if #available(iOS 26.0, *) {
                            conf.glassEffect(.regular.interactive().tint(buttonBackground.opacity(0.9)), in: RoundedRectangle(cornerRadius: UIConstants.largeCornerRadius))
                        } else {
                            conf
                                .background(buttonBackground)
                                .clipShape(.rect(cornerRadius: UIConstants.largeCornerRadius))
                        }
                    }
                }
            }
            HabiticaButtonUI(label: Text(L10n.share).foregroundStyle(Color(theme.primaryTextColor)), color: buttonBackground) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    SharingManager.share(pet: pet)
                }
                dismisser.dismiss()
            }
            if trained > 0 {
                HabiticaButtonUI(label: Text(isCurrentPet ? L10n.unequip : L10n.equip), color: Color(theme.fixedTintColor)) {
                    onEquip()
                    dismisser.dismiss()
                }
            }
        }
        )
        .sheet(isPresented: $isShowingFeeding, content: {
            NavigationView {
                FeedSheetView(onFeed: { food in
                        self.feedPet(food: food)
                    }, dismissParent: {
                        dismisser.dismiss()
                    }).presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible).navigationTitle(L10n.Titles.feedPet)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    ToolbarItem(placement: .automatic) {
                        Button {
                            isShowingFeeding = false
                        } label: {
                            Text(L10n.cancel)
                        }
                    }
                })
            }
        })
    }
    
    private func feedPet(food: FoodProtocol) {
        self.inventoryRepository.feed(pet: pet, food: food).observeValues { response in
            if response?.data == -1 {
                dismisser.dismiss()
                return
            }
            withAnimation {
                feedMessage = response?.message
                showFeedResponse = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation {
                    feedValue = Float(response?.data ?? 0)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showFeedResponse = false
                }
            }
        }
    }
}

#Preview {
    return PetBottomSheetView(pet: PreviewPet(egg: "BearCub", potion: "Base", type: "drop", text: "Base Bear Cub"), trained: 10, canRaise: true, isCurrentPet: false, onEquip: {})
}

class PreviewPet: PetProtocol {
    init(egg: String, potion: String, type: String? = nil, text: String? = nil) {
        self.key = "\(egg)-\(potion)"
        self.egg = egg
        self.potion = potion
        self.type = type
        self.text = text
    }
    
    var key: String?
    var egg: String?
    var potion: String?
    var type: String?
    var text: String?
    var isValid: Bool = true
    var isManaged: Bool = true
    
}

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self.ignoresSafeArea())
        let view = controller.view
 
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
 
        let renderer = UIGraphicsImageRenderer(size: targetSize)
 
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
