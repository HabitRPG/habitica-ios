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

struct PetBottomSheetView: View, Dismissable {
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
    
    private func getFoodName() -> String {
        switch pet.potion {
        case "Base":
            return Asset.feedBase.name
        case "CottonCandyBlue":
            return Asset.feedBlue.name
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
        let theme = ThemeService.shared.theme
        let petView = PixelArtView(name: "stable_Pet-\(pet.key ?? "")").frame(width: 70, height: 70)
        BottomSheetView(dismisser: dismisser, title: Text(pet.text ?? ""), content: VStack(spacing: 16) {
            StableBackgroundView(content: petView.padding(.top, 40), animateFlying: false)
                .clipShape(.rect(cornerRadius: 12))
            if trained > 0 && pet.type != "special" && canRaise {
                let buttonBackground = Color(theme.tintedSubtleUI)
                HStack(spacing: 16) {
                    Button(action: {
                        dismisser.dismiss?()
                        inventoryRepository.feed(pet: pet.key ?? "", food: "Saddle").observeCompleted {}
                    }, label: {
                        VStack {
                            if isUsingSaddle {
                                ProgressView().habiticaProgressStyle(strokeWidth: 6)
                            } else {
                                Image(Asset.feedSaddle.name).interpolation(.none)
                                Text(L10n.Stable.useSaddle).font(.system(size: 16, weight: .semibold)).foregroundColor(Color(theme.tintedMainText))
                            }
                        }
                        .frame(height: 101)
                        .maxWidth(.infinity)
                        .background(buttonBackground)
                        .clipShape(.rect(cornerRadius: 12))
                    })
                    Button(action: {
                        isShowingFeeding = true
                    }, label: {
                        VStack {
                            Image(getFoodName()).interpolation(.none)
                            Text(L10n.Stable.feed).font(.system(size: 16, weight: .semibold)).foregroundColor(Color(theme.tintedMainText))
                        }
                        .frame(height: 101)
                        .maxWidth(.infinity)
                        .background(buttonBackground)
                        .clipShape(.rect(cornerRadius: 12))
                    })
                }
            }
            HabiticaButtonUI(label: Text(L10n.share), color: Color(theme.fixedTintColor), size: .compact) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    var items: [Any] = [
                    ]
                    items.insert(StableBackgroundView(content: petView.padding(.top, 40), animateFlying: false)
                        .frame(width: 300, height: 124)
                        .snapshot(), at: 0)
                    SharingManager.share(identifier: "pet", items: items, presentingViewController: nil, sourceView: nil)
                }
                dismisser.dismiss?()
            }
            if trained > 0 {
                HabiticaButtonUI(label: Text(isCurrentPet ? L10n.unequip : L10n.equip), color: Color(theme.fixedTintColor), size: .compact) {
                    onEquip()
                    dismisser.dismiss?()
                }
            }
        }
        )
        .sheet(isPresented: $isShowingFeeding, content: {
            NavigationView {
                Group {
                    if #available(macCatalyst 16.0, iOS 16.0, *) {
                        FeedSheetView { food in
                            self.feedPet(food: food)
                        }.presentationDetents([.medium, .large])
                            .presentationDragIndicator(.visible)
                    } else {
                        FeedSheetView { food in
                            self.feedPet(food: food)
                        }
                    }
                }.navigationTitle(L10n.Titles.feedPet)
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
                dismisser.dismiss?()
            }
        }
    }
}

#Preview {
    PetBottomSheetView(pet: PreviewPet(egg: "BearCub", potion: "Base", type: "drop", text: "Base Bear Cub"), trained: 10, canRaise: true, isCurrentPet: false, onEquip: {})
        .previewLayout(.fixed(width: 400, height: 500))
}

private class PreviewPet: PetProtocol {
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
