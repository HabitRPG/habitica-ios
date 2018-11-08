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
import Habitica_Models
import ReactiveSwift

class GroupChatViewController: SLKTextViewController {
    
    @objc public var groupID: String? {
        didSet {
            if dataSource == nil, let groupID = self.groupID {
                setupDataSource(groupID: groupID)
            }
            if groupID != oldValue {
                self.refresh()
            }
        }
    }
    private var dataSource: GroupChatViewDataSource?
    var isScrolling = false
    
    private let socialRepository = SocialRepository()
    private let userRepository = UserRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true
               
        let nib = UINib(nibName: "ChatMessageCell", bundle: nil)
        tableView?.register(nib, forCellReuseIdentifier: "ChatMessageCell")
        let systemNib = UINib(nibName: "SystemMessageTableViewCell", bundle: nil)
        tableView?.register(systemNib, forCellReuseIdentifier: "SystemMessageCell")
        
        tableView?.separatorStyle = .none
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 90
        tableView?.backgroundColor = UIColor.gray700()

        if #available(iOS 10.0, *) {
            tableView?.refreshControl = UIRefreshControl()
            tableView?.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        }
        
        textView.registerMarkdownFormattingSymbol("**", withTitle: "Bold")
        textView.registerMarkdownFormattingSymbol("*", withTitle: "Italics")
        textView.registerMarkdownFormattingSymbol("~~", withTitle: "Strike")
        textView.placeholder = NSLocalizedString("Write a message", comment: "")
        textInputbar.maxCharCount = UInt(ConfigRepository().integer(variable: .maxChatLength))
        textInputbar.charCountLabelNormalColor = UIColor.gray400()
        textInputbar.charCountLabelWarningColor = UIColor.red50()
        textInputbar.charCountLabel.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        
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
            setupDataSource(groupID: groupID)
        }
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        let textLength = textView.text.count
        if textLength > Int(Double(textInputbar.maxCharCount) * 0.95) {
            textInputbar.charCountLabelNormalColor = UIColor.yellow5()
        } else {
            textInputbar.charCountLabelNormalColor = UIColor.gray400()
        }
    }
    
    private func setupDataSource(groupID: String) {
        dataSource = GroupChatViewDataSource(groupID: groupID)
        dataSource?.tableView = tableView
        dataSource?.viewController = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let groupID = self.groupID, groupID != Constants.TAVERN_ID {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.socialRepository.markChatAsSeen(groupID: groupID).observeCompleted {}
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let acceptView = view.viewWithTag(999)
        acceptView?.frame = CGRect(x: 0, y: view.frame.size.height-90, width: view.frame.size.width, height: 90)
    }
    
    @objc
    func refresh() {
        if let groupID = self.groupID {
            socialRepository.retrieveChat(groupID: groupID).observeCompleted {[weak self] in
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
        if textView.text.count > 0 {
            textView.text = "\(textView.text ?? "") @\(username ?? "") "
        } else {
            textView.text = "@\(username ?? "") "
        }
        textView.becomeFirstResponder()
        textView.selectedRange = NSRange(location: self.textView.text.count, length: 0)
    }

}
