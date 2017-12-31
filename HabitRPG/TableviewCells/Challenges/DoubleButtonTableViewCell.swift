//
//  DoubleButtonTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 12/31/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class DoubleButtonTableViewCell: UITableViewCell {
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    public var leftButtonViewModel: HRPGButtonViewModel = HRPGButtonViewModel()
    public weak var leftModelInputs: HRPGButtonModelInputs?
    
    public var rightButtonViewModel: HRPGButtonViewModel = HRPGButtonViewModel()
    public weak var rightModelInputs: HRPGButtonModelInputs?
    
    override func didMoveToWindow() {
        leftButtonViewModel.button = self.leftButton
        rightButtonViewModel.button = self.rightButton
    }
    
    @IBAction func leftButtonPressed() {
        leftModelInputs?.hrpgButtonPressed()
    }
    
    @IBAction func rightButtonPressed() {
        rightModelInputs?.hrpgButtonPressed()
    }
}
