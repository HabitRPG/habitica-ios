//
//  Avatar.swift
//  Habitica
//
//  Created by Phillip Thelen on 07.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
protocol Avatar {

    var background: String? { get }
    var chair: String? { get }
    var back: String? { get }
    var skin: String? { get }
    var shirt: String? { get }
    var armor: String? { get }
    var body: String? { get }
    var hairColor: String? { get }
    var hairBase: String? { get }
    var hairBangs: String? { get }
    var hairMustache: String? { get }
    var hairBeard: String? { get }
    var eyewear: String? { get }
    var head: String? { get }
    var headAccessory: String? { get }
    var hairFlower: String? { get }
    var shield: String? { get }
    var weapon: String? { get }
    var visualBuff: String? { get }
    var mount: String? { get }
    var knockout: String? { get }
    var pet: String? { get }

    var isSleep: Bool { get }
    var size: String { get }
}

extension Avatar {
    
    private func isValid(_ value: String?) -> Bool {
        return value?.count ?? 0 > 0
    }
    
    private func isAvailableGear(_ value: String?) -> Bool {
        return value?.contains("base_0") != true
    }
    
    func getViewDictionary(showsBackground: Bool, showsMount: Bool, showsPet: Bool, isFainted: Bool) -> [String: Bool] {
        return [
            "background": showsBackground && isValid(background),
            "mount-body": showsMount && isValid(mount),
            "chair": isValid(chair) && chair != "none",
            "back": isValid(back) && isAvailableGear(back),
            "skin": isValid(skin),
            "shirt": isValid(shirt),
            "armor": isValid(armor) && isAvailableGear(armor),
            "body": isValid(body) && isAvailableGear(body),
            "head_0": true,
            "hair-base": isValid(hairBase) && hairBase != "0",
            "hair-bangs": isValid(hairBangs) && hairBangs != "0" ,
            "hair-mustache": isValid(hairMustache) && hairMustache != "0",
            "hair-beard": isValid(hairBeard) && hairBeard != "0",
            "eyewear": isValid(eyewear) && isAvailableGear(eyewear),
            "head": isValid(head) && isAvailableGear(head),
            "head-accessory": isValid(headAccessory) && isAvailableGear(headAccessory),
            "hair-flower": isValid(hairFlower) && hairFlower != "0",
            "shield": isValid(shield) && isAvailableGear(shield),
            "weapon": isValid(weapon) && isAvailableGear(weapon),
            "visual-buff": isValid(visualBuff),
            "mount-head": showsMount && isValid(mount),
            "zzz": isSleep,
            "knockout": isFainted,
            "pet": showsPet && isValid(pet)
        ]
    }
    
    func getFilenameDictionary() -> [String: String?] {
        return [
            "background": "background_\(background ?? "")",
            "mount-body": "Mount_Body_\(mount ?? "")",
            "chair": "chair_\(chair ?? "")",
            "back": back,
            "skin": isSleep ? "skin_\(skin ?? "")_sleep" : "skin_\(skin ?? "")",
            "shirt": "\(size)_shirt_\( shirt ?? "")",
            "armor": "\(size)_\(armor ?? "")",
            "body": body,
            "head_0": "head_0",
            "hair-base": "hair_base_\(hairBase ?? "")_\(hairColor ?? "")",
            "hair-bangs": "hair_bangs_\(hairBangs ?? "")_\(hairColor ?? "")",
            "hair-mustache": "hair_mustache_\(hairMustache ?? "")_\(hairColor ?? "")",
            "hair-beard": "hair_beard_\(hairBeard ?? "")_\(hairColor ?? "")",
            "eyewear": eyewear,
            "head": head,
            "head-accessory": headAccessory ?? "",
            "hair-flower": "hair_flower_\(hairFlower ?? "")",
            "shield": shield,
            "weapon": weapon,
            "visual-buff": visualBuff,
            "mount-head": "Mount_Head_\(mount ?? "")",
            "zzz": "zzz",
            "pet": "Pet-\(pet ?? "")"
        ]
    }
}

extension User: Avatar {

    private var displayedOutfit: Outfit {
        if preferences.useCostume?.boolValue == true {
            return costume
        } else {
            return equipped
        }
    }
    
    var background: String? {
        return preferences.background
    }
    var chair: String? {
        return preferences.chair
    }
    
    var back: String? {
        return displayedOutfit.back
    }
    
    var skin: String? {
        return preferences.skin
    }
    
    var shirt: String? {
        return preferences.shirt
    }
    
    var armor: String? {
        return displayedOutfit.armor
    }
    
    var body: String? {
        return displayedOutfit.body
    }
    
    var hairColor: String? {
        return preferences.hairColor
    }
    
    var hairBase: String? {
        return preferences.hairBase
    }
    
    var hairBangs: String? {
        return preferences.hairBangs
    }
    
    var hairMustache: String? {
        return preferences.hairMustache
    }
    
    var hairBeard: String? {
        return preferences.hairBeard
    }
    
    var eyewear: String? {
        return displayedOutfit.eyewear
    }
    
    var head: String? {
        return displayedOutfit.head
    }
    
    var headAccessory: String? {
        return displayedOutfit.headAccessory
    }
    
    var hairFlower: String? {
        return preferences.hairFlower
    }
    
    var shield: String? {
        return displayedOutfit.shield
    }
    
    var weapon: String? {
        return displayedOutfit.weapon
    }
    
    var visualBuff: String? {
        return nil
    }
    
    var mount: String? {
        return currentMount
    }
    
    var knockout: String? {
        return nil
    }
    
    var pet: String? {
        return currentPet
    }
    
    var isSleep: Bool {
        return preferences.sleep?.boolValue ?? false
    }
    
    var size: String {
        return preferences.size ?? ""
    }
}
