// https://github.com/kickstarter/ios-oss/blob/master/Library/UIAlertController.swift

import UIKit
import FBSDKLoginKit

public extension UIAlertController {
    
    public static func alert(title: String? = nil,
                             message: String? = nil,
                             handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(
                title: "OK".localized,
                style: .cancel,
                handler: handler
            )
        )
        
        return alertController
    }
    
    public static func genericError(message: String, title: String = "Error") -> UIAlertController {
        let alertController = UIAlertController(
            title: title.localized,
            message: message.localized,
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(
                title: "OK".localized,
                style: .cancel,
                handler: nil
            )
        )
        
        return alertController
    }

}
