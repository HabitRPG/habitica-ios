//
//  ChallengeTableViewHeaderView.swift
//  Habitica
//
//  Created by Elliot Schrock on 1/12/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class ChallengeTableViewHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func didMoveToWindow() {
        setup()
    }
    
    func setup() {
        titleLabel.textColor = UIColor.gray50()

        countLabel.textColor = UIColor.gray400()
        countLabel.layer.cornerRadius = 11
        countLabel.backgroundColor = UIColor.white
        countLabel.textColor = UIColor.gray400()
        countLabel.clipsToBounds = true

        contentView.backgroundColor = UIColor.gray700()
    }
}
