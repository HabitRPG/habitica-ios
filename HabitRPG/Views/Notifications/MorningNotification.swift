//
//  MorningNotification.swift
//  Habitica
//
//  Created by Phillip on 12.06.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import Foundation

class MorningNotificationwait: HRPGBaseNotificationView {

    var sharedManager: HRPGManager?

    //swiftlint:disable:next force_unwrapping
    override func displayNotification(_ completionBlock: (() -> Void)!) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            if let sharedManager = self.sharedManager {
                YesterdailiesDialogView.showDialog(sharedManager: sharedManager)
            }
        }
    }
}
