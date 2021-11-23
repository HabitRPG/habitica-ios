//
//  UIImage-Extensions.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.08.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation

extension UIImage {
    class func from(color: UIColor, size: CGRect? = nil) -> UIImage? {
        let rect = size ?? CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        context?.setFillColor(color.cgColor)
        context?.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
    
    func inverted() -> UIImage? {
        if let filter = CIFilter(name: "CIColorInvert") {
            filter.setDefaults()
            filter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
            if let image = filter.outputImage {
                let context = CIContext()
                if let cgImage = context.createCGImage(image, from: image.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        return nil
    }
    
    // Resizable UIImage with max width/height from: https://stackoverflow.com/questions/24709244/how-do-set-a-width-and-height-of-an-image-in-swift
    func resize(maxWidthHeight: Double) -> UIImage? {
        let actualHeight = Double(size.height)
        let actualWidth = Double(size.width)
        var maxWidth = 0.0
        var maxHeight = 0.0

        if actualWidth > actualHeight {
            maxWidth = maxWidthHeight
            let per = (100.0 * maxWidthHeight / actualWidth)
            maxHeight = (actualHeight * per) / 100.0
        } else {
            maxHeight = maxWidthHeight
            let per = (100.0 * maxWidthHeight / actualHeight)
            maxWidth = (actualWidth * per) / 100.0
        }

        let hasAlpha = true
        let scale: CGFloat = 0.0

        UIGraphicsBeginImageContextWithOptions(CGSize(width: maxWidth, height: maxHeight), !hasAlpha, scale)
        self.draw(in: CGRect(origin: .zero, size: CGSize(width: maxWidth, height: maxHeight)))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return scaledImage
    }
}
