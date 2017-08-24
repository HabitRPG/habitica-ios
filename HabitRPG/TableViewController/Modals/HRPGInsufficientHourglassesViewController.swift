//
//  HRPGInsufficientHourglassesViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/16/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class HRPGInsufficientHourglassesViewController: HRPGSingleOptionModalViewController {
    @IBOutlet weak var backgroundModalView: HRPGCloseableShopModalView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundModalView.closeButton.addTarget(self, action: #selector(closePressed), for: UIControlEvents.touchUpInside)
        backgroundModalView.sendSubview(toBack: backgroundModalView.shopModalBgView)
    }
    
    @IBAction func subscribePressed() {
        
    }
    
    func closePressed() {
        dismiss(animated: true, completion: nil)
    }

}
