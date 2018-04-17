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
    
    @objc var groupID: String?
    
    weak var detailViewController: GroupDetailViewController?
    weak var chatViewController: GroupChatViewController?
    
    private let socialRepository = SocialRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        segmentedControl.setTitle(L10n.details, forSegmentAt: 0)
        segmentedControl.setTitle(L10n.chat, forSegmentAt: 1)
        
        showAsSplitView = traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular
        
        scrollView.delegate = self
        
        for childViewController in childViewControllers {
            if let viewController = childViewController as? GroupDetailViewController {
                detailViewController = viewController
            }
            if let viewController = childViewController as? GroupChatViewController {
                chatViewController = viewController
            }
        }
        
        if let groupID = self.groupID {
            disposable.inner.add(socialRepository.getGroup(groupID: groupID).skipNil().on(value: {[weak self] group in
                self?.set(group: group)
            }).start())
        }
    }
    
    internal func set(group: GroupProtocol) {
        //detailViewController?.group = group
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailViewController = segue.destination as? GroupDetailViewController {
            detailViewController.groupID = groupID
        } else if let chatViewController  = segue.destination as? GroupChatViewController {
            chatViewController.groupID = groupID
        }
    }
}
