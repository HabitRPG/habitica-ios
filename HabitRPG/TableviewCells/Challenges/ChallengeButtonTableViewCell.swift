//
//  ChallengeButtonTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/25/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class ChallengeButtonTableViewCell: UITableViewCell {
    @IBOutlet weak var button: UIButton!
    
    public var buttonViewModel: HRPGButtonViewModel = HRPGButtonViewModel()
    public weak var modelInputs: HRPGButtonModelInputs?
    
    override func didMoveToWindow() {
        buttonViewModel.button = self.button
    }
    
    @IBAction func cellButtonPressed() {
        modelInputs?.hrpgButtonPressed()
    }
}
