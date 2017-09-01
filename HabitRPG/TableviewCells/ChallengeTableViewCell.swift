//
//  ChallengeTableViewCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 23/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

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

    func setChallenge(_ challenge: Challenge) {
        self.prizeLabel.text = challenge.prize?.stringValue
        self.nameLabel.text = challenge.name?.unicodeEmoji

        self.groupLabel.text = challenge.group?.name.unicodeEmoji

        if let leaderName = challenge.leaderName {
            self.leaderLabel.text = "By \(leaderName.unicodeEmoji)".localized
        }
        self.memberCountLabel.text = challenge.memberCount?.stringValue

        let official = challenge.official?.boolValue ?? false
        self.officialBadge.isHidden = !official
        if official {
            officialParticipatingSpacing.constant = 8
        } else {
            officialParticipatingSpacing.constant = 0
        }

        self.participatingBadge.isHidden = challenge.user == nil

        if self.officialBadge.isHidden && self.participatingBadge.isHidden {
            self.badgesHeight.constant = 0
            self.badgesOffset.constant = 0
        } else {
            self.badgesHeight.constant = 22
            self.badgesOffset.constant = 8
        }
    }
}
