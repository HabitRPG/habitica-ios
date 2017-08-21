//
//  HRPGInsufficientGoldViewController.swift
//  Habitica
//
//  Created by Elliot Schrock on 8/16/17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class HRPGInsufficientGoldViewController: HRPGSingleOptionModalViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func closePressed() {
        dismiss(animated: true, completion: nil)
    }
}
