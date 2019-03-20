//
//  StableSplitViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import FirebaseAnalytics

class StableSplitViewController: HabiticaSplitViewController {

    override func viewDidLoad() {
        canShowAsSplitView = false
        super.viewDidLoad()
        segmentedControl.setTitle(L10n.pets, forSegmentAt: 0)
        segmentedControl.setTitle(L10n.mounts, forSegmentAt: 1)
        
        Analytics.logEvent("open_stable", parameters: nil)
    }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.stable
    }
}
