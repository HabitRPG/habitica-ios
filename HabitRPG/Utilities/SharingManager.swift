//
//  SharingManager.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.08.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation

class SharingManager {
    static func share(items: [Any], presentingViewController: UIViewController, sourceView: UIView?) {
        let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        avc.popoverPresentationController?.sourceView = sourceView ?? presentingViewController.view
        presentingViewController.present(avc, animated: true, completion: nil)
    }
}
