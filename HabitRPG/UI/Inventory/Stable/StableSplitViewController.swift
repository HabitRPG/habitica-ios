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
    @IBOutlet weak var organizeByButton: UIBarButtonItem!
    
    private var petViewController: PetOverviewViewController?
    private var mountViewController: MountOverviewViewController?
    
    private var organizeByColor = false {
        didSet {
            petViewController?.organizeByColor = organizeByColor
            mountViewController?.organizeByColor = organizeByColor
        }
    }
    
    override func viewDidLoad() {
        canShowAsSplitView = false
        super.viewDidLoad()
        
        for childViewController in children {
            if let viewController = childViewController as? PetOverviewViewController {
                petViewController = viewController
            }
            if let viewController = childViewController as? MountOverviewViewController {
                mountViewController = viewController
            }
        }
        
        Analytics.logEvent("open_stable", parameters: nil)
    }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.stable
        segmentedControl.setTitle(L10n.pets, forSegmentAt: 0)
        segmentedControl.setTitle(L10n.mounts, forSegmentAt: 1)
        organizeByButton.title = L10n.organizeBy
    }
    
    @IBAction func changeOrganizeBy(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: L10n.Stable.color, style: .default, handler: {[weak self] _ in
            self?.organizeByColor = true
        }))
        actionSheet.addAction(UIAlertAction(title: L10n.Stable.type, style: .default, handler: {[weak self] _ in
            self?.organizeByColor = false
        }))
        present(actionSheet, animated: true, completion: nil)
    }
}
