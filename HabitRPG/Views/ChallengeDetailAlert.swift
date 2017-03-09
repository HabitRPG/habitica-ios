//
//  ChallengeDetailAlert.swift
//  Habitica
//
//  Created by Phillip Thelen on 04/03/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit
import Down

class ChallengeDetailAlert: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var gemLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var joinLeaveButton: UIButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var joinLeaveAction: ((Bool) -> ())?
    
    var challenge: Challenge? {
        didSet {
            if viewIsLoaded {
                if let challenge = self.challenge {
                    configureForChallenge(challenge)
                }
            }
        }
    }
    
    var isMember: Bool = false {
        didSet {
            if !viewIsLoaded {
                return
            }
            if isMember {
                joinLeaveButton.setTitle(NSLocalizedString("Leave", comment: ""), for: .normal)
                joinLeaveButton.setTitleColor(.red100(), for: .normal)
            } else{
                joinLeaveButton.setTitle(NSLocalizedString("Join", comment: ""), for: .normal)
                joinLeaveButton.setTitleColor(.green100(), for: .normal)
            }
        }
    }
    
    private var viewIsLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewIsLoaded = true
        if let challenge = self.challenge {
            configureForChallenge(challenge)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.heightConstraint.constant = (self.view.window?.frame.size.height)! - 200
    }
    
    private func configureForChallenge(_ challenge: Challenge) {
        nameLabel.text = challenge.name?.unicodeEmoji
        if let notes = challenge.notes {
            let markdownString = try? Down(markdownString: notes.unicodeEmoji).toHabiticaAttributedString()
            notesLabel.attributedText = markdownString
        }
        ownerLabel.text = challenge.leaderName?.unicodeEmoji
        gemLabel.text = challenge.prize?.stringValue
        memberCountLabel.text = challenge.memberCount?.stringValue
        isMember = challenge.user != nil
    }
    @IBAction func joinLeaveTapped(_ sender: Any) {
        if let action = joinLeaveAction {
            action(!isMember)
        }
    }
}
