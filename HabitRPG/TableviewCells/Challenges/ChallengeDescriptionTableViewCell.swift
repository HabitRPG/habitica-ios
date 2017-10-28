//
//  ChallengeDescriptionTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/25/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class ChallengeDescriptionTableViewCell: UITableViewCell, ChallengeConfigurable {
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with challenge: Challenge) {
        descriptionLabel.text = challenge.notes
    }
    
}
