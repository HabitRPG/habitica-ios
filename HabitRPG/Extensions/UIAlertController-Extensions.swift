// https://github.com/kickstarter/ios-oss/blob/master/Library/UIAlertController.swift

import UIKit
import FBSDKLoginKit

public extension UIAlertController {

    @objc
    public static func alert(title: String? = nil,
                             message: String? = nil,
                             handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction.okAction())

        return alertController
    }

    public static func genericError(message: String, title: String = NSLocalizedString("Error", comment: "")) -> UIAlertController {
        let alertController = UIAlertController(
            title: title.localized,
            message: message.localized,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction.okAction())

        return alertController
    }

    public func setSourceInCenter(_ view: UIView) {
        if let popoverController = popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
    }
}
