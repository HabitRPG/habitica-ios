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
    @objc public var autocompleteContext = "guild"
    private var dataSource: GroupChatViewDataSource?
    var isScrolling = false
    
    private let socialRepository = SocialRepository()
    private let userRepository = UserRepository()
    private let configRepository = ConfigRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    private var autocompleteUsernamesObserver: Signal<String, Never>.Observer?
    private var autocompleteUsernames: [MemberProtocol] = []
    private var autocompleteEmojisObserver: Signal<String, Never>.Observer?
    private var autocompleteEmojis: [String] = []
    
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
        tableView?.backgroundColor = ThemeService.shared.theme.windowBackgroundColor

        if #available(iOS 10.0, *) {
            tableView?.refreshControl = UIRefreshControl()
            tableView?.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        }
        
        textView.registerMarkdownFormattingSymbol("**", withTitle: "Bold")
        textView.registerMarkdownFormattingSymbol("*", withTitle: "Italics")
        textView.registerMarkdownFormattingSymbol("~~", withTitle: "Strike")
        textView.placeholder = L10n.writeMessage
        textInputbar.maxCharCount = UInt(ConfigRepository().integer(variable: .maxChatLength))
        textInputbar.charCountLabelNormalColor = UIColor.gray400()
        textInputbar.charCountLabelWarningColor = UIColor.red50()
        textInputbar.charCountLabel.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        textInputbar.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        textInputbar.textView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        textInputbar.textView.placeholderColor = ThemeService.shared.theme.dimmedTextColor
        textInputbar.textView.textColor = ThemeService.shared.theme.primaryTextColor
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.checkGuidelinesAccepted(user: user)
        }).start())
        
        self.registerPrefixes(forAutoCompletion: ["@", ":"])
        let (signal, observer) = Signal<String, Never>.pipe()
        autocompleteUsernamesObserver = observer
        
        if configRepository.bool(variable: .enableUsernameAutocomplete) {
            disposable.inner.add(signal
                .filter({ username -> Bool in return !username.isEmpty })
                .throttle(2, on: QueueScheduler.main)
                .flatMap(.latest, { username in
                    self.socialRepository.findUsernames(username, context: self.autocompleteContext, id: self.groupID)
                })
                .observeValues({ members in
                    self.autocompleteUsernames = members
                    if self.foundWord != nil {
                        self.showAutoCompletionView(self.autocompleteUsernames.isEmpty == false)
                    }
                })
            )
        } else {
            disposable.inner.add(signal
                .filter({ username -> Bool in return !username.isEmpty })
                .flatMap(.latest, { username in
                    self.socialRepository.findUsernamesLocally(username, id: self.groupID)
                })
                .observeValues({ (members) in
                    self.autocompleteUsernames = members
                    if self.foundWord != nil {
                        self.showAutoCompletionView(self.autocompleteUsernames.isEmpty == false)
                    }
                }))
        }
        
        let (emojiSignal, emojiObserver) = Signal<String, Never>.pipe()
        autocompleteEmojisObserver = emojiObserver
        disposable.inner.add(emojiSignal
            .filter { emoji -> Bool in return !emoji.isEmpty }
            .throttle(0.5, on: QueueScheduler.main)
            .observeValues({ emoji in
                self.autocompleteEmojis = NSString.emojiCheatCodes(matching: emoji)
                self.showAutoCompletionView(self.autocompleteEmojis.isEmpty == false)
            })
        )
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView != autoCompletionView {
            dismissKeyboard(true)
            isScrolling = true
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        super.scrollViewDidEndDecelerating(scrollView)
        if scrollView != autoCompletionView {
            isScrolling = false
        }
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
            if #available(iOS 10.0, *) {
                UIImpactFeedbackGenerator.oneShotImpactOccurred(.light)
            }
            socialRepository.post(chatMessage: message, toGroup: groupID).observeResult { (result) in
                switch result {
                case .failure:
                    self.textView.text = message
                case .success:
                    return
                }
            }
        }
        
        /*if let expandedIndexPath = self.expandedChatPath {
            expandSelectedCell(expandedIndexPath)
        }*/
        
        super.didPressRightButton(sender)
    }

    override func didChangeAutoCompletionPrefix(_ prefix: String, andWord word: String) {
        if prefix == "@" {
            
            autocompleteUsernamesObserver?.send(value: word)
        } else if prefix == ":" {
            autocompleteEmojisObserver?.send(value: word)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if foundPrefix == "@" {
            return autocompleteUsernames.count
        } else if foundPrefix == ":" {
            return autocompleteEmojis.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if foundPrefix == "@" {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "UsernameCell")
            let member = autocompleteUsernames[indexPath.item]
            cell.textLabel?.text = member.profile?.name
            cell.textLabel?.textColor = member.contributor?.color
            cell.detailTextLabel?.text = "@\(member.username ?? "")"
            return cell
            
        } else if foundPrefix == ":" {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "EmojiCell")
            cell.textLabel?.text = autocompleteEmojis[indexPath.item]
            cell.detailTextLabel?.text = autocompleteEmojis[indexPath.item].unicodeEmoji
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.autoCompletionView {
            if foundPrefix == "@" {
                return 60
            } else if foundPrefix == ":" {
                return 44
            }
        }
        return UITableView.automaticDimension
    }
    
    override func heightForAutoCompletionView() -> CGFloat {
        var count = 0
        if foundPrefix == "@" {
            count = autocompleteUsernames.count
        } else if foundPrefix == ":" {
            count = autocompleteEmojis.count
        }
        // swiftlint:disable:next empty_count
        if count == 0 {
            return 0
        }
        let cellHeight = self.autoCompletionView.delegate?.tableView?(self.autoCompletionView, heightForRowAt: IndexPath(row: 0, section: 0))
        guard let height = cellHeight else {
            return 0
        }
        return height * CGFloat(count)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.autoCompletionView {
            var item = ""
            if self.foundPrefix == "@" {
                item += autocompleteUsernames[indexPath.row].username ?? ""
                if self.foundPrefixRange.location == 0 {
                    item += ":"
                }
            } else if self.foundPrefix == ":" || self.foundPrefix == "+:" {
                var cheatcode = autocompleteEmojis[indexPath.row]
                cheatcode.remove(at: cheatcode.startIndex)
                item += cheatcode
            }
            item += " "
            self.acceptAutoCompletion(with: item, keepPrefix: true)
        }
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
            acceptButton?.setTitle(L10n.accept, for: .normal)
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
        if textView.text.isEmpty == false {
            textView.text = "\(textView.text ?? "") @\(username ?? "") "
        } else {
            textView.text = "@\(username ?? "") "
        }
        textView.becomeFirstResponder()
        textView.selectedRange = NSRange(location: self.textView.text.count, length: 0)
    }

}
