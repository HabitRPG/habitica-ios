//
//  SetupCustomizationRepository.swift
//  Habitica
//
//  Created by Phillip on 03.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation

class SetupCustomizationRepository {
    
    static func getCustomizations(category: AvatarCustomizationCategory, user: User) -> [SetupCustomization] {
        return getCustomizations(category: category, subcategory: nil, user: user)
    }
    
    static func getCustomizations(category: AvatarCustomizationCategory, subcategory: AvatarCustomizationSubcategory?, user: User) -> [SetupCustomization] {
        switch category {
        case .body:
            return getBodyCustomizations(subcategory: subcategory, user: user)
        case .skin:
            return getSkins()
        case .hair:
            return getHairCustomizations(subcategory: subcategory, user: user)
        case .extras:
            return getExtrasCustomizations(subcategory: subcategory, user: user)
        }
    }
    
    static private func getBodyCustomizations(subcategory: AvatarCustomizationSubcategory?, user: User) -> [SetupCustomization] {
        switch subcategory {
        case .some(.shirt):
            return getShirts(size: user.preferences?.size)
        case .some(.size):
            return getSizes()
        default:
            return Array()
        }
    }

    static private func getHairCustomizations(subcategory: AvatarCustomizationSubcategory?, user: User) -> [SetupCustomization] {
        switch subcategory {
        case .some(.bangs):
            return getBangs(color: user.preferences?.hairColor)
        case .some(.ponytail):
            return getPonytails(color: user.preferences?.hairColor)
        case .some(.color):
            return getHairColors()
        default:
            return Array()
        }
    }
    
    static private func getExtrasCustomizations(subcategory: AvatarCustomizationSubcategory?, user: User) -> [SetupCustomization] {
        switch subcategory {
        case .some(.wheelchair):
            return getWheelchairs()
        case .some(.glasses):
            return getGlasses()
        case .some(.flower):
            return getFlowers()
        default:
            return Array()
        }
    }
    
