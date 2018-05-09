//
//  PartyViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 21.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class PartyViewController: SplitSocialViewController {
    
    private let userRepository = UserRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disposable.inner.add(userRepository.getUser().map({ (user) -> String? in
            return user.party?.id
        }).skipNil()
            .take(first: 1)
            .on(value: { partyID in
                self.isGroupMember = true
                self.groupID = partyID
            })
            .start())
    }

}
