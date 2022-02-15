//
//  NetworkImageView.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.08.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import Kingfisher

class NetworkImageView: AnimatedImageView {
    var loadedImageName: String?
    
    func setImagewith(name: String?, extension fileExtension: String = "", completion: ((UIImage?, NSError?) -> Void)? = nil) {
        accessibilityIgnoresInvertColors = true
        if let name = name {
            ImageManager.setImage(on: self, name: name, extension: fileExtension, completion: completion)
        }
    }
    
    func setShopImagewith(name: String?, extension fileExtension: String = "", completion: ((UIImage?, NSError?) -> Void)? = nil) {
        accessibilityIgnoresInvertColors = true
        if let name = name {
            ImageManager.setImage(on: self, name: "shop_\(name)", extension: fileExtension, completion: completion)
        }
    }
    
}
