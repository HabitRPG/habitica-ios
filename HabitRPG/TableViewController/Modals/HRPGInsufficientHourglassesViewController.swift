//
//  HRPGInsufficientHourglassesViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/16/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class HRPGInsufficientHourglassesViewController: HRPGSingleOptionModalViewController {
    @IBOutlet weak var backgroundModalView: HRPGCloseableShopModalView!
    @IBOutlet weak var infoView: HRPGSimpleShopItemView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundModalView.sendSubviewToBack(backgroundModalView.shopModalBgView)
        
        infoView.image = HabiticaIcons.imageOfHourglassShop
    }
    
    override func populateText() {
        titleLabel.text = L10n.notEnoughHourglasses
        actionButton?.setTitle(L10n.subscribeForHourglasses, for: .normal)
    }
    
    @IBAction func subscribePressed() {
        dismiss(animated: true, completion: nil)
        if let parentViewController = presentingViewController {
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
