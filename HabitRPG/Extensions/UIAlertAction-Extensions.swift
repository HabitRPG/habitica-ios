//
//  UIAlertAction-Extensions.swift
//  Habitica
//
//  Created by Phillip on 14.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

extension UIAlertAction {
    
    static func cancelAction(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {(action) in
            if let clickHandler = handler {
                clickHandler(action)
            }
        })
    }
    
    static func okAction(handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {(action) in
            if let clickHandler = handler {
                clickHandler(action)
            }
        })
    }
    
}
