//
//  MessagesViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 07.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import UIKit
import ReactiveSwift
import Habitica_Models
import InputBarAccessoryView

class MessagesViewController: BaseUIViewController, UITableViewDelegate, UIScrollViewDelegate {
    let inputBar: InputBarAccessoryView = InputBarAccessoryView()

    let socialRepository = SocialRepository()
    private let userRepository = UserRepository()
    private let configRepository = ConfigRepository.shared
    
    @objc public var autocompleteContext = "guild"
    private let disposable = ScopedDisposable(CompositeDisposable())
    private var autocompleteUsernamesObserver: Signal<String, Never>.Observer?
    private var autocompleteUsernames: [MemberProtocol] = []
    private var autocompleteEmojisObserver: Signal<String, Never>.Observer?
    private var autocompleteEmojis: [String] = []
    
    var isScrolling = false
    let tableView = UITableView()

    override func loadView() {
        view = UIView()
        view.addSubview(tableView)
        view.addSubview(inputBar)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true

        let nib = UINib(nibName: "ChatMessageCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ChatMessageCell")
        let systemNib = UINib(nibName: "SystemMessageTableViewCell", bundle: nil)
        tableView.register(systemNib, forCellReuseIdentifier: "SystemMessageCell")
        
        tableView.delegate = self
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        tableView.keyboardDismissMode = .interactive
        #if !targetEnvironment(macCatalyst)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        #endif
        
        inputBar.delegate = self
        inputBar.inputTextView.keyboardType = .twitter
        inputBar.inputTextView.placeholder = L10n.writeMessage
        inputBar.bottomStackView.isHidden = true
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.checkGuidelinesAccepted(user: user)
        }).start())
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        KeyboardManager.addObservingView(view)
    }
    
    override func applyTheme(theme: Theme) {
        inputBar.inputTextView.textColor = theme.primaryTextColor
        inputBar.inputTextView.tintColor = theme.tintColor
        inputBar.sendButton.tintColor = theme.tintColor
        inputBar.sendButton.setTitleColor(theme.tintColor, for: .normal)
        tableView.backgroundColor = theme.windowBackgroundColor
        tableView.reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.pin.top().start().end().bottom()
        var tabbarOffset: CGFloat = (view.window?.safeAreaInsets.bottom ?? 0) + 40
        var safearea: CGFloat = 0
        if tabBarController == nil {
            tabbarOffset = 0
            safearea = (view.window?.safeAreaInsets.bottom ?? 0)
        }
        let keyboardOffset = KeyboardManager.height > 0 ? KeyboardManager.height - tabbarOffset : safearea
        tableView.contentInset.top = inputBar.intrinsicContentSize.height + keyboardOffset
        inputBar.pin.start().end().height(inputBar.intrinsicContentSize.height).bottom(keyboardOffset)
        let acceptView = view.viewWithTag(999)
        acceptView?.frame = CGRect(x: 0, y: view.frame.size.height-90, width: view.frame.size.width, height: 90)
    }
    
    @objc
    func refresh() {
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
        performSegue(withIdentifier: "GuidelinesSegue", sender: self)
    }
    
    @IBAction func unwindToAcceptGuidelines(_ segue: UIStoryboardSegue) {
        acceptGuidelines()
    }
    
    @objc
    private func acceptGuidelines() {
        userRepository.updateUser(key: "flags.communityGuidelinesAccepted", value: true).observeCompleted {}
    }
    
    func configureReplyTo(name: String?) {
        let textView = inputBar.inputTextView
        if textView.text.isEmpty == false {
            textView.text = "\(textView.text ?? "") @\(name ?? "") "
        } else {
            textView.text = "@\(name ?? "") "
        }
        textView.becomeFirstResponder()
        textView.selectedRange = NSRange(location: textView.text.count, length: 0)
    }
}

extension MessagesViewController: InputBarAccessoryViewDelegate {
    
    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        view.setNeedsLayout()
    }
    
    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        
    }
    
}
