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
    let inputBarContainer: UIVisualEffectView = UIVisualEffectView()
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
        view.addSubview(inputBarContainer)
        inputBarContainer.contentView.addSubview(inputBar)
        if #available(iOS 26.0, *) {
            inputBarContainer.effect = UIGlassEffect(style: .regular)
        } else {
            inputBarContainer.effect = UIBlurEffect(style: .systemMaterial)
        }
        inputBar.inputTextView.isImagePasteEnabled = false
        inputBarContainer.cornerRadius = UIConstants.largeCornerRadius
        inputBar.backgroundColor = .clear
        inputBar.backgroundView.backgroundColor = .clear
        inputBar.separatorLine.isHidden = true
        autocompleteManager.tableView.backgroundColor = .clear
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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.insetsContentViewsToSafeArea = false
        tableView.insetsLayoutMarginsFromSafeArea = false
        tableView.contentInsetAdjustmentBehavior = .never
        
        #if !targetEnvironment(macCatalyst)
            tableView.refreshControl = HabiticaRefresControl()
            tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        #endif
        
        inputBar.delegate = self
        inputBar.inputTextView.keyboardType = .twitter
        inputBar.inputTextView.placeholder = L10n.writeMessage
        inputBar.bottomStackView.isHidden = true
        let configuration = UIImage.SymbolConfiguration(pointSize: 32)
        inputBar.sendButton.image = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: configuration)?.withRenderingMode(.alwaysTemplate)
        inputBar.sendButton.title = nil
        inputBar.sendButton.alpha = 0
        inputBar.sendButton.transform = CGAffineTransform(translationX: 30, y: 0)
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
        inputBar.sendButton.setTitleColor(theme.dimmedTextColor, for: .disabled)
        if #available(iOS 26.0, *) {
            (inputBarContainer.effect as? UIGlassEffect)?.tintColor = theme.contentBackgroundColor
        }
        tableView.backgroundColor = theme.windowBackgroundColor
        tableView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.tableView.visibleCells.forEach { $0.setNeedsLayout() }
        })
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false
    }

    override func viewDidLayoutSubviews() {
        if view.frame.height > (parent?.view.frame.height ?? 0) {
            super.viewDidLayoutSubviews()
            return
        }
        tableView.pin.all()
        let safearea = view.window?.safeAreaInsets ?? .zero
        var safeheight: CGFloat = (tabBarController?.tabBar.frame.size.height ?? safearea.bottom)
        var keyboardOffset = (KeyboardManager.height > 0 ? KeyboardManager.height : safeheight) + 12
        if (modalPresentationStyle == .pageSheet || modalPresentationStyle == .formSheet) && traitCollection.isIPadFullSize == true {
            if (view.window?.bounds.size.height ?? 0) - KeyboardManager.height > view.bounds.size.height {
                keyboardOffset = safearea.bottom + 16
            } else {
                keyboardOffset = KeyboardManager.height - ((view.window?.bounds.height ?? 0) -  (abs(view?.window?.convert(CGPoint(x: 0, y: 0), to: view).y ?? 0) + view.bounds.height))
            }
        }
        let textViewHeight = inputBar.maxTextViewHeight > 0 ? min(inputBar.requiredInputTextViewHeight, inputBar.maxTextViewHeight) : inputBar.requiredInputTextViewHeight
        let inputBarHeight = textViewHeight + inputBar.padding.top + inputBar.topStackViewPadding.top + 2
        let autocompleteSize = autocompleteManager.tableView.intrinsicContentSize
        let autocompleteHeight: CGFloat
        if autocompleteManager.currentSession != nil {
            autocompleteHeight = autocompleteSize.height
        } else {
            autocompleteHeight = 0
        }

        let inputBarOffset = keyboardOffset + autocompleteHeight + inputBarHeight + 10
        tableView.contentInset.top = inputBarOffset + 16
        tableView.contentInset.bottom = navigationController?.navigationBar.frame.totalHeight ?? 0
        inputBarContainer.pin.left(safearea.left + 20)
            .right(safearea.right + 20)
            .height(inputBarHeight + autocompleteHeight + 10)
            .bottom(keyboardOffset == 0 && safeheight == 0 ? safearea.bottom + 8 : keyboardOffset)
        inputBar.pin.start(8).end(-10).top().bottom()
        inputBar.inputTextView.contentInset = .zero
        if let acceptView = view.viewWithTag(999) {
            acceptView.pin.left(20).right(20).bottom((tabBarController?.tabBar.frame.height ?? 0) + 6).height(90)
        }
        super.viewDidLayoutSubviews()
    }
    
    @objc
    func refresh() {
    }
    
    private func checkGuidelinesAccepted(user: UserProtocol) {
        let acceptView = view.viewWithTag(999)
        if acceptView == nil && !(user.flags?.communityGuidelinesAccepted ?? false) {
            guard let acceptView = Bundle.main.loadNibNamed("GuidelinesPromptView", owner: self, options: nil)?[0] as? UIView else {
                return
            }
            let acceptButton = acceptView.viewWithTag(1) as? UIButton
            acceptButton?.setTitle(L10n.accept, for: .normal)
            acceptButton?.addTarget(self, action: #selector(acceptGuidelines), for: .touchUpInside)
            if #available(iOS 26.0, *) {
                acceptButton?.cornerConfiguration = .capsule()
            } else {
                acceptButton?.cornerRadius = UIConstants.largeCornerRadius
            }
            let descriptionButton = acceptView.viewWithTag(2) as? UIButton
            descriptionButton?.addTarget(self, action: #selector(openGuidelinesView), for: .touchUpInside)
            acceptView.frame = CGRect(x: 0, y: view.frame.size.height-90, width: view.frame.size.width, height: 90)
            acceptView.tag = 999
            acceptView.cornerRadius = UIConstants.largeCornerRadius
            view.addSubview(acceptView)
        } else if acceptView != nil && (user.flags?.communityGuidelinesAccepted ?? false) {
            acceptView?.removeFromSuperview()
        } else {
            return
        }
        view.setNeedsLayout()
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
        if text.isEmpty && inputBar.sendButton.isAnimating {
            return
        }
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 4) {
            inputBar.sendButton.alpha = text.isEmpty ? 0 : 1
            inputBar.sendButton.transform = CGAffineTransform(translationX: text.isEmpty ? 30 : 0, y: 0)
        }
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
        cell.backgroundColor = .clear
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
