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

class ButtonCellMultiModelDataSourceItem: ConcreteMultiModelDataSourceItem<ChallengeButtonTableViewCell> {
    let attributeProvider: HRPGButtonAttributeProvider?
    let inputs: HRPGButtonModelInputs?
    
    init(attributeProvider: HRPGButtonAttributeProvider?, inputs: HRPGButtonModelInputs?, identifier: String) {
        self.attributeProvider = attributeProvider
        self.inputs = inputs
        super.init(identifier: identifier)
    }
    
    override func configureCell(_ cell: UITableViewCell) {
        if let buttonCell = cell as? ChallengeButtonTableViewCell {
            buttonCell.buttonViewModel.attributeProvider = attributeProvider
            buttonCell.modelInputs = inputs
        }
    }
}
