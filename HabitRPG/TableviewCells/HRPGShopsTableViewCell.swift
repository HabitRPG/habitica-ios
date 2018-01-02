//
//  HRPGShopsTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 7/28/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class HRPGShopsTableViewCell: UITableViewCell {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var characterImageView: UIImageView!
    @IBOutlet weak var gradientImageView: GradientImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 28, ofWeight: .regular)
        subtitleLabel.font = CustomFontMetrics.scaledSystemFont(ofSize: 28, ofWeight: .regular)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
