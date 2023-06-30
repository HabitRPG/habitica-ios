//
//  GroupChatViewDataSource.swift
//  Habitica
//
//  Created by Phillip Thelen on 30.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

class GroupChatViewDataSource: BaseReactiveTableViewDataSource<ChatMessageProtocol> {

    @objc weak var viewController: GroupChatViewController?

    private var expandedChatPath: IndexPath?

    private let socialRepository = SocialRepository()
    private let userRepository = UserRepository()
    private let configRepository = ConfigRepository.shared
    private var user: UserProtocol?
    private let groupID: String
    
    init(groupID: String) {
        self.groupID = groupID
        super.init()
        sections.append(ItemSection<ChatMessageProtocol>())
        tableView?.reloadData()
        
        disposable.add(userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
            self?.tableView?.reloadData()
        }).start())
        disposable.add(socialRepository.getChatMessages(groupID: groupID).on(value: {[weak self] (chatMessages, changes) in
            self?.sections[0].items = chatMessages
            self?.notify(changes: changes)
        }).start())
        disposable.add(socialRepository.getGroupMembers(groupID: groupID).take(first: 1).on(value: { [weak self] members in
            if members.value.count > 1 {
                let timerSignal: SignalProducer<Date, Never> = SignalProducer.timer(interval: .seconds(30), on: QueueScheduler.main)
                self?.disposable.add(timerSignal.on(value: { _ in
                    self?.retrieveData(completed: nil)
                }).start())
            }
        }).start())
        
        retrieveData(completed: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatMessage = item(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: chatMessage), for: indexPath)
        if let chatMessage = chatMessage, chatMessage.isValid {
            if let chatCell = cell as? ChatTableViewCell {
                self.configure(cell: chatCell, chatMessage: chatMessage, indexPath: indexPath)
            }
            if let systemCell = cell as? SystemMessageTableViewCell {
                systemCell.configure(chatMessage: chatMessage)
                systemCell.transform = tableView.transform
            }
        }
        return cell
    }
    
    private func configure(cell: ChatTableViewCell, chatMessage: ChatMessageProtocol, indexPath: IndexPath?) {
        var isExpanded = false
        if let expandedChatPath = self.expandedChatPath, let indexPath = indexPath {
            isExpanded = expandedChatPath == indexPath
        }
        
        cell.isFirstMessage = indexPath?.item == 0
        var username = user?.username ?? ""
        if username.isEmpty {
            username = self.user?.profile?.name ?? ""
        }
        cell.configure(chatMessage: chatMessage,
                       previousMessage: item(at: IndexPath(item: (indexPath?.item ?? 0)+1, section: indexPath?.section ?? 0)),
                       nextMessage: item(at: IndexPath(item: (indexPath?.item ?? 0)-1, section: indexPath?.section ?? 0)),
                       userID: self.user?.id ?? "",
                       username: username,
                       isModerator: self.user?.isModerator == true,
                       isExpanded: isExpanded)
        
        cell.profileAction = {[weak self] in
            guard let profileViewController = self?.viewController?.storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController else {
                return
            }
            profileViewController.userID = chatMessage.userID
            profileViewController.username = chatMessage.username
            self?.viewController?.navigationController?.pushViewController(profileViewController, animated: true)
        }
        cell.reportAction = {[weak self] in
            guard let view = Bundle.main.loadNibNamed("HRPGFlagInformationOverlayView", owner: self, options: nil)?.first as? FlagInformationOverlayView else {
                return
            }
            view.message = chatMessage.text
            view.sizeToFit()
            
            let alert = HabiticaAlertController()
            alert.title = L10n.reportXViolation(chatMessage.username ?? "")
            alert.contentView = view
            alert.addAction(title: L10n.report, style: .destructive, isMainAction: true) {[weak self] _ in
                self?.socialRepository.flag(groupID: self?.groupID ?? "", chatMessage: chatMessage).observeCompleted {}
            }
            alert.addCancelAction()
            alert.containerViewSpacing = 8
            alert.enqueue()
        }
        cell.replyAction = {[weak self] in
            self?.viewController?.configureReplyTo(name: chatMessage.username ?? chatMessage.displayName)
        }
        cell.plusOneAction = {[weak self] in
            self?.socialRepository.like(groupID: self?.groupID ?? "", chatMessage: chatMessage).observeCompleted {}
        }
        cell.copyAction = {
            let pasteboard = UIPasteboard.general
            pasteboard.string = chatMessage.text
            let toastView = ToastView(title: L10n.copiedMessage, background: .green)
            ToastManager.show(toast: toastView)
        }
        cell.deleteAction = {[weak self] in
            self?.socialRepository.delete(groupID: self?.groupID ?? "", chatMessage: chatMessage).observeCompleted {}
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
    
    override func retrieveData(completed: (() -> Void)?) {
        if user?.party?.id == nil {
            return
        }
        disposable.add(socialRepository.retrieveChat(groupID: groupID).observeCompleted {
            completed?()
        })
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

    private func cellIdentifier(for chatMessage: ChatMessageProtocol?) -> String {
        if let message = chatMessage, message.isValid {
            if message.userID == nil || message.userID == "system" {
                return "SystemMessageCell"
            }
        }
        return "ChatMessageCell"
    }
}
