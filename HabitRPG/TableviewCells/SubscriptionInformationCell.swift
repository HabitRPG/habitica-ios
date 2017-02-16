//
//  SubscriptionInformationCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 16/02/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class SubscriptionInformationCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var expandButtonPressedAction: ((Bool) -> ())?
    
    var isExpanded = false

    @IBAction func expandButtonPressed(_ sender: Any) {
        isExpanded = !isExpanded
        if expandButtonPressedAction != nil {
            expandButtonPressedAction!(isExpanded)
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
