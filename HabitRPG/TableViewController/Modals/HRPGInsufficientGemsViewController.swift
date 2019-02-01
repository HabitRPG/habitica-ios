//
//  HRPGInsufficientGemsViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/15/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class HRPGInsufficientGemsViewController: HRPGSingleOptionModalViewController {
    @IBOutlet weak var backgroundModalView: HRPGCloseableShopModalView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundModalView.closeButton.addTarget(self, action: #selector(closePressed), for: UIControl.Event.touchUpInside)
        backgroundModalView.sendSubviewToBack(backgroundModalView.shopModalBgView)
    }
    
    override func populateText() {
        titleLabel.text = L10n.notEnoughGems
        actionButton?.setTitle(L10n.purchaseGems, for: .normal)
    }
    
    @IBAction func actionButtonPressed() {
        dismiss(animated: true, completion: nil)
        if let parentViewController = self.presentingViewController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController = storyboard.instantiateViewController(withIdentifier: "PurchaseGemNavController")
            parentViewController.present(navigationController, animated: true, completion: nil)
        }
    }
    
    @objc
    func closePressed() {
        dismiss(animated: true, completion: nil)
    }

}
