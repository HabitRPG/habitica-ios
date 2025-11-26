//
//  StableSplitViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class StableSplitViewController: HabiticaSplitViewController {
    @IBOutlet weak var organizeByButton: UIBarButtonItem!
    
    private var petViewController: PetOverviewViewController?
    private var mountViewController: MountOverviewViewController?
    
    private var organizeByColor = false {
        didSet {
            petViewController?.organizeByColor = organizeByColor
            mountViewController?.organizeByColor = organizeByColor
            UserDefaults.standard.set(organizeByColor, forKey: "stableOrganize")
        }
    }
    
    override func viewDidLoad() {
        canShowAsSplitView = false
        super.viewDidLoad()
        organizeByColor = UserDefaults.standard.bool(forKey: "stableOrganize")
        organizeByButton.menu = UIMenu(title: L10n.organizeBy, children: [
            UIDeferredMenuElement.uncached {[weak self] call in
                call([
                    UIAction(title: L10n.Stable.color, image: UIImage(systemName: "paintbrush"), state: self?.organizeByColor == true ? .on : .off) { _ in
                        self?.organizeByColor = true
                    },
                    UIAction(title: L10n.Stable.type, image: UIImage(systemName: "pawprint"), state: self?.organizeByColor == true ? .off : .on) { _ in
                        self?.organizeByColor = false
                    }
                ])
            }
        ])
        
        for childViewController in children {
            if let viewController = childViewController as? PetOverviewViewController {
                petViewController = viewController
                viewController.organizeByColor = organizeByColor
            }
            if let viewController = childViewController as? MountOverviewViewController {
                mountViewController = viewController
                viewController.organizeByColor = organizeByColor
            }
        }
        
        HabiticaAnalytics.shared.log("open_stable")
    }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.petsAndMounts
        segmentedControl.setTitle(L10n.pets, forSegmentAt: 0)
        segmentedControl.setTitle(L10n.mounts, forSegmentAt: 1)
        organizeByButton.image = UIImage(systemName: "slider.horizontal.3")
    }
}
