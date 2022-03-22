//
//  ChallengeCreatorTableViewCell.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/25/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

protocol ChallengeCreatorCellDelegate: AnyObject {
    func userPressed(_ member: MemberProtocol)
    func messagePressed(member: MemberProtocol)
}

class ChallengeCreatorTableViewCell: UITableViewCell, ChallengeConfigurable {
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    weak var delegate: ChallengeCreatorCellDelegate?
    
    private var member: MemberProtocol? {
        didSet {
            if let member = member {
                avatarView.size = .compact
                avatarView.avatar = AvatarViewModel(avatar: member)
                userNameLabel.text = member.profile?.name
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with challenge: ChallengeProtocol, userID: String?) {
        userNameLabel.text = challenge.leaderName
    }
    
    func configure(member: MemberProtocol?) {
        self.member = member
    }
    
    @IBAction func userPressed() {
        if let member = member {
            delegate?.userPressed(member)
        }
    }
    
    @IBAction func messagesPressed() {
        if let member = member {
            delegate?.messagePressed(member: member)
        }
    }
    
}
