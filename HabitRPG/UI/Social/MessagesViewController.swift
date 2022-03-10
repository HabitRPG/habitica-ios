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

class MessagesViewController: BaseTableViewController {
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

    override func loadView() {
        view = UITableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true

        let nib = UINib(nibName: "ChatMessageCell", bundle: nil)
        tableView?.register(nib, forCellReuseIdentifier: "ChatMessageCell")
        let systemNib = UINib(nibName: "SystemMessageTableViewCell", bundle: nil)
        tableView?.register(systemNib, forCellReuseIdentifier: "SystemMessageCell")
        
        tableView?.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView?.separatorStyle = .none
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 90
        #if !targetEnvironment(macCatalyst)
        tableView?.refreshControl = UIRefreshControl()
        tableView?.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        #endif

        let (signal, observer) = Signal<String, Never>.pipe()
        autocompleteUsernamesObserver = observer
        
        /*if configRepository.bool(variable: .enableUsernameAutocomplete) {
            disposable.inner.add(signal
                .filter({ username -> Bool in return !username.isEmpty })
                .throttle(2, on: QueueScheduler.main)
                .flatMap(.latest, {[weak self] username in
                    self?.socialRepository.findUsernames(username, context: self?.autocompleteContext, id: self?.groupID) ?? Signal.empty
                })
                .observeValues({[weak self] members in
                    self?.autocompleteUsernames = members
                    if self?.foundWord != nil {
                    }
                })
            )
        } else {
            disposable.inner.add(signal
                .filter({ username -> Bool in return !username.isEmpty })
                .flatMap(.latest, {[weak self] username in
                    self?.socialRepository.findUsernamesLocally(username, id: self?.groupID) ?? SignalProducer.empty
                })
                .observeValues({[weak self] (members) in
                    self?.autocompleteUsernames = members
                    if self?.foundWord != nil {
                    }
                }))
        }*/
        
        let (emojiSignal, emojiObserver) = Signal<String, Never>.pipe()
        autocompleteEmojisObserver = emojiObserver
        disposable.inner.add(emojiSignal
            .filter { emoji -> Bool in return !emoji.isEmpty }
            .throttle(0.5, on: QueueScheduler.main)
            .observeValues({[weak self] emoji in
            self?.autocompleteEmojis = Emoji.allCases.flatMap { $0.shortnames }.filter({ name in
                return name.contains(emoji)
            })
            })
        )
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.checkGuidelinesAccepted(user: user)
        }).start())
    }
    
    override func applyTheme(theme: Theme) {
        tableView?.backgroundColor = theme.windowBackgroundColor
        tableView?.reloadData()
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //dismissKeyboard(true)
        isScrolling = true
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        super.scrollViewDidEndDecelerating(scrollView)
        isScrolling = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let acceptView = view.viewWithTag(999)
        acceptView?.frame = CGRect(x: 0, y: view.frame.size.height-90, width: view.frame.size.width, height: 90)
    }
    
    @objc
    func refresh() {
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
}
