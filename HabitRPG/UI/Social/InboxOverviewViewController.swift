//
//  InboxOverviewViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 09.09.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

class InboxOverviewViewController: BaseTableViewController {
    
    private let dataSource = InboxOverviewDataSource()
    
    private let socialRepository = SocialRepository()
    
    private var newMessageUsername: String?
    
    override func viewDidLoad() {
        tutorialIdentifier = "inbox"
        super.viewDidLoad()
        dataSource.tableView = tableView
        clearsSelectionOnViewWillAppear = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        tableView.backgroundColor = theme.contentBackgroundColor
        view.backgroundColor = theme.contentBackgroundColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataSource.markInboxSeen()
    }
    
    @objc
    private func refresh() {
        dataSource.refresh {[weak self] in
            self?.refreshControl?.endRefreshing()
        }
    }
    
    override func getDefinitonForTutorial(_ tutorialIdentifier: String!) -> [AnyHashable : Any]! {
        if tutorialIdentifier == self.tutorialIdentifier {
            return [
                "text": L10n.Tutorials.inbox
            ]
        }
        return nil
    }
    
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == StoryboardSegue.Social.chatSegue.rawValue {
               if let chatViewController = segue.destination as? InboxChatViewController {
                   if let username = newMessageUsername {
                       chatViewController.username = username
                       newMessageUsername = nil
                   } else {
                       if let cell = sender as? UITableViewCell {
                         guard let indexPath = tableView.indexPath(for: cell) else {
                             return
                         }
                         let message = dataSource.item(at: indexPath)
                         chatViewController.userID = message?.uuid
                         chatViewController.displayName = message?.displayName
                       }
                   }
               }
           }
       }

    @IBAction func showNewMessageAlert(_ sender: Any) {
        let alertController = HabiticaAlertController(title: L10n.newMessage)
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        let usernameTextField = UITextField()
        usernameTextField.attributedPlaceholder = NSAttributedString(string: L10n.username, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.autocapitalizationType = .none
        usernameTextField.spellCheckingType = .no
        usernameTextField.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        usernameTextField.textColor = ThemeService.shared.theme.primaryTextColor
        stackView.addArrangedSubview(usernameTextField)
        alertController.contentView = stackView
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.isHidden = true
        stackView.addArrangedSubview(activityIndicator)
        
        let errorView = UILabel()
        errorView.isHidden = true
        errorView.textColor = ThemeService.shared.theme.errorColor
        errorView.text = L10n.Errors.userNotFound
        stackView.addArrangedSubview(errorView)

        alertController.addCancelAction()
        var foundUser = false
        alertController.addAction(title: L10n.next, isMainAction: true, closeOnTap: false) {[weak self] dialog in
            activityIndicator.isHidden = false
            errorView.isHidden = true
            activityIndicator.startAnimating()
            if let username = usernameTextField.text {
                self?.socialRepository.retrieveMember(userID: username).on(
                    value: { _ in
                        foundUser = true
                        alertController.dismiss(animated: true, completion: {
                            self?.perform(segue: StoryboardSegue.Social.chatSegue)
                        })
                }
                ).observeCompleted {
                    activityIndicator.isHidden = true
                    if !foundUser {
                        errorView.isHidden = false
                    }
                }
                self?.newMessageUsername = username
                
            }
        }
        alertController.show()
    }
}
