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
    private var autocompleteUsernames: [MemberProtocol] = []

    var isScrolling = false
    let tableView = UITableView()

    lazy var autocompleteManager: AutocompleteManager = { [unowned self] in
        let manager = AutocompleteManager(for: self.inputBar.inputTextView)
        manager.delegate = self
        manager.dataSource = self
        return manager
    }()
    
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
        autocompleteManager.register(prefix: "@", with: [.font: UIFont.systemFont(ofSize: inputBar.inputTextView.font.pointSize, weight: .semibold),
                                                         .foregroundColor: ThemeService.shared.theme.tintColor,
                                                         .backgroundColor: ThemeService.shared.theme.tintColor.withAlphaComponent(0.8)])
        autocompleteManager.register(prefix: ":", with: [.font: UIFont.systemFont(ofSize: inputBar.inputTextView.font.pointSize, weight: .semibold)])
        inputBar.inputPlugins = [autocompleteManager]
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
        tableView.pin.top().start().end().bottom()
        var safearea: CGFloat = 0
        var tabbarOffset: CGFloat = (view.window?.safeAreaInsets.bottom ?? 0) + 40
        if tabBarController == nil {
            tabbarOffset = 0
            safearea = (view.window?.safeAreaInsets.bottom ?? 0)
        }
        var keyboardOffset = KeyboardManager.height > 0 ? KeyboardManager.height - tabbarOffset : safearea
        if (modalPresentationStyle == .pageSheet || modalPresentationStyle == .formSheet) && view.window?.traitCollection.isIPadFullSize == true {
            safearea = 0
            if (view.window?.bounds.size.height ?? 0) - KeyboardManager.height > view.bounds.size.height {
                keyboardOffset = 0
            } else {
                keyboardOffset = KeyboardManager.height - ((view.window?.bounds.height ?? 0) -  (abs(view?.window?.convert(CGPoint(x: 0, y: 0), to: view).y ?? 0) + view.bounds.height))
            }
        }
        let inputBarHeight = inputBar.requiredInputTextViewHeight + inputBar.padding.top + inputBar.padding.bottom + inputBar.topStackViewPadding.top
        let autocompleteSize = autocompleteManager.tableView.intrinsicContentSize
        let autocompleteHeight: CGFloat
        if autocompleteManager.currentSession != nil {
            autocompleteHeight = autocompleteSize.height
        } else {
            autocompleteHeight = 0
        }
        
        var inputBarOffset = keyboardOffset + autocompleteHeight
        if tabBarController != nil {
            inputBarOffset += inputBarHeight + autocompleteHeight
        } else {
            inputBarOffset -= 4
        }
        tableView.contentInset.top = inputBarOffset
        inputBar.pin.start().end().height(inputBarHeight + autocompleteHeight).bottom(keyboardOffset)
        let acceptView = view.viewWithTag(999)
        acceptView?.frame = CGRect(x: 0, y: view.frame.size.height-90, width: view.frame.size.width, height: 90)
        super.viewDidLayoutSubviews()
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
}

extension MessagesViewController: AutocompleteManagerDelegate, AutocompleteManagerDataSource {
    
    // MARK: - AutocompleteManagerDataSource
    func autocompleteManager(_ manager: AutocompleteManager, autocompleteSourceFor prefix: String) -> [AutocompleteCompletion] {
        if prefix == "@" {
            return autocompleteUsernames.map { AutocompleteCompletion(text: $0.username ?? "" ) }
        } else {
            return Emoji.allCases.map { AutocompleteCompletion(text: "\($0.shortnames.first ?? ""):") }
        }
    }
    
    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        guard autocompleteManager.currentSession?.prefix == "@" else {
            return
        }
        socialRepository.findUsernamesLocally(autocompleteManager.currentSession?.filter ?? text, id: nil)
            .on(value: {[weak self] usernames in
                self?.autocompleteUsernames = usernames
                self?.autocompleteManager.reloadData()
            })
            .start()
    }

    func autocompleteManager(_ manager: AutocompleteManager, tableView: UITableView, cellForRowAt indexPath: IndexPath, for session: AutocompleteSession) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AutocompleteCell.reuseIdentifier, for: indexPath) as? AutocompleteCell else {
            fatalError("Oops, some unknown error occurred")
        }
        var attributedText: NSAttributedString = manager.attributedText(matching: session, fontSize: 17, keepPrefix: session.prefix == "@" )
        if session.prefix == ":" {
            attributedText = NSAttributedString(string: ":\(session.completion?.text ?? "")".unicodeEmoji + " :") + attributedText
        }
        cell.textLabel?.attributedText = attributedText
        return cell
    }

    // MARK: - AutocompleteManagerDelegate
    func autocompleteManager(_ manager: AutocompleteManager, shouldBecomeVisible: Bool) {
        setAutocompleteManager(active: shouldBecomeVisible)
    }

    // MARK: - AutocompleteManagerDelegate Helper
    func setAutocompleteManager(active: Bool) {
        let topStackView = inputBar.topStackView
        if active && !topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.insertArrangedSubview(autocompleteManager.tableView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        } else if !active && topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
            topStackView.removeArrangedSubview(autocompleteManager.tableView)
            topStackView.layoutIfNeeded()
        }
        inputBar.invalidateIntrinsicContentSize()
    }
}
