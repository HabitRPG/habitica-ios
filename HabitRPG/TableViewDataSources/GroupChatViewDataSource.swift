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
import KLCPopup

class GroupChatViewDataSource: BaseReactiveTableViewDataSource<ChatMessageProtocol> {

    @objc weak var viewController: GroupChatViewController?

    private var expandedChatPath: IndexPath?

    private let socialRepository = SocialRepository()
    private let userRepository = UserRepository()
    private let configRepository = ConfigRepository()
    private var user: UserProtocol?
    private let groupID: String
    
    init(groupID: String) {
        self.groupID = groupID
        super.init()
        sections.append(ItemSection<ChatMessageProtocol>())
        tableView?.reloadData()
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
            self?.tableView?.reloadData()
        }).start())
        disposable.inner.add(socialRepository.getChatMessages(groupID: groupID).on(value: {[weak self] (chatMessages, changes) in
            self?.sections[0].items = chatMessages
            self?.notify(changes: changes)
        }).start())
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
        
        cell.profileAction = {
            guard let profileViewController = self.viewController?.storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController else {
                return
            }
            profileViewController.userID = chatMessage.userID
            profileViewController.username = chatMessage.displayName
            self.viewController?.navigationController?.pushViewController(profileViewController, animated: true)
        }
        cell.reportAction = {[weak self] in
            guard let view = Bundle.main.loadNibNamed("HRPGFlagInformationOverlayView", owner: self, options: nil)?.first as? HRPGFlagInformationOverlayView else {
                return
            }
            view.username = chatMessage.displayName
            view.message = chatMessage.text
            view.flagAction = {
                if let strongSelf = self {
                    strongSelf.socialRepository.flag(groupID: strongSelf.groupID, chatMessage: chatMessage).observeCompleted {}
                }
            }
            view.sizeToFit()
            let popup = KLCPopup(contentView: view,
                                 showType: KLCPopupShowType.bounceIn,
                                 dismissType: KLCPopupDismissType.bounceOut,
                                 maskType: KLCPopupMaskType.dimmed,
                                 dismissOnBackgroundTouch: true,
                                 dismissOnContentTouch: false)
            popup?.show()
        }
        cell.replyAction = {
            self.viewController?.configureReplyTo(chatMessage.username ?? chatMessage.displayName)
        }
        cell.plusOneAction = {
            self.socialRepository.like(groupID: self.groupID, chatMessage: chatMessage).observeCompleted {}
        }
        cell.copyAction = {
            let pasteboard = UIPasteboard.general
            pasteboard.string = chatMessage.text
            let toastView = ToastView(title: L10n.copiedMessage, background: .green)
            ToastManager.show(toast: toastView)
        }
        cell.deleteAction = {
            self.socialRepository.delete(groupID: self.groupID, chatMessage: chatMessage).observeCompleted {}
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

    private func cellIdentifier(for chatMessage: ChatMessageProtocol?) -> String {
        if let message = chatMessage, message.isValid {
            if message.userID == nil || message.userID == "system" {
                return "SystemMessageCell"
            }
        }
        return "ChatMessageCell"
    }
}
