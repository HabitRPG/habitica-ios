//
//  ChallengeCreatorTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/25/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

protocol ChallengeCreatorCellDelegate: class {
    func userPressed(_ user: UserProtocol)
    func messagePressed(user: UserProtocol)
}

class ChallengeCreatorTableViewCell: UITableViewCell, ChallengeConfigurable {
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    weak var delegate: ChallengeCreatorCellDelegate?
    
    private var user: UserProtocol? {
        didSet {
            if let member = user {
                avatarView.avatar = AvatarViewModel(avatar: member)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with challenge: ChallengeProtocol) {
        userNameLabel.text = challenge.leaderName
        
        /*User.fetch(withId: challenge.leaderID) { (user) in
            self.configure(user: user)
        }*/
    }
    
    func configure(user: UserProtocol?) {
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
