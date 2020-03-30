//
//  ImageView-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Kingfisher

extension ImageView {
    
    func setImagewith(name: String?, extension fileExtension: String = "", completion: ((UIImage?, NSError?) -> Void)? = nil) {
        if let name = name {
            ImageManager.setImage(on: self, name: name, extension: fileExtension, completion: completion)
        }
    }
    
    func setShopImagewith(name: String?, extension fileExtension: String = "", completion: ((UIImage?, NSError?) -> Void)? = nil) {
        if let name = name {
            ImageManager.setImage(on: self, name: "shop_\(name)", extension: fileExtension, completion: completion)
        }
    }
    
}
