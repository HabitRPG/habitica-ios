//
//  ChallengeButtonTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/25/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

protocol HRPGButtonCellModelInputs: class {
    func hrpgCellButtonPressed()
}

protocol HRPGButtonCellAttributeProvider: class {
    var bgColorSignal: Signal<UIColor?, NoError> { get }
    var titleSignal: Signal<String, NoError> { get }
    var enabledSignal: Signal<Bool, NoError> { get }
    
    func didButtonCellAwakeFromNib()
}

class ChallengeButtonTableViewCell: UITableViewCell {
    @IBOutlet weak var button: UIButton!
    
    public weak var modelInputs: HRPGButtonCellModelInputs?
    public weak var attributeProvider: HRPGButtonCellAttributeProvider? {
        didSet {
            attributeProvider?.bgColorSignal.observeValues({ [weak self] (color) in
                self?.button.backgroundColor = color
            })
            
            attributeProvider?.titleSignal.observeValues({ [weak self] (title) in
                self?.button.setTitle(title, for: .normal)
            })
            
            attributeProvider?.enabledSignal.observeValues({ [weak self] (isEnabled) in
                self?.button.isEnabled = isEnabled
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func didMoveToWindow() {
        attributeProvider?.didButtonCellAwakeFromNib()
    }
    
    @IBAction func cellButtonPressed() {
        modelInputs?.hrpgCellButtonPressed()
    }
}
