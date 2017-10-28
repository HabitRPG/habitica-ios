//
//  ChallengeDetailInfoTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/24/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class ChallengeDetailInfoTableViewCell: UITableViewCell, ChallengeConfigurable {
    @IBOutlet weak var challengeTitleLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!
    @IBOutlet weak var rewardCurrencyCountView: HRPGCurrencyCountView!
    @IBOutlet weak var participantsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rewardCurrencyCountView.currency = .gem
        rewardCurrencyCountView.viewSize = .large
    }
    
    func configure(with challenge: Challenge) {
        challengeTitleLabel.text = challenge.name
        rewardCurrencyCountView.amount = challenge.prize?.intValue ?? 0
        participantsLabel.text = "\(challenge.memberCount?.intValue ?? 0)"
    }
}
