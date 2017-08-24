//
//  CustomRewrdCell.swift
//  Habitica
//
//  Created by Phillip on 21.08.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class CustomRewardCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    func configure(reward: Reward) {
        titleLabel.text = reward.text
        if reward.notes.characters.count > 0 {
            notesLabel.isHidden = false
            notesLabel.text = reward.notes
        } else {
            notesLabel.isHidden = true
        }
        amountLabel.text = reward.value.stringValue
    }
}
