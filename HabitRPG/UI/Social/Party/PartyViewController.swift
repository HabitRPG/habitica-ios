//
//  PartyViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 21.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class PartyViewController: SplitSocialViewController {
    
    override func viewDidLoad() {
        groupID = HRPGManager.shared().getUser().partyID
        super.viewDidLoad()
    }
    
}
