//
//  ChallengeCreatorTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/25/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

protocol ChallengeCreatorCellDelegate: class {
    func userPressed(_ user: User)
    func messagePressed(user: User)
}

class ChallengeCreatorTableViewCell: UITableViewCell, ChallengeConfigurable {
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    weak var delegate: ChallengeCreatorCellDelegate?
    
    private var user: User? {
        didSet {
            if let member = user {
                avatarView.avatar = member
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with challenge: Challenge) {
        userNameLabel.text = challenge.leaderName
        
        User.fetch(withId: challenge.leaderId) { (user) in
            self.configure(user: user)
        }
    }
    
    func configure(user: User?) {
        self.user = user
    }
    
    @IBAction func userPressed() {
        if let user = user {
            delegate?.userPressed(user)
        }
    }
    
    @IBAction func messagesPressed() {
        if let user = user {
            delegate?.messagePressed(user: user)
        }
    }
    
}
