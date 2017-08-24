//
//  HRPGInsufficientGemsViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/15/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class HRPGInsufficientGemsViewController: HRPGSingleOptionModalViewController {
    @IBOutlet weak var backgroundModalView: HRPGCloseableShopModalView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundModalView.closeButton.addTarget(self, action: #selector(closePressed), for: UIControlEvents.touchUpInside)
        backgroundModalView.sendSubview(toBack: backgroundModalView.shopModalBgView)
    }
    
    @IBAction func actionButtonPressed() {
        let storyboard = UIStoryboard(name: "Main", bundle:nil)
        let navigationController = storyboard.instantiateViewController(withIdentifier: "PurchaseGemNavController")
        present(navigationController, animated: true, completion: nil)
    }
    
    func closePressed() {
        dismiss(animated: true, completion: nil)
    }

}
