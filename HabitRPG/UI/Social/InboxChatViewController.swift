//
//  InboxChatViewController.swift
//
//
//  Created by Phillip Thelen on 09.09.19.
//

import UIKit
import InputBarAccessoryView

class InboxChatViewController: MessagesViewController {
    @objc var userID: String?
    var displayName: String?
    var username: String?
    var isPresentedModally = false
    
    private lazy var dataSource: InboxMessagesDataSource = {
        return InboxMessagesDataSource(otherUserID: userID, otherUsername: username)
    }()

    @IBOutlet var profileBarButton: UIBarButtonItem!
    @IBOutlet var doneBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.tableView = tableView
        dataSource.viewController = self
        
        tableView.register(UINib(nibName: "EmptyTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "emptyCell")
        dataSource.emptyDataSource = SingleItemTableViewDataSource<EmptyTableViewCell>(cellIdentifier: "emptyCell", styleFunction: EmptyTableViewCell.inboxChatStyle)
        
        if isPresentedModally {
            navigationItem.setRightBarButtonItems([doneBarButton], animated: false)
        } else {
            navigationItem.setRightBarButtonItems([profileBarButton], animated: false)
        }
                
        if let topHeaderNavigationController = navigationController as? TopHeaderViewController {
            topHeaderNavigationController.shouldHideTopHeader = true
            topHeaderNavigationController.hideNavbar = false
        }
        
        ThemeService.shared.addThemeable(themable: self)
        
        refresh()
    }

    @objc
    override func refresh() {
        dataSource.retrieveData(forced: true) {[weak self] in
            #if !targetEnvironment(macCatalyst)
            self?.tableView.refreshControl?.endRefreshing()
            #endif
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let topHeaderNavigationController = navigationController as? TopHeaderViewController {
            topHeaderNavigationController.scrollView(tableView, scrolledToPosition: 0)
        }
    }
    
    func setTitleWith(username: String?) {
        if let username = username {
            navigationItem.title = L10n.writeTo(username)
        } else {
            navigationItem.title = L10n.writeMessage
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Social.userProfileSegue.rawValue {
            let profileViewController = segue.destination as? UserProfileViewController
            profileViewController?.userID = userID
            profileViewController?.username = username
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.item == dataSource.tableView(tableView, numberOfRowsInSection: indexPath.section)-1 {
            dataSource.retrieveData(forced: false) {
                #if !targetEnvironment(macCatalyst)
                self.tableView.refreshControl?.endRefreshing()
                #endif
            }
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: UIView) {
        dismiss(animated: true, completion: nil)
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
        socialRepository.post(inboxMessage: message, toUserID: userID ?? "").observeResult { (result) in
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
