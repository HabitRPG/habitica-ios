//
//  SharingManager.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.08.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import UIKit
#if !targetEnvironment(macCatalyst)
import FirebaseAnalytics
#endif

class SharingManager {
    static func share(identifier: String, items: [Any], presentingViewController: UIViewController?, sourceView: UIView?) {
        guard let viewController = presentingViewController ?? UIApplication.topViewController() else {
            return
        }
        
        var sharedItems = [Any]()
        
        for item in items {
            if let image = item as? UIImage, let newImage = addSharingBanner(inImage: image) {
                sharedItems.append(newImage)
            } else {
                sharedItems.append(item)
            }
        }
        
        let avc = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
        avc.popoverPresentationController?.sourceView = sourceView ?? viewController.view
        viewController.present(avc, animated: true, completion: nil)
        #if !targetEnvironment(macCatalyst)
        Analytics.logEvent("shared", parameters: ["identifier": identifier])
        #endif
    }
    
    static func addSharingBanner(inImage image: UIImage) -> UIImage? {
        let textColor = UIColor.white
        let bannerHeight: CGFloat = 18

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(CGSize(width: image.size.width, height: image.size.height + bannerHeight), false, scale)
        if let context = UIGraphicsGetCurrentContext() {
            
            context.setFillColor(UIColor.white.cgColor)
            context.addRect(CGRect(origin: CGPoint.zero, size: image.size))
            context.drawPath(using: .fill)
            context.setFillColor(UIColor.purple300.cgColor)
            context.addRect(CGRect(origin: CGPoint(x: 0, y: image.size.height), size: CGSize(width: image.size.width, height: bannerHeight)))
            context.drawPath(using: .fill)
        
            let textFontAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10),
                NSAttributedString.Key.foregroundColor: textColor
                ] as [NSAttributedString.Key: Any]
            image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

            let logo = Asset.wordmarkWhite.image
            let width = logo.size.width / (logo.size.height / bannerHeight)
            logo.draw(in: CGRect(x: image.size.width - width - 1, y: image.size.height, width: width, height: bannerHeight))
        }
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

}
