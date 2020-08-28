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
}
