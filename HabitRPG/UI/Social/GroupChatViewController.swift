//
//  GroupChatViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import SlackTextViewController
import Down
import KLCPopup

class GroupChatViewController: SLKTextViewController {
    
    @objc public var groupID: String?
    private var sizeTextView = UITextView()
    private var expandedChatPath: IndexPath?
    private var dataSource: HRPGCoreDataDataSource?
    private let user = HRPGManager.shared().getUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true
        self.sizeTextView.textContainerInset = .zero
        self.sizeTextView.contentInset = .zero
        self.sizeTextView.font = CustomFontMetrics.scaledSystemFont(ofSize: 15)
        
        let nib = UINib(nibName: "ChatMessageCell", bundle: nil)
        self.tableView?.register(nib, forCellReuseIdentifier: "ChatMessageCell")
        let systemNib = UINib(nibName: "SystemMessageTableViewCell", bundle: nil)
        self.tableView?.register(systemNib, forCellReuseIdentifier: "SystemMessageCell")
        
        self.tableView?.separatorStyle = .none
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 90
        self.tableView?.backgroundColor = UIColor.gray700()
        
        self.dataSource = HRPGCoreDataDataSource(managedObjectContext: HRPGManager.shared().getManagedObjectContext(),
                                                 entityName: "ChatMessage",
                                                 cellIdentifier: nil,
                                                 configureCellBlock: {[weak self] (anyCell, anyItem, indexPath) in
                                                    guard let item = anyItem as? ChatMessage else {
                                                        return
                                                    }
                                                    if let cell = anyCell as? ChatTableViewCell {
                                                        self?.configure(cell: cell, item: item, indexPath: indexPath)
                                                        return
                                                    }
                                                    if let cell = anyCell as? SystemMessageTableViewCell {
                                                        cell.configure(chatMessage: item)
                                                        if let transform = self?.tableView?.transform {
                                                            cell.transform = transform
                                                        }
                                                        return
                                                    }
            }, fetchRequest: {[weak self] (fetchRequest) in
                fetchRequest?.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
                fetchRequest?.predicate = NSPredicate(format: "group.id == %@", self?.groupID ?? "")
            }, asDelegateFor: self.tableView)
        
        self.dataSource?.cellIdentifierBlock = { (item, indexPath) in
            if let message = item as? ChatMessage {
                if message.user == nil {
                    return "SystemMessageCell"
                }
            }
            return "ChatMessageCell"
        }
        
