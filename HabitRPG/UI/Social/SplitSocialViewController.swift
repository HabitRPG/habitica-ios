//
//  HabiticaSplitViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 21.02.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift

class SplitSocialViewController: HabiticaSplitViewController {
    
    override var viewID: String? {
        get {
            return groupID
        }
        set {
            groupID = newValue
        }
    }
    
    @objc var groupID: String? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.chatViewController?.groupID = self?.groupID
                self?.detailViewController?.groupID = self?.groupID
                self?.retrieveGroup()
                self?.fetchGroup()
            }
        }
    }
    
    var isGroupOwner = false {
        didSet {
            if isGroupOwner {
                navigationItem.rightBarButtonItem = editGroupButton
            } else {
                navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    weak var detailViewController: GroupDetailViewController?
    weak var chatViewController: GroupChatViewController?
    
    @IBOutlet var editGroupButton: UIBarButtonItem?
    
    private let socialRepository = SocialRepository()
    let disposable = ScopedDisposable(CompositeDisposable())
    var fetchGroupDisposable: Disposable?

    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.setTitle(L10n.details, forSegmentAt: 0)
        segmentedControl.setTitle(L10n.chat, forSegmentAt: 1)
        
        showAsSplitView = traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular
        
        scrollView.delegate = self
        
        for childViewController in children {
            if let viewController = childViewController as? GroupDetailViewController {
                detailViewController = viewController
            }
            if let viewController = childViewController as? GroupChatViewController {
                chatViewController = viewController
            }
        }
        navigationItem.rightBarButtonItem = nil
        
        view.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
    }
    
    deinit {
        if let disposable = fetchGroupDisposable {
            disposable.dispose()
        }
    }
    
    func retrieveGroup() {
        if let groupID = self.groupID {
            disposable.inner.add(socialRepository.retrieveGroup(groupID: groupID)
                    .flatMap(.latest) {[weak self] _ -> Signal<[MemberProtocol]?, Never> in
                        if  groupID != Constants.TAVERN_ID {
                            return self?.socialRepository.retrieveGroupMembers(groupID: groupID) ?? Signal.empty
                        }
                        return Signal.empty
                     }
                    .observeCompleted {})
        }
    }
    
    func fetchGroup() {
        guard let groupID = self.groupID else {
            return
        }
        if let disposable = self.fetchGroupDisposable {
            disposable.dispose()
        }
        fetchGroupDisposable = socialRepository.getGroup(groupID: groupID).skipNil().on(value: {[weak self] group in
            DispatchQueue.main.async {
                self?.set(group: group)
            }
            self?.isGroupOwner = group.leaderID == self?.socialRepository.currentUserId
        }).start()
    }
    
    internal func set(group: GroupProtocol) {
        detailViewController?.groupProperty.value = group
        if group.type == "guild" {
            if group.privacy == "public" {
                chatViewController?.autocompleteContext = "publicGuild"
            } else {
                chatViewController?.autocompleteContext = "privateGuild"
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let chatViewController  = segue.destination as? GroupChatViewController {
            chatViewController.groupID = groupID
        } else if segue.identifier == StoryboardSegue.Social.formSegue.rawValue {
            let destination = segue.destination as? UINavigationController
            if let formViewController = destination?.topViewController as? GroupFormViewController {
                formViewController.groupID = groupID
            }
        } else if segue.identifier == StoryboardSegue.Social.invitationSegue.rawValue {
            let destination = segue.destination as? UINavigationController
            if let invitationViewController = destination?.topViewController as? InviteMembersViewController {
                invitationViewController.groupID = groupID
            }
        }
    }
    
    @IBAction func unwindToList(_ segue: UIStoryboardSegue) {
    }
}
