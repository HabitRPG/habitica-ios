//
//  ChallengeCreatorTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/25/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

protocol ChallengeCreatorCellDelegate: class {
    func messagePressed()
}

class ChallengeCreatorTableViewCell: UITableViewCell, ChallengeConfigurable {
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    weak var delegate: ChallengeCreatorCellDelegate?
    
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
        if let member = user {
            if let avatar = member.getAvatarViewShowsBackground(true, showsMount: false, showsPet: false) {
                avatarView.addSubview(avatar)
                avatarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(-10)-[avatar]-(0)-|", options: .init(rawValue: 0), metrics: nil, views: ["avatar": avatar]))
                avatarView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(-15)-[avatar]-(-10)-|", options: .init(rawValue: 0), metrics: nil, views: ["avatar": avatar]))
                
                setNeedsUpdateConstraints()
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }
    
    @IBAction func messagesPressed() {
        delegate?.messagePressed()
    }
    
}
