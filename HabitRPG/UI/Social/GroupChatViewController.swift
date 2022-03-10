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
    override func refresh() {
        dataSource?.retrieveData(completed: {[weak self] in
            self?.tableView?.refreshControl?.endRefreshing()
        })
    }
    
    /*override func didPressRightButton(_ sender: Any?) {
        self.textView.refreshFirstResponder()
        let message = textView.text
        if let message = message, let groupID = self.groupID {
            UIImpactFeedbackGenerator.oneShotImpactOccurred(.light)
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
        if tableView == autoCompletionView {
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
        let cellHeight = autoCompletionView.delegate?.tableView?(autoCompletionView, heightForRowAt: IndexPath(row: 0, section: 0))
        guard let height = cellHeight else {
            return 0
        }
        return height * CGFloat(count)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == autoCompletionView {
            var item = ""
            if self.foundPrefix == "@" {
                item += autocompleteUsernames[indexPath.row].username ?? ""
                if foundPrefixRange.location == 0 {
                    item += ":"
                }
            } else if foundPrefix == ":" || foundPrefix == "+:" {
                var cheatcode = autocompleteEmojis[indexPath.row]
                cheatcode.remove(at: cheatcode.startIndex)
                item += cheatcode
            }
            item += " "
            acceptAutoCompletion(with: item, keepPrefix: true)
        }
    }
    
    func configureReplyTo(_ username: String?) {
        if textView.text.isEmpty == false {
            textView.text = "\(textView.text ?? "") @\(username ?? "") "
        } else {
            textView.text = "@\(username ?? "") "
        }
        textView.becomeFirstResponder()
        textView.selectedRange = NSRange(location: textView.text.count, length: 0)
    }*/

}
