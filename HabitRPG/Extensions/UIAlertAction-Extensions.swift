//
//  UIAlertAction-Extensions.swift
//  Habitica
//
//  Created by Phillip on 14.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

extension UIAlertAction {
    
    @objc
    static func cancelAction(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: L10n.cancel, style: .cancel, handler: {(action) in
            if let clickHandler = handler {
                clickHandler(action)
            }
        })
    }
    
    @objc
    static func okAction(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: L10n.ok, style: .default, handler: {(action) in
            if let clickHandler = handler {
                clickHandler(action)
            }
        })
    }
    
}
