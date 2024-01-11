//
//  GroupChatViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 17.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Down
import Habitica_Models
import ReactiveSwift
import InputBarAccessoryView

class GroupChatViewController: MessagesViewController {
    
    @objc public var groupID: String? {
        didSet {
            if dataSource == nil, let groupID = self.groupID {
                setupDataSource(groupID: groupID)
            }
            if groupID != oldValue {
                refresh()
            }
        }
    }
    private var dataSource: GroupChatViewDataSource?

    override func viewWillAppear(_ animated: Bool) {
        autocompleteContext = "guild"
        super.viewWillAppear(animated)
        
        if let groupID = self.groupID {
            setupDataSource(groupID: groupID)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        dataSource = nil
        super.viewDidDisappear(animated)
    }

    private func setupDataSource(groupID: String) {
        dataSource = GroupChatViewDataSource(groupID: groupID)
        dataSource?.tableView = tableView
        dataSource?.viewController = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let groupID = self.groupID {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.socialRepository.markChatAsSeen(groupID: groupID).observeCompleted {}
            }
        }
    }
    
    @objc
    override func refresh() {
        dataSource?.retrieveData(completed: {[weak self] in
            self?.tableView.refreshControl?.endRefreshing()
        })
    }
    
    override func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard let message = inputBar.inputTextView.text else {
            return
        }

        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()

        // Send button activity animation
        inputBar.sendButton.startAnimating()
        UIImpactFeedbackGenerator.oneShotImpactOccurred(.light)
        socialRepository.post(chatMessage: message, toGroup: groupID ?? "").observeResult { (result) in
            inputBar.sendButton.stopAnimating()
            switch result {
            case .failure:
                inputBar.inputTextView.text = message
            case .success:
                return
            }
        }
    }
}
