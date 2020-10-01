//
//  PetHatchingDialog.swift
//  Habitica
//
//  Created by Phillip Thelen on 29.09.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

class PetHatchingAlertController: HabiticaAlertController {
    private let inventoryRepository = InventoryRepository()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        return view
    }()
    
    private let imageStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 20
        view.addHeightConstraint(height: 68)
        view.alignment = .center
        view.distribution = .equalCentering
        return view
    }()
    
    private let eggView: NetworkImageView = {
        let view = NetworkImageView()
        view.cornerRadius = 4
        view.contentMode = .center
        view.addSizeConstraint(size: 50)
        view.clipsToBounds = false
        return view
    }()
    private let eggCountView: PillView = {
        let view = PillView(frame: CGRect(x: 34, y: -8, width: 24, height: 24))
        view.isCircular = true
        return view
    }()
    private let potionView: NetworkImageView = {
        let view = NetworkImageView()
        view.addSizeConstraint(size: 50)
        view.cornerRadius = 4
        view.contentMode = .center
        view.clipsToBounds = false
        return view
    }()
    private let potionCountView: PillView = {
        let view = PillView(frame: CGRect(x: 34, y: -8, width: 24, height: 24))
        view.isCircular = true
        return view
    }()
    private let petView: NetworkImageView = {
        let view = NetworkImageView()
        view.addSizeConstraint(size: 68)
        view.cornerRadius = 4
        view.contentMode = .center
        return view
    }()
    
    private let petTitleLabel: UILabel = {
        let label = UILabel()
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.addHeightConstraint(height: 21)
        return label
    }()
    private let descriptionlabel: UILabel = {
        let label = UILabel()
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 14)
        label.numberOfLines = 3
        label.addHeightConstraint(height: 60)
        label.textAlignment = .center
        return label
    }()
    
    convenience init(item: PetStableItem, ownedEggs: OwnedItemProtocol?, ownedPotions: OwnedItemProtocol?) {
        self.init()
        let eggCount = ownedEggs?.numberOwned ?? 0
        let potionCount = ownedPotions?.numberOwned ?? 0
        eggCountView.text = String(eggCount)
        eggCountView.isHidden = eggCount == 0
        potionCountView.text = String(potionCount)
        potionCountView.isHidden = potionCount == 0
        eggView.setImagewith(name: "Pet_Egg_\(item.pet?.egg ?? "")")
        potionView.setImagewith(name: "Pet_HatchingPotion_\(item.pet?.potion ?? "")")
        petTitleLabel.text = item.pet?.text
        if item.canRaise {
            title = L10n.hatchPet
            ImageManager.getImage(name: "stable_Pet-\(item.pet?.key ?? "")") {[weak self] (image, _) in
                self?.petView.image = image?.withRenderingMode(.alwaysTemplate)
            }
            if eggCount == 0 && potionCount == 0 {
                descriptionlabel.text = L10n.suggestPetHatchMissingBoth(item.pet?.egg ?? "", item.pet?.potion ?? "")
            } else if eggCount == 0 {
                descriptionlabel.text = L10n.suggestPetHatchMissingEgg(item.pet?.egg ?? "")
            } else if potionCount == 0 {
                descriptionlabel.text = L10n.suggestPetHatchMissingPotion(item.pet?.potion ?? "")
            } else {
                descriptionlabel.text = L10n.canHatchPet(item.pet?.egg ?? "", item.pet?.potion ?? "")
            }
        } else {
            title = L10n.hatchPetAgain
            petView.setImagewith(name: "stable_Pet-\(item.pet?.key ?? "")")
            petView.alpha = 0.5
            if eggCount == 0 && potionCount == 0 {
                descriptionlabel.text = L10n.suggestPetHatchAgainMissingBoth(item.pet?.egg ?? "", item.pet?.potion ?? "")
            } else if eggCount == 0 {
                descriptionlabel.text = L10n.suggestPetHatchAgainMissingEgg(item.pet?.egg ?? "")
            } else if potionCount == 0 {
                descriptionlabel.text = L10n.suggestPetHatchAgainMissingPotion(item.pet?.potion ?? "")
            } else {
                descriptionlabel.text = L10n.canHatchPet(item.pet?.egg ?? "", item.pet?.potion ?? "")
            }
        }
        
        if eggCount > 0 && potionCount > 0 {
            addAction(title: L10n.hatch, isMainAction: true) { _ in
                self.inventoryRepository.hatchPet(egg: ownedEggs?.key, potion: ownedPotions?.key).observeCompleted {
                }
            }
            addCloseAction()
        } else {
            addAction(title: L10n.close, isMainAction: true)
            
            inventoryRepository.getItems(keys: [ItemType.eggs: [item.pet?.egg ?? ""], ItemType.hatchingPotions: [item.pet?.potion ?? ""]]).take(first: 1).on(value: { items in
                let egg = items.eggs.value.first
                let potion = items.hatchingPotions
                var hatchValue = self.getItemPrice(pet: item.pet, item: egg, hasUnlocked: ownedEggs != nil)
                hatchValue += self.getItemPrice(pet: item.pet, item: potion, hasUnlocked: ownedPotions != nil)
                
                if hatchValue > 0 {
                    self.addAction(title: L10n.hatch, isMainAction: false) { _ in
                        var signal = SignalProducer<UserProtocol?, Never> { (observable, lifetime) in
                            observable.send(Signal.Event.value(nil))
                            observable.sendCompleted()
                        }
                        if eggCount == 0 {
                            signal = signal.flatMap(.latest, { _ -> Signal<UserProtocol?, Never> in
                                return self.inventoryRepository.purchaseItem(purchaseType: "eggs", key: item.pet?.egg ?? "", value: 4, quantity: 1, text: item.pet?.egg ?? "")
                            })
                        }
                        if potionCount == 0 {
                            signal = signal.flatMap(.latest, { _ -> Signal<UserProtocol?, Never> in
                                return self.inventoryRepository.purchaseItem(purchaseType: "hatchingPotions", key: item.pet?.potion ?? "", value: 4, quantity: 1, text: item.pet?.potion ?? "")
                            })
                        }
                        
                        signal.flatMap(.latest, { _ in
                            return self.inventoryRepository.hatchPet(egg: item.pet?.egg, potion: item.pet?.potion)
                        }).start()
                    }
                }
            }).start()
        }
        
        setupView()
    }
    
    private func getItemPrice(pet: PetProtocol?, item: ItemProtocol?, hasUnlocked: Bool) -> Int {
            if pet?.type == "drop" || (pet?.type == "quest" && hasUnlocked) {
                return Int(item?.value ?? 0.0)
            }
            return 0
        }
    
    private func setupView() {
        contentView = stackView
        stackView.addArrangedSubview(imageStackView)
        imageStackView.addArrangedSubview(eggView)
        eggView.addSubview(eggCountView)
        imageStackView.addArrangedSubview(petView)
        potionView.addSubview(potionCountView)
        imageStackView.addArrangedSubview(potionView)
        let spacer = UIView()
        spacer.addHeightConstraint(height: 17)
        stackView.addArrangedSubview(spacer)
        stackView.addArrangedSubview(petTitleLabel)
        stackView.addArrangedSubview(descriptionlabel)
        
        stackView.setNeedsUpdateConstraints()
        stackView.setNeedsLayout()
        view.setNeedsLayout()
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        petView.tintColor = theme.dimmedColor

        eggView.backgroundColor = theme.windowBackgroundColor
        eggCountView.pillColor = theme.offsetBackgroundColor
        eggCountView.textColor = theme.primaryTextColor
        petView.backgroundColor = theme.windowBackgroundColor
        potionCountView.pillColor = theme.offsetBackgroundColor
        potionCountView.textColor = theme.primaryTextColor
        potionView.backgroundColor = theme.windowBackgroundColor
        
        petTitleLabel.textColor = theme.primaryTextColor
        descriptionlabel.textColor = theme.secondaryTextColor
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stackView.setNeedsUpdateConstraints()
        stackView.setNeedsLayout()
    }
}
