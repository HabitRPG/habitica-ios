//
//  ChallengeTableViewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 23/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class ChallengeTableViewCell: UITableViewCell {

    @IBOutlet weak private var prizeLabel: UILabel!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var summaryLabel: UILabel!
    @IBOutlet weak private var memberCountLabel: UILabel!
    @IBOutlet weak private var officialBadge: PillView!
    @IBOutlet weak private var participatingBadge: PillView!
    @IBOutlet weak private var ownerBadge: PillView!
    
    func setChallenge(_ challenge: ChallengeProtocol, isParticipating: Bool, isOwner: Bool) {
        self.prizeLabel.text = String(challenge.prize)
        self.nameLabel.text = challenge.name?.unicodeEmoji
        summaryLabel.text = challenge.summary?.unicodeEmoji
        
        self.memberCountLabel.text = String(challenge.memberCount)

        self.officialBadge.isHidden = !challenge.official
        self.participatingBadge.isHidden = !isParticipating
        self.ownerBadge.isHidden = !isOwner
        
        prizeLabel.textColor = UIColor.green100()
        summaryLabel.textColor = ThemeService.shared.theme.secondaryTextColor
        memberCountLabel.textColor = ThemeService.shared.theme.secondaryTextColor
        
        officialBadge.textColor = UIColor.white
        participatingBadge.textColor = UIColor.white
        ownerBadge.textColor = UIColor.white
    }
}
