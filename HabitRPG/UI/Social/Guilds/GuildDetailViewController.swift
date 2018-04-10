//
//  GuildDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 09.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class GuildDetailViewController: GroupDetailViewController {
    
    @IBOutlet weak var guildMembersLabel: UILabel!
    @IBOutlet weak var guildGemCountLabel: UILabel!
    @IBOutlet weak var guildMembersCrestIcon: UIImageView!
    @IBOutlet weak var gemIconView: UIImageView!
    
    let numberFormatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gemIconView.image = HabiticaIcons.imageOfGem_36
    }
    
    override func updateData(group: GroupProtocol) {
        super.updateData(group: group)
        guildMembersCrestIcon.image = HabiticaIcons.imageOfGuildCrestMedium(memberCount: CGFloat(group.memberCount))
        guildMembersLabel.text = numberFormatter.string(from: NSNumber(value: group.memberCount))
        guildGemCountLabel.text = numberFormatter.string(from: NSNumber(value: group.gemCount))
    }
}
