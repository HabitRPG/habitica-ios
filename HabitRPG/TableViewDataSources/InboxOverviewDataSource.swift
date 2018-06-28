//
//  InboxOverviewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import DateTools

@objc public protocol InboxOverviewDataSourceProtocol {
    @objc weak var tableView: UITableView? { get set }

    @objc
    func messageAt(indexPath: IndexPath) -> InboxMessageProtocol?
    
    @objc
    func markInboxSeen()
    @objc
    func refresh(completed: @escaping (() -> Void))
}

@objc
class InboxOverviewDataSourceInstantiator: NSObject {
    @objc
    static func instantiate() -> InboxOverviewDataSourceProtocol {
        return InboxOverviewDataSource()
    }
}

class InboxOverviewDataSource: BaseReactiveTableViewDataSource<InboxMessageProtocol>, InboxOverviewDataSourceProtocol {
    
    private let socialRepository = SocialRepository()
    private let userRepository = UserRepository()
    
    override init() {
        super.init()
        sections.append(ItemSection<InboxMessageProtocol>())
        
        disposable.inner.add(socialRepository.getMessagesThreads().on(value: {[weak self](messages, changes) in
            self?.sections[0].items = messages
            self?.notify(changes: changes)
        }).start())
    }
    
    func messageAt(indexPath: IndexPath) -> InboxMessageProtocol? {
        return item(at: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if let message = item(at: indexPath) {
            let usernameLabel = cell.viewWithTag(1) as? UsernameLabel
            usernameLabel?.text = message.username
            usernameLabel?.contributorLevel = message.contributor?.level ?? 0
            usernameLabel?.font = CustomFontMetrics.scaledSystemFont(ofSize: 17)
            let textLabel = cell.viewWithTag(2) as? UILabel
            textLabel?.text = message.text
            let timeLabel = cell.viewWithTag(3) as? UILabel
            timeLabel?.text = (message.timestamp as NSDate?)?.timeAgoSinceNow()
        }
        
        return cell
    }
    
    func markInboxSeen() {
        socialRepository.markInboxAsSeen().observeCompleted {}
    }
    
    func refresh(completed: @escaping (() -> Void)) {
        userRepository.retrieveInboxMessages().observeCompleted {
            completed()
        }
    }
}
