//
//  HRPGGemCapReachedViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class HRPGGemCapReachedViewController: HRPGSingleOptionModalViewController {
    @IBOutlet weak var backgroundModalView: HRPGCloseableShopModalView!
    @IBOutlet weak var infoView: HRPGSimpleShopItemView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundModalView.closeButton.addTarget(self, action: #selector(closePressed), for: UIControlEvents.touchUpInside)
        backgroundModalView.sendSubview(toBack: backgroundModalView.shopModalBgView)
    }
    
    @objc
    func closePressed() {
        dismiss(animated: true, completion: nil)
    }
    
}

