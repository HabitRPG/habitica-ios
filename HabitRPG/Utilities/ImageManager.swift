//
//  ImageManager.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Kingfisher

@objc
class ImageManager: NSObject {
    static let baseURL = "https://habitica-assets.s3.amazonaws.com/mobileApp/images/"
    
    private static let formatDictionary = [
        "head_special_0": "gif",
        "head_special_1": "gif",
        "shield_special_0": "gif",
        "weapon_special_0": "gif",
        "slim_armor_special_0": "gif",
        "slim_armor_special_1": "gif",
        "broad_armor_special_0": "gif",
        "broad_armor_special_1": "gif",
        "weapon_special_critical": "gif",
        "Pet-Wolf-Cerberus": "gif",
        "armor_special_ks2019": "gif",
        "slim_armor_special_ks2019": "gif",
        "broad_armor_special_ks2019": "gif",
        "eyewear_special_ks2019": "gif",
        "head_special_ks2019": "gif",
        "shield_special_ks2019": "gif",
        "weapon_special_ks2019": "gif",
        "Pet-Gryphon-Gryphatrice": "gif",
        "Mount_Head_Gryphon-Gryphatrice": "gif",
        "Mount_Body_Gryphon-Gryphatrice": "gif",
        "background_clocktower": "gif",
        "background_airship": "gif",
        "background_steamworks": "gif",
        "Pet_HatchingPotion_Veggie": "gif",
        "Pet_HatchingPotion_Dessert": "gif",
        "Pet-HatchingPotion-Dessert": "gif",
        "quest_windup": "gif",
        "Pet-HatchingPotion_Windup": "gif",
        "Pet_HatchingPotion_Windup": "gif",
        "Pet-HatchingPotion-Windup": "gif"
    ]
    
    @objc
    static func setImage(on imageView: NetworkImageView, name: String, extension fileExtension: String = "", completion: ((UIImage?, NSError?) -> Void)? = nil) {
        if imageView.loadedImageName != name {
            imageView.image = nil
        }
        imageView.loadedImageName = name
        getImage(name: name, extension: fileExtension) { (image, error) in
            if imageView.loadedImageName == name {
                imageView.image = image
                if let action = completion {
                    action(image, error)
                }
            }
        }
    }
    
    @objc
    static func getImage(name: String, extension fileExtension: String = "", completion: @escaping (UIImage?, NSError?) -> Void) {
        guard let url = URL(string: "\(baseURL)\(name).\(getFormat(name: name, format: fileExtension))") else {
            return
        }
        KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) { (image, error, _, _) in
            if let error = error {
                print("Image loading error:", name, error.localizedDescription)
            }
            completion(image, error)
        }
    }
    
    @objc
    static func getImage(url urlString: String, completion: @escaping (UIImage?, NSError?) -> Void) {
        guard let url = URL(string: urlString) else {
            return
        }
        KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) { (image, error, _, _) in
            if let error = error {
                print("Image loading error:", url, error.localizedDescription)
            }
            completion(image, error)
        }
    }
    
    @objc
    static func clearImageCache() {
        ImageCache.default.clearDiskCache()
        ImageCache.default.clearMemoryCache()
    }
    
    private static func getFormat(name: String, format: String) -> String {
        if !format.isEmpty {
            return format
        }
        return formatDictionary[name] ?? "png"
    }

    private static func substituteSprite(name: String?) -> String? {
        for (key, value) in substitutions {
            if let keyString = key as? String, name?.contains(keyString) == true {
                return value as? String
            }
        }
        return name
    }
    
    static var substitutions = ConfigRepository().dictionary(variable: .spriteSubstitutions)
}
