//
//  ChallengeDetailHeaderView.swift
//  Habitica
//
//  Created by Phillip Thelen on 01/03/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit
import Down

class ChallengeDetailHeaderView: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var gemCountLabel: UILabel!
    var showMoreAction: (() -> ())?

    @IBAction func showMoreTapped(_ sender: Any) {
        if let action = self.showMoreAction {
            action()
        }
    }
    
    func set(challenge: Challenge) {
        nameLabel.text = challenge.name?.unicodeEmoji
        if let notes = challenge.notes {
            notesLabel.attributedText = try? Down(markdownString: notes.unicodeEmoji).toHabiticaAttributedString()
        }
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