    private static func getShirts(size: String?) -> [SetupCustomization] {
        if let userSize = size {
            if userSize == "slin" {
                return [
                    SetupCustomization.createShirt(key: "black", icon: #imageLiteral(resourceName: "creator_slim_shirt_black")),
                    SetupCustomization.createShirt(key: "blue", icon: #imageLiteral(resourceName: "creator_slim_shirt_blue")),
                    SetupCustomization.createShirt(key: "green", icon: #imageLiteral(resourceName: "creator_slim_shirt_green")),
                    SetupCustomization.createShirt(key: "pink", icon: #imageLiteral(resourceName: "creator_slim_shirt_pink")),
                    SetupCustomization.createShirt(key: "white", icon: #imageLiteral(resourceName: "creator_slim_shirt_white")),
                    SetupCustomization.createShirt(key: "yellow", icon: #imageLiteral(resourceName: "creator_slim_shirt_yellow"))
                ]
            }
        }
        return [
            SetupCustomization.createShirt(key: "black", icon: #imageLiteral(resourceName: "creator_broad_shirt_black")),
            SetupCustomization.createShirt(key: "blue", icon: #imageLiteral(resourceName: "creator_broad_shirt_blue")),
            SetupCustomization.createShirt(key: "green", icon: #imageLiteral(resourceName: "creator_broad_shirt_green")),
            SetupCustomization.createShirt(key: "pink", icon: #imageLiteral(resourceName: "creator_broad_shirt_pink")),
            SetupCustomization.createShirt(key: "white", icon: #imageLiteral(resourceName: "creator_broad_shirt_white")),
            SetupCustomization.createShirt(key: "yellow", icon: #imageLiteral(resourceName: "creator_broad_shirt_yellow"))
        ]
    }
    
    private static func getSizes() -> [SetupCustomization] {
        return [
            SetupCustomization.createSize(key: "slim", icon: #imageLiteral(resourceName: "creator_slim_shirt_white"), text: NSLocalizedString("Slim", comment: "")),
            SetupCustomization.createSize(key: "broad", icon: #imageLiteral(resourceName: "creator_broad_shirt_white"), text: NSLocalizedString("Broad", comment: ""))
        ]
    }
    
    private static func getSkins() -> [SetupCustomization] {
        return [
            SetupCustomization.createSkin(key: "915533", color: UIColor("#915533") ),
            SetupCustomization.createSkin(key: "ddc994", color: UIColor("#ddc994") ),
            SetupCustomization.createSkin(key: "f5a76e", color: UIColor("#f5a76e") ),
            SetupCustomization.createSkin(key: "ea8349", color: UIColor("#ea8349") ),
            SetupCustomization.createSkin(key: "c06534", color: UIColor("#c06534") ),
            SetupCustomization.createSkin(key: "98461a", color: UIColor("#98461a") ),
            SetupCustomization.createSkin(key: "c3e1dc", color: UIColor("#c3e1dc") ),
            SetupCustomization.createSkin(key: "6bd049", color: UIColor("#6bd049") )
        ]
    }
    
    private static func getBangs(color: String?) -> [SetupCustomization] {
        let hairColor = color ?? "red"
        return [
            SetupCustomization.createBangs(key: "0", icon: #imageLiteral(resourceName: "creator_blank_face")),
            SetupCustomization.createBangs(key: "1", icon: UIImage(named: "creator_hair_bangs_1_"+hairColor)),
            SetupCustomization.createBangs(key: "2", icon: UIImage(named: "creator_hair_bangs_2_"+hairColor)),
            SetupCustomization.createBangs(key: "3", icon: UIImage(named: "creator_hair_bangs_3_"+hairColor))
        ]
    }
    
    private static func getPonytails(color: String?) -> [SetupCustomization] {
        let hairColor = color ?? "red"
        return [
            SetupCustomization.createPonytails(key: "0", icon: #imageLiteral(resourceName: "creator_blank_face")),
            SetupCustomization.createPonytails(key: "1", icon: UIImage(named: "creator_hair_base_1_"+hairColor)),
            SetupCustomization.createPonytails(key: "3", icon: UIImage(named: "creator_hair_base_3_"+hairColor))
        ]
    }
    
    private static func getHairColors() -> [SetupCustomization] {
        return [
            SetupCustomization.createHairColor(key: "white", color: UIColor("#DEDEDE")),
            SetupCustomization.createHairColor(key: "brown", color: UIColor("#903A00")),
            SetupCustomization.createHairColor(key: "blond", color: UIColor("#CFA925")),
            SetupCustomization.createHairColor(key: "red", color: UIColor("#EC720E")),
            SetupCustomization.createHairColor(key: "black", color: UIColor("#313131"))
        ]
    }
    
    private static func getFlowers() -> [SetupCustomization] {
        return [
            SetupCustomization.createFlower(key: "0", icon: #imageLiteral(resourceName: "creator_blank_face")),
            SetupCustomization.createFlower(key: "1", icon: #imageLiteral(resourceName: "creator_hair_flower_1")),
            SetupCustomization.createFlower(key: "2", icon: #imageLiteral(resourceName: "creator_hair_flower_2")),
            SetupCustomization.createFlower(key: "3", icon: #imageLiteral(resourceName: "creator_hair_flower_3")),
            SetupCustomization.createFlower(key: "4", icon: #imageLiteral(resourceName: "creator_hair_flower_4")),
            SetupCustomization.createFlower(key: "5", icon: #imageLiteral(resourceName: "creator_hair_flower_5")),
            SetupCustomization.createFlower(key: "6", icon: #imageLiteral(resourceName: "creator_hair_flower_6"))
        ]
    }
    
    private static func getWheelchairs() -> [SetupCustomization] {
        return [
            SetupCustomization.createWheelchair(key: "none", icon: nil),
            SetupCustomization.createWheelchair(key: "black", icon: #imageLiteral(resourceName: "creator_chair_black")),
            SetupCustomization.createWheelchair(key: "blue", icon: #imageLiteral(resourceName: "creator_chair_blue")),
            SetupCustomization.createWheelchair(key: "green", icon: #imageLiteral(resourceName: "creator_chair_green")),
            SetupCustomization.createWheelchair(key: "pink", icon: #imageLiteral(resourceName: "creator_chair_pink")),
            SetupCustomization.createWheelchair(key: "red", icon: #imageLiteral(resourceName: "creator_chair_red")),
            SetupCustomization.createWheelchair(key: "yellow", icon: #imageLiteral(resourceName: "creator_chair_yellow"))
        ]
    }
    
    private static func getGlasses() -> [SetupCustomization] {
        return [
            SetupCustomization.createGlasses(key: "", icon: #imageLiteral(resourceName: "creator_blank_face")),
            SetupCustomization.createGlasses(key: "eyewear_special_blackTopFrame", icon: #imageLiteral(resourceName: "creator_eyewear_special_blacktopframe")),
            SetupCustomization.createGlasses(key: "eyewear_special_blueTopFrame", icon: #imageLiteral(resourceName: "creator_eyewear_special_bluetopframe")),
            SetupCustomization.createGlasses(key: "eyewear_special_greenTopFrame", icon: #imageLiteral(resourceName: "creator_eyewear_special_greentopframe")),
            SetupCustomization.createGlasses(key: "eyewear_special_pinkTopFrame", icon: #imageLiteral(resourceName: "creator_eyewear_special_pinktopframe")),
            SetupCustomization.createGlasses(key: "eyewear_special_redTopFrame", icon: #imageLiteral(resourceName: "creator_eyewear_special_redtopframe")),
            SetupCustomization.createGlasses(key: "eyewear_special_yellowTopFrame", icon: #imageLiteral(resourceName: "creator_eyewear_special_yellowtopframe"))
        ]
    }
  }
