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
        notesLabel.text = reward.notes
        if reward.value.stringValue.characters.count > 0 {
            notesLabel.isHidden = false
            notesLabel.text = reward.value.stringValue
        } else {
            notesLabel.isHidden = true
        }
    }
}
