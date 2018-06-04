//
//  SkillsUserTableViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 29.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

class SkillsUserTableViewDataSource: BaseReactiveTableViewDataSource<MemberProtocol> {
    
    private let socialRepository = SocialRepository()
    private let userRepository = UserRepository()
    
    override init() {
        super.init()
        sections.append(ItemSection<MemberProtocol>())
        disposable.inner.add(userRepository.getUser().map({ (user) -> String? in
            return user.party?.id
        }).skipNil()
            .flatMap(.latest, {[weak self] (partyID) in
                return self?.socialRepository.getGroupMembers(groupID: partyID) ?? SignalProducer.empty
            })
            .on(value: {[weak self](members, changes) in
                self?.sections[0].items = members
                self?.notify(changes: changes)
            }).start()
        )
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let member = item(at: indexPath) {
            let nameTextView = cell.viewWithTag(1) as? UILabel
            nameTextView?.text = member.profile?.name
            let avatarView = cell.viewWithTag(2) as? AvatarView
            avatarView?.avatar = AvatarViewModel(avatar: member)
        }
        
        return cell
    }
}
