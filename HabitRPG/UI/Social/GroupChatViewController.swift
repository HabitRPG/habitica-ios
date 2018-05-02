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
import Habitica_Models
import ReactiveSwift

class GroupChatViewController: SLKTextViewController {
    
    @objc public var groupID: String?
    private var dataSource: GroupChatViewDataSource?
    var isScrolling = false
    
    private let socialRepository = SocialRepository()
    private let userRepository = UserRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true
               
        let nib = UINib(nibName: "ChatMessageCell", bundle: nil)
        self.tableView?.register(nib, forCellReuseIdentifier: "ChatMessageCell")
        let systemNib = UINib(nibName: "SystemMessageTableViewCell", bundle: nil)
        self.tableView?.register(systemNib, forCellReuseIdentifier: "SystemMessageCell")
        
        self.tableView?.separatorStyle = .none
        self.tableView?.rowHeight = UITableViewAutomaticDimension
        self.tableView?.estimatedRowHeight = 90
        self.tableView?.backgroundColor = UIColor.gray700()

        if #available(iOS 10.0, *) {
            self.tableView?.refreshControl = UIRefreshControl()
            self.tableView?.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        }
        
        self.textView.registerMarkdownFormattingSymbol("**", withTitle: "Bold")
        self.textView.registerMarkdownFormattingSymbol("*", withTitle: "Italics")
        self.textView.registerMarkdownFormattingSymbol("~~", withTitle: "Strike")
        self.textView.placeholder = NSLocalizedString("Write a message", comment: "")
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.checkGuidelinesAccepted(user: user)
        }).start())
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard(true)
        isScrolling = true
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        super.scrollViewDidEndDecelerating(scrollView)
        isScrolling = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let groupID = self.groupID {
            dataSource = GroupChatViewDataSource(groupID: groupID)
            dataSource?.tableView = tableView
            dataSource?.viewController = self
        }
        
        self.refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let groupID = self.groupID {
            socialRepository.markChatAsSeen(groupID: groupID).observeCompleted {}
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let acceptView = view.viewWithTag(999)
        acceptView?.frame = CGRect(x: 0, y: view.frame.size.height-90, width: view.frame.size.width, height: 90)
    }
    
    private func render(message: ChatMessage) {
        message.attributedText = try? Down(markdownString: message.text?.unicodeEmoji ?? "").toHabiticaAttributedString()
    }
    
    @objc
    func refresh() {
        if let groupID = self.groupID {
            socialRepository.retrieveGroup(groupID: groupID).observeCompleted {[weak self] in
                if #available(iOS 10.0, *) {
                    self?.tableView?.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    override func didPressRightButton(_ sender: Any?) {
        self.textView.refreshFirstResponder()
        let message = self.textView.text
        if let message = message, let groupID = self.groupID {
            socialRepository.post(chatMessage: message, toGroup: groupID).observeResult { (result) in
                switch result {
                case .failure:
                    self.textView.text = message
                case .success(_):
                    return
                }
            }
        }
        
        /*if let expandedIndexPath = self.expandedChatPath {
            expandSelectedCell(expandedIndexPath)
        }*/
        
        super.didPressRightButton(sender)
    }
    
    private func checkGuidelinesAccepted(user: UserProtocol) {
        let acceptView = view.viewWithTag(999)
        if !(user.flags?.communityGuidelinesAccepted ?? false) {
            if acceptView != nil {
                return
            }
            guard let acceptView = Bundle.main.loadNibNamed("GuidelinesPromptView", owner: self, options: nil)?[0] as? UIView else {
                return
            }
            let acceptButton = acceptView.viewWithTag(1) as? UIButton
            acceptButton?.addTarget(self, action: #selector(acceptGuidelines), for: .touchUpInside)
            let descriptionButton = acceptView.viewWithTag(2) as? UIButton
            descriptionButton?.addTarget(self, action: #selector(openGuidelinesView), for: .touchUpInside)
            acceptView.frame = CGRect(x: 0, y: view.frame.size.height-90, width: view.frame.size.width, height: 90)
            acceptView.tag = 999
            view.addSubview(acceptView)
        } else {
            acceptView?.removeFromSuperview()
        }
    }
    
    @objc
    private func openGuidelinesView() {
        self.performSegue(withIdentifier: "GuidelinesSegue", sender: self)
    }
    
    @IBAction func unwindToAcceptGuidelines(_ segue: UIStoryboardSegue) {
        acceptGuidelines()
    }
    
    @objc
    private func acceptGuidelines() {
        userRepository.updateUser(key: "flags.communityGuidelinesAccepted", value: true).observeCompleted {}
    }
    
    func configureReplyTo(_ username: String?) {
        self.textView.text = "@\(username ?? "") "
        self.textView.becomeFirstResponder()
        self.textView.selectedRange = NSRange(location: self.textView.text.count, length: 0)
    }

}
