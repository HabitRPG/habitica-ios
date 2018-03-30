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
import Result
import KLCPopup

class GroupChatViewDataSource: BaseReactiveDataSource, UITableViewDataSource {

    @objc weak var tableView: UITableView? {
        didSet {
            tableView?.dataSource = self
            tableView?.reloadData()
        }
    }
    private var expandedChatPath: IndexPath?

    private let socialRepository = SocialRepository()
    private let userRepository = UserRepository()
    private var chatMessages = [ChatMessageProtocol]()
    private var user: UserProtocol?
    private let groupID: String
    
    init(groupID: String) {
        self.groupID = groupID
        super.init()
        disposable.inner.add(socialRepository.getChatMessages(groupID: groupID).on(value: {[weak self] (chatMessages, changes) in
            self?.chatMessages = chatMessages
            self?.notifyDataUpdate(tableView: self?.tableView, changes: changes)
        }).start())
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.user = user
            self?.tableView?.reloadData()
        }).start())
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatMessage = itemAt(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier(for: chatMessage), for: indexPath)
        if let chatMessage = chatMessage {
            if let chatCell = cell as? ChatTableViewCell {
                self.configure(cell: chatCell, item: chatMessage, indexPath: indexPath)
            }
            if let systemCell = cell as? SystemMessageTableViewCell {
                systemCell.configure(chatMessage: chatMessage)
                systemCell.transform = tableView.transform
            }
        }
        return cell
    }
    
    private func configure(cell: ChatTableViewCell, item: ChatMessageProtocol, indexPath: IndexPath?) {
        var isExpanded = false
        if let expandedChatPath = self.expandedChatPath, let indexPath = indexPath {
            isExpanded = expandedChatPath == indexPath
        }
        
        cell.isFirstMessage = indexPath?.item == 0
        cell.configure(chatMessage: item,
                       previousMessage: itemAt(indexPath: IndexPath(item: (indexPath?.item ?? 0)+1, section: indexPath?.section ?? 0)),
                       nextMessage: itemAt(indexPath: IndexPath(item: (indexPath?.item ?? 0)-1, section: indexPath?.section ?? 0)),
                       userID: self.user?.id ?? "",
                       username: self.user?.profile?.name ?? "",
                       isModerator: self.user?.isModerator == true,
                       isExpanded: isExpanded)
        
        cell.profileAction = {
            /*guard let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as? HRPGUserProfileViewController else {
                return
            }
            profileViewController.userID = item.uuid
            profileViewController.username = item.user
            self.navigationController?.pushViewController(profileViewController, animated: true)*/
        }
        cell.reportAction = {[weak self] in
            guard let view = Bundle.main.loadNibNamed("HRPGFlagInformationOverlayView", owner: self, options: nil)?.first as? HRPGFlagInformationOverlayView else {
                return
            }
            view.username = item.username
            view.message = item.text
            view.flagAction = {
                if let strongSelf = self {
                    strongSelf.socialRepository.flag(groupID: strongSelf.groupID, chatMessage: item).observeCompleted {}
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
            //self.textView.text = "@\(item.user ?? "") "
            //self.textView.becomeFirstResponder()
            //self.textView.selectedRange = NSRange(location: self.textView.text.count, length: 0)
        }
        cell.plusOneAction = {
            self.socialRepository.like(groupID: self.groupID, chatMessage: item).observeCompleted {}
        }
        cell.copyAction = {
            let pasteboard = UIPasteboard.general
            pasteboard.string = item.text
            let toastView = ToastView(title: NSLocalizedString("Copied Message", comment: ""), background: .green)
            ToastManager.show(toast: toastView)
        }
        cell.deleteAction = {
            self.socialRepository.delete(groupID: self.groupID, chatMessage: item).observeCompleted {}
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
        /*if isScrolling {
            return
        }*/
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
        if let message = chatMessage {
            if message.userID == nil || message.userID == "system" {
                return "SystemMessageCell"
            }
        }
        return "ChatMessageCell"
    }
    
    @objc
    func itemAt(indexPath: IndexPath) -> ChatMessageProtocol? {
        if indexPath.section == 0 {
            if indexPath.item > 0 && indexPath.item < chatMessages.count {
                return chatMessages[indexPath.item]
            }
        }
        return nil
    }
}
