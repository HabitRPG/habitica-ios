//
//  ChallengeCreatorTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/25/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

protocol ChallengeCreatorCellDelegate: class {
    func messagePressed()
}

class ChallengeCreatorTableViewCell: UITableViewCell, ChallengeConfigurable {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    weak var delegate: ChallengeCreatorCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with challenge: Challenge) {
        configure(user: challenge.user)
    }
    
    func configure(user: User?) {
        userNameLabel.text = user?.username
    }
    
    @IBAction func messagesPressed() {
        delegate?.messagePressed()
    }
    
}
