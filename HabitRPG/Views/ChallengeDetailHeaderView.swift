//
//  ChallengeDetailHeaderView.swift
//  Habitica
//
//  Created by Phillip Thelen on 01/03/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class ChallengeDetailHeaderView: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var gemCountLabel: UILabel!

    @IBAction func showMoreTapped(_ sender: Any) {
    }
    
    func set(challenge: Challenge) {
        nameLabel.text = challenge.name?.unicodeEmoji
        notesLabel.text = challenge.notes?.unicodeEmoji
        memberCountLabel.text = challenge.memberCount?.stringValue
        gemCountLabel.text = challenge.prize?.stringValue
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        var height = size.height
        let width = size.width
        height += nameLabel.intrinsicContentSize.height + 8
        height += notesLabel.intrinsicContentSize.height + 8
        height += 38
        return CGSize(width: width, height: height)
    }
}
