//
//  SubscriptionInformationCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 16/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class SubscriptionInformationCell: UITableViewCell {

    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var expandButton: UIButton!
    @IBOutlet weak private var descriptionTextView: UITextView!
    @IBOutlet weak var titleWrapper: UIView!
    
    var expandButtonPressedAction: ((Bool) -> Void)?

    var isExpanded = false

    var title: String {
        set {
            titleLabel.text = newValue
        }

        get {
            return titleLabel.text ?? ""
        }
    }

    var descriptionText: String {
        set {
            descriptionTextView.text = newValue
            descriptionTextView.textColor = ThemeService.shared.theme.primaryTextColor
        }

        get {
            return descriptionTextView.text ?? ""
        }
    }

    @IBAction func expandButtonPressed(_ sender: Any) {
        isExpanded = !isExpanded
        if let action = expandButtonPressedAction {
            action(isExpanded)
        }
        self.setExpandIcon(isExpanded)
    }

    func setExpandIcon(_ isExpanded: Bool) {
        if isExpanded {
            expandButton.setImage(#imageLiteral(resourceName: "carret_up"), for: .normal)
        } else {
            expandButton.setImage(#imageLiteral(resourceName: "carret_down"), for: .normal)
        }
    }
}