        if #available(iOS 10.0, *) {
            self.tableView?.refreshControl = UIRefreshControl()
            self.tableView?.refreshControl?.tintColor = UIColor.purple400()
            self.tableView?.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        }
        
        self.textView.registerMarkdownFormattingSymbol("**", withTitle: "Bold")
        self.textView.registerMarkdownFormattingSymbol("*", withTitle: "Italics")
        self.textView.registerMarkdownFormattingSymbol("~~", withTitle: "Strike")
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkGuidelinesAccepted()
        
        self.refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.renderAttributedTexts()
    }
    
    private func renderAttributedTexts() {
        DispatchQueue.global(qos: .background).async {[weak self] in
            for item in self?.dataSource?.items() ?? [] {
                guard let message = item as? ChatMessage else {
                    return
                }
                message.attributedText = try? Down(markdownString: message.text ?? "").toHabiticaAttributedString()
            }
            DispatchQueue.main.async {
                if let rows = self?.tableView?.indexPathsForVisibleRows {
                    self?.tableView?.reloadRows(at: rows, with: .automatic)
                }
            }
        }
    }
    
    @objc
    func refresh() {
        HRPGManager.shared().fetchGroup(self.groupID, onSuccess: {[weak self] in
            if #available(iOS 10.0, *) {
                self?.tableView?.refreshControl?.endRefreshing()
            }
        }, onError: {[weak self] in
            if #available(iOS 10.0, *) {
                self?.tableView?.refreshControl?.endRefreshing()
            }
        })
    }
    
    override func didPressRightButton(_ sender: Any?) {
        self.textView.refreshFirstResponder()
        
        HRPGManager.shared().chatMessage(self.textView.text, withGroup: self.groupID, onSuccess: {[weak self] in
            HRPGManager.shared().fetchGroup(self?.groupID, onSuccess: nil, onError: nil)
        }, onError: nil)
        
        if let expandedIndexPath = self.expandedChatPath {
            expandSelectedCell(expandedIndexPath)
        }
        
        super.didPressRightButton(sender)
    }
    
    private func expandSelectedCell(_ indexPath: IndexPath) {
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
            self.tableView?.reloadRows(at: [indexPath, expandedPath], with: .automatic)
            self.tableView?.endUpdates()
        } else {
            let cell = self.tableView?.cellForRow(at: indexPath) as? ChatTableViewCell
            cell?.isExpanded = !(cell?.isExpanded ?? false)
            if !(cell?.isExpanded ?? false) {
                self.expandedChatPath = nil
            }
            self.tableView?.beginUpdates()
            self.tableView?.reloadRows(at: [indexPath], with: .automatic)
            self.tableView?.endUpdates()
        }
    }
    
    private func configure(cell: ChatTableViewCell, item: ChatMessage, indexPath: IndexPath?) {
        var isExpanded = false
        if let expandedChatPath = self.expandedChatPath, let indexPath = indexPath {
            isExpanded = expandedChatPath == indexPath
        }
        cell.configure(chatMessage: item,
                       previousMessage: dataSource?.item(at: IndexPath(item: (indexPath?.item ?? 0)+1, section: indexPath?.section ?? 0)) as? ChatMessage,
                       nextMessage: dataSource?.item(at: IndexPath(item: (indexPath?.item ?? 0)-1, section: indexPath?.section ?? 0)) as? ChatMessage,
                       userID: self.user?.id ?? "",
                       username: self.user?.username ?? "",
                       isModerator: self.user?.isModerator() ?? false,
                       isExpanded: isExpanded)
        
        cell.profileAction = {
            guard let profileViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as? HRPGUserProfileViewController else {
                return
            }
            profileViewController.userID = item.uuid
            profileViewController.username = item.user
            self.navigationController?.pushViewController(profileViewController, animated: true)
        }
        cell.reportAction = {[weak self] in
            guard let view = Bundle.main.loadNibNamed("HRPGFlagInformationOverlayView", owner: self, options: nil)?.first as? HRPGFlagInformationOverlayView else {
                return
            }
            view.username = item.user
            view.message = item.text
            view.flagAction = {
                HRPGManager.shared().flagMessage(item, withGroup: self?.groupID, onSuccess: nil, onError: nil)
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
            self.textView.text = "@\(item.user ?? "")"
        }
        cell.plusOneAction = {
            HRPGManager.shared().like(item, withGroup: self.groupID, onSuccess: {
                if let path = indexPath {
                    self.tableView?.reloadRows(at: [path], with: .automatic)
                }
            }, onError: nil)
        }
        cell.copyAction = {
            let pasteboard = UIPasteboard.general
            pasteboard.string = item.text
        }
        cell.deleteAction = {
            HRPGManager.shared().delete(item, withGroup: self.groupID, onSuccess: nil, onError: nil)
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
    
    private func checkGuidelinesAccepted() {
        if !(user?.flags?.communityGuidelinesAccepted?.boolValue ?? false) {
            let acceptButton = UIButton()
            acceptButton.setTitle(NSLocalizedString("Post a message", comment: ""), for: .normal)
            acceptButton.backgroundColor = .white
            acceptButton.setTitleColor(UIColor.purple300(), for: .normal)
            acceptButton.addTarget(self, action: #selector(openGuidelinesView), for: .touchUpInside)
            acceptButton.frame = CGRect(x: 0, y: 0, width: textInputbar.frame.size.width, height: textInputbar.frame.size.height)
            acceptButton.tag = 2
            textInputbar.addSubview(acceptButton)
        } else {
            let button = textInputbar.viewWithTag(2)
            button?.removeFromSuperview()
        }
    }
    
    @objc
    private func openGuidelinesView() {
        self.performSegue(withIdentifier: "GuidelinesSegue", sender: self)
    }
    
    @IBAction func unwindToAcceptGuidelines(_ segue: UIStoryboardSegue) {
        HRPGManager.shared().updateUser(["flags.communityGuidelinesAccepted": true], onSuccess: {[weak self] in
            self?.user?.flags?.communityGuidelinesAccepted = NSNumber(value: true)
            self?.checkGuidelinesAccepted()
        }, onError: nil)
    }

}
