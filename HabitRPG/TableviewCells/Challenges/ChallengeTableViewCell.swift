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
    @IBOutlet weak var otherPillsStack: UIStackView!
	
    func setChallenge(_ challenge: ChallengeProtocol, isParticipating: Bool, isOwner: Bool) {
        self.prizeLabel.text = String(challenge.prize)
        self.nameLabel.text = challenge.name?.unicodeEmoji
        summaryLabel.text = challenge.summary?.unicodeEmoji
        
        self.memberCountLabel.text = String(challenge.memberCount)

        self.officialBadge.isHidden = !challenge.official
        self.participatingBadge.isHidden = true
        self.ownerBadge.isHidden = !isOwner

        prizeLabel.textColor = ThemeService.shared.theme.secondaryTextColor
        summaryLabel.textColor = ThemeService.shared.theme.secondaryTextColor
        if isParticipating {
            memberCountLabel.textColor = UIColor.green10
            memberCountLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        } else {
            memberCountLabel.textColor = ThemeService.shared.theme.secondaryTextColor
            memberCountLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        }
        
        prizeLabel.backgroundColor = .clear
        nameLabel.backgroundColor = .clear
        summaryLabel.backgroundColor = .clear
        memberCountLabel.backgroundColor = .clear

        officialBadge.textColor = UIColor.white
        participatingBadge.textColor = UIColor.white
        ownerBadge.textColor = UIColor.white

        otherPillsStack.removeAllArrangedSubviews()
        challenge.categories
            .compactMap { $0.name }
            .filter { $0 != ChallengeCategory.official.rawValue }
            .compactMap { ChallengeCategory.localizedCategoryNameFor(name: $0) }
            .enumerated()
            .forEach { idx, name in
                let pill = PillView()
                pill.pillColor = .gray400
                pill.text = name
                let priority = UILayoutPriority(rawValue: Float(1000 - idx))
                pill.setContentHuggingPriority(priority, for: .horizontal)
                pill.setContentCompressionResistancePriority(priority, for: .horizontal)
                otherPillsStack.addArrangedSubview(pill)
            }
    }

}
