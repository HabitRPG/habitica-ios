//
//  InboxMessagesDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 25.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class InboxMessagesDataSource: BaseReactiveTableViewDataSource<InboxMessageProtocol> {
    @objc weak var viewController: InboxChatViewController?
    
    private var expandedChatPath: IndexPath?
    
    private let socialRepository = SocialRepository()
    private let userRepository = UserRepository()
    private let configRepository = ConfigRepository()
    private var user: UserProtocol?
    private var otherUserID: String?
    internal var otherUsername: String?
    
    var loadedAllData = false
    var isLoading = false
    
    init(otherUserID: String?, otherUsername: String?) {
        self.otherUserID = otherUserID
        self.otherUsername = otherUsername
        super.init()
        sections.append(ItemSection<InboxMessageProtocol>())
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
            if (self?.otherUserID == nil) {
                self?.otherUserID = user.id
            }
            self?.tableView?.reloadData()
        }).start())
        disposable.inner.add(socialRepository.getMember(userID: otherUserID ?? otherUsername ?? "", retrieveIfNotFound: true).on(value: {[weak self]member in
            self?.viewController?.setTitleWith(username: member?.profile?.name)
            (self?.emptyDataSource as? SingleItemTableViewDataSource)?.styleFunction = EmptyTableViewCell.inboxChatStyleUsername(displayName: member?.profile?.name ?? "", contributorTier: member?.contributor?.level, username: member?.username ?? "")
            self?.tableView?.reloadData()
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
        
        cell.profileAction = {[weak self] in
            guard let profileViewController = self?.viewController?.storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController else {
                return
            }
            if message.sent {
                profileViewController.userID = self?.user?.id
                profileViewController.username = self?.user?.profile?.name
            } else {
                profileViewController.userID = message.userID
                profileViewController.username = message.displayName
            }
            self?.viewController?.navigationController?.pushViewController(profileViewController, animated: true)
        }
        cell.copyAction = {
            let pasteboard = UIPasteboard.general
            pasteboard.string = message.text
            let toastView = ToastView(title: L10n.copiedMessage, background: .green)
            ToastManager.show(toast: toastView)
        }
        cell.deleteAction = {[weak self] in
            self?.socialRepository.delete(message: message).observeCompleted {}
        }
        cell.expandAction = {[weak self] in
            if let path = indexPath {
                self?.expandSelectedCell(path)
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
        socialRepository.post(inboxMessage: messageText, toUserID: otherUserID ?? otherUsername ?? "").observeCompleted {
            self.tableView?.reloadData()
        }
    }
    
    func retrieveData(forced: Bool, completed: (() -> Void)?) {
        var page = (self.visibleSections.first?.items.count ?? 0) / 10
        if forced {
            page = 0
            loadedAllData = false
        }
        if loadedAllData || isLoading {
            return
        }
        isLoading = true
        userRepository.retrieveInboxMessages(conversationID: otherUserID ?? "", page: page)
            .on(value: { messages in
                if messages?.count ?? 0 < 10 {
                    self.loadedAllData = true
                }
                self.isLoading = false
            })
            .observeCompleted {
            completed?()
        }
    }
    
    override func checkForEmpty() {
        super.checkForEmpty()
        tableView?.separatorStyle = .none
    }
}
