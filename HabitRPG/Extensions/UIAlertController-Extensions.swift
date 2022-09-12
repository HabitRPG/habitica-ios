// https://github.com/kickstarter/ios-oss/blob/master/Library/UIAlertController.swift

import UIKit

public extension UIAlertController {

    @objc
    static func alert(title: String? = nil,
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

    static func genericError(message: String, title: String = L10n.Errors.error) -> UIAlertController {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction.okAction())

        return alertController
    }

    @objc
    func setSourceInCenter(_ view: UIView) {
        if let popoverController = popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
    }
}
