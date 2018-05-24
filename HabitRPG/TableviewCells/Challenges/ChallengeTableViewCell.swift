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
    @IBOutlet weak private var groupLabel: UILabel!
    @IBOutlet weak private var leaderLabel: UILabel!
    @IBOutlet weak private var memberCountLabel: UILabel!
    @IBOutlet weak private var officialBadge: PillView!
    @IBOutlet weak private var participatingBadge: PillView!
    @IBOutlet weak private var officialParticipatingSpacing: NSLayoutConstraint!
    @IBOutlet weak private var badgesOffset: NSLayoutConstraint!
    @IBOutlet weak private var badgesHeight: NSLayoutConstraint!

    func setChallenge(_ challenge: ChallengeProtocol, isParticipating: Bool) {
        self.prizeLabel.text = String(challenge.prize)
        self.nameLabel.text = challenge.name?.unicodeEmoji

        //self.groupLabel.text = challenge.group?.name?.unicodeEmoji

        if let leaderName = challenge.leaderName {
            self.leaderLabel.text = NSLocalizedString("By \(leaderName.unicodeEmoji)", comment: "")
        }
        self.memberCountLabel.text = String(challenge.memberCount)

        let official = challenge.official
        self.officialBadge.isHidden = !official
        if official {
            officialParticipatingSpacing.constant = 8
        } else {
            officialParticipatingSpacing.constant = 0
        }

        self.participatingBadge.isHidden = isParticipating

        if self.officialBadge.isHidden && self.participatingBadge.isHidden {
            self.badgesHeight.constant = 0
            self.badgesOffset.constant = 0
        } else {
            self.badgesHeight.constant = 22
            self.badgesOffset.constant = 8
        }
    }
}
