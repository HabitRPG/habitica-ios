//
//  SetupCustomization.swift
//  Habitica
//
//  Created by Phillip on 03.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import Foundation

public class SetupCustomization {
    
    let key: String
    let path: String
    let text: String?
    let category: AvatarCustomizationCategory
    let subcategory: AvatarCustomizationSubcategory
    var color: UIColor?
    var icon: UIImage?
    
    init(key: String, path: String, text: String?, category: AvatarCustomizationCategory, subcategory: AvatarCustomizationSubcategory, color: UIColor?) {
        self.key = key
        self.path = path
        self.text = text
        self.category = category
        self.subcategory = subcategory
        self.color = color
    }
    
    init(key: String, path: String, text: String?, category: AvatarCustomizationCategory, subcategory: AvatarCustomizationSubcategory, icon: UIImage?) {
        self.key = key
        self.path = path
        self.text = text
        self.category = category
        self.subcategory = subcategory
        self.icon = icon
    }
    
    static func createSize(key: String, icon: UIImage?, text: String) -> SetupCustomization {
        return SetupCustomization(key: key, path: "size", text: text, category: .body, subcategory: .size, icon: icon)
    }
    
    static func createShirt(key: String, icon: UIImage?) -> SetupCustomization {
        return SetupCustomization(key: key, path: "shirt", text: nil, category: .body, subcategory: .shirt, icon: icon)
    }
    
    static func createSkin(key: String, color: UIColor?) -> SetupCustomization {
        return SetupCustomization(key: key, path: "skin", text: nil, category: .skin, subcategory: .color, color: color)
    }
    
    static func createHairColor(key: String, color: UIColor?) -> SetupCustomization {
        return SetupCustomization(key: key, path: "hair.color", text: nil, category: .hair, subcategory: .color, color: color)
    }
    
    static func createBangs(key: String, icon: UIImage?) -> SetupCustomization {
        return SetupCustomization(key: key, path: "hair.bangs", text: nil, category: .hair, subcategory: .bangs, icon: icon)
    }
    
    static func createPonytails(key: String, icon: UIImage?) -> SetupCustomization {
        return SetupCustomization(key: key, path: "hair.base", text: nil, category: .hair, subcategory: .ponytail, icon: icon)
    }
    
    static func createGlasses(key: String, icon: UIImage?) -> SetupCustomization {
        return SetupCustomization(key: key, path: "glasses", text: nil, category: .extras, subcategory: .glasses, icon: icon)
    }
    
    static func createFlower(key: String, icon: UIImage?) -> SetupCustomization {
        return SetupCustomization(key: key, path: "hair.flower", text: nil, category: .extras, subcategory: .flower, icon: icon)
    }
    
    static func createWheelchair(key: String, icon: UIImage?) -> SetupCustomization {
        return SetupCustomization(key: key, path: "chair", text: nil, category: .extras, subcategory: .wheelchair, icon: icon)
    }
}
