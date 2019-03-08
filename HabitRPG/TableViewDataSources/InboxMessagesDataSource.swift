//
//  InboxMessagesDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

@objc public protocol InboxMessagesDataSourceProtocol {
    @objc weak var tableView: UITableView? { get set }
    @objc weak var viewController: HRPGInboxChatViewController? { get set }
    @objc var otherUsername: String? { get set }
    
    @objc
    func sendMessage(messageText: String)
}

@objc
class InboxMessagesDataSourceInstantiator: NSObject {
    @objc
    static func instantiate(otherUserID: String?) -> InboxMessagesDataSourceProtocol {
        return InboxMessagesDataSource(otherUserID: otherUserID)
    }
}

class InboxMessagesDataSource: BaseReactiveTableViewDataSource<InboxMessageProtocol>, InboxMessagesDataSourceProtocol {
    @objc weak var viewController: HRPGInboxChatViewController?
    
    private var expandedChatPath: IndexPath?
    
    private let socialRepository = SocialRepository()
    private let userRepository = UserRepository()
    private let configRepository = ConfigRepository()
    private var user: UserProtocol?
    private let otherUserID: String?
    internal var otherUsername: String?
    
    init(otherUserID: String?) {
        self.otherUserID = otherUserID
        super.init()
        sections.append(ItemSection<InboxMessageProtocol>())
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
            self?.tableView?.reloadData()
        }).start())
        disposable.inner.add(socialRepository.getMember(userID: otherUserID ?? otherUsername ?? "", retrieveIfNotFound: true).on(value: {[weak self]member in
            self?.viewController?.setTitleWithUsername(member?.profile?.name)
        }).start())
        disposable.inner.add(socialRepository.getMessages(withUserID: otherUserID ?? otherUsername ?? "").on(value: {[weak self] (messages, changes) in
            self?.sections[0].items = messages
            self?.notify(changes: changes)
        }).start())
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = item(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath)
        if let message = message {
            if let chatCell = cell as? ChatTableViewCell {
                self.configure(cell: chatCell, message: message, indexPath: indexPath)
            }
        }
        return cell
    }
    
    private func configure(cell: ChatTableViewCell, message: InboxMessageProtocol, indexPath: IndexPath?) {
        var isExpanded = false
        if let expandedChatPath = self.expandedChatPath, let indexPath = indexPath {
            isExpanded = expandedChatPath == indexPath
        }
        
        cell.isFirstMessage = indexPath?.item == 0
        cell.configure(inboxMessage: message,
                       previousMessage: item(at: IndexPath(item: (indexPath?.item ?? 0)+1, section: indexPath?.section ?? 0)),
                       nextMessage: item(at: IndexPath(item: (indexPath?.item ?? 0)-1, section: indexPath?.section ?? 0)),
                       user: self.user, isExpanded: isExpanded)
        
        cell.profileAction = {
            guard let profileViewController = self.viewController?.storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController else {
                return
            }
            if message.sent {
                profileViewController.userID = self.user?.id
                profileViewController.username = self.user?.profile?.name
            } else {
                profileViewController.userID = message.userID
                profileViewController.username = message.displayName
            }
            self.viewController?.navigationController?.pushViewController(profileViewController, animated: true)
        }
        cell.copyAction = {
            let pasteboard = UIPasteboard.general
            pasteboard.string = message.text
            let toastView = ToastView(title: L10n.copiedMessage, background: .green)
            ToastManager.show(toast: toastView)
        }
        cell.deleteAction = {
            self.socialRepository.delete(message: message).observeCompleted {}
        }
        cell.expandAction = {
            if let path = indexPath {
                self.expandSelectedCell(path)
            }
        }
        
        if let transform = self.tableView?.transform {
            cell.transform = transform
        }
    }
    
    private func expandSelectedCell(_ indexPath: IndexPath) {
        if self.viewController?.isScrolling == true {
            return
        }
        var oldExpandedPath: IndexPath? = self.expandedChatPath
        if self.tableView?.numberOfRows(inSection: 0) ?? 0 < oldExpandedPath?.item ?? 0 {
            oldExpandedPath = nil
        }
        self.expandedChatPath = indexPath
        if let expandedPath = oldExpandedPath, indexPath.item != expandedPath.item {
            let oldCell = self.tableView?.cellForRow(at: expandedPath) as? ChatTableViewCell
            let cell = self.tableView?.cellForRow(at: indexPath) as? ChatTableViewCell
            self.tableView?.beginUpdates()
            cell?.isExpanded = true
            oldCell?.isExpanded = false
            self.tableView?.endUpdates()
        } else {
            let cell = self.tableView?.cellForRow(at: indexPath) as? ChatTableViewCell
            cell?.isExpanded = !(cell?.isExpanded ?? false)
            if !(cell?.isExpanded ?? false) {
                self.expandedChatPath = nil
            }
            self.tableView?.beginUpdates()
            self.tableView?.endUpdates()
        }
    }
    
    func sendMessage(messageText: String) {
        socialRepository.post(inboxMessage: messageText, toUserID: otherUserID ?? otherUsername ?? "").observeCompleted {}
    }
}
