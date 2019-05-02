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
    
    @objc
    static func setImage(on imageView: ImageView, name: String, extension fileExtension: String = "png", completion: ((UIImage?, NSError?) -> Void)? = nil) {
        getImage(name: name, extension: fileExtension) { (image, error) in
            imageView.image = image
            if let action = completion {
                action(image, error)
            }
        }
    }
    
    @objc
    static func getImage(name: String, extension fileExtension: String = "png", completion: @escaping (UIImage?, NSError?) -> Void) {
        guard let url = URL(string: "\(baseURL)\(name).\(fileExtension)") else {
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
}
