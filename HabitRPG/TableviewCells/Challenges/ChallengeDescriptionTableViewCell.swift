//
//  ChallengeDescriptionTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/25/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Down

class ChallengeDescriptionTableViewCell: UITableViewCell, ChallengeConfigurable {
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with challenge: Challenge) {
        if let notes = challenge.notes {
            descriptionLabel.attributedText = try? Down(markdownString: notes.unicodeEmoji).toHabiticaAttributedString(baseFont: descriptionLabel.font)
            descriptionLabel.textColor = UIColor.gray10()
        }
    }
    
}
