//
//  InboxChatViewController.swift
//
//
//  Created by Phillip Thelen on 09.09.19.
//

import Foundation

class InboxChatViewController: SLKTextViewController, Themeable {
    @objc var userID: String?
    var displayName: String?
    var username: String?
    var isPresentedModally = false
    var isScrolling = false
    
    private lazy var dataSource: InboxMessagesDataSource = {
        return InboxMessagesDataSource(otherUserID: userID, otherUsername: username)
    }()
    private var configRepository = ConfigRepository()
    private let refreshControl = UIRefreshControl()

    @IBOutlet var profileBarButton: UIBarButtonItem!
    @IBOutlet var doneBarButton: UIBarButtonItem!
    
    override class func tableViewStyle(for decoder: NSCoder) -> UITableView.Style {
        return .plain
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.tableView = tableView
        dataSource.viewController = self
        
        let nib = UINib(nibName: "ChatMessageCell", bundle: nil)
        tableView?.register(nib, forCellReuseIdentifier: "ChatMessageCell")
        tableView?.register(UINib(nibName: "EmptyTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "emptyCell")
        dataSource.emptyDataSource = SingleItemTableViewDataSource<EmptyTableViewCell>(cellIdentifier: "emptyCell", styleFunction: EmptyTableViewCell.inboxChatStyle)
        
        if isPresentedModally {
            navigationItem.setRightBarButtonItems([doneBarButton], animated: false)
        } else {
            navigationItem.setRightBarButtonItems([profileBarButton], animated: false)
        }
        
        tableView?.separatorStyle = .none
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 90
        tableView?.delegate = self
        
        textView.registerMarkdownFormattingSymbol("**", withTitle: "Bold")
        textView.registerMarkdownFormattingSymbol("*", withTitle: "Italics")
        textView.registerMarkdownFormattingSymbol("~~", withTitle: "Strike")
        
        textView.placeholder = L10n.writeAMessage
        textInputbar.maxCharCount = UInt(configRepository.integer(variable: .maxChatLength))
        textInputbar.charCountLabel.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        textInputbar.textView.isDynamicTypeEnabled = true
        textInputbar.textView.placeholderFont = CustomFontMetrics.scaledSystemFont(ofSize: 13)
        textInputbar.textView.font = CustomFontMetrics.scaledSystemFont(ofSize: 13)
        
        hrpgTopHeaderNavigationController()?.shouldHideTopHeader = true
        hrpgTopHeaderNavigationController()?.hideNavbar = false
                
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView?.refreshControl = refreshControl
        
        ThemeService.shared.addThemeable(themable: self)
        
        refresh()
    }
    
    func applyTheme(theme: Theme) {
        tableView?.backgroundColor = theme.windowBackgroundColor
        textInputbar.charCountLabelNormalColor = theme.dimmedTextColor
        textInputbar.textView.backgroundColor = theme.contentBackgroundColor
        textInputbar.textView.textColor = theme.primaryTextColor
        view.backgroundColor = theme.contentBackgroundColor
        tableView?.reloadData()
    }
    
    @objc
    private func refresh() {
        dataSource.retrieveData(forced: true) {[weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if hrpgTopHeaderNavigationController() != nil {
            hrpgTopHeaderNavigationController()?.scrollView(scrollView, scrolledToPosition: 0)
        }
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        let text = textView.text
        if Double(text?.count ?? 0) > (Double(textInputbar.maxCharCount) * 0.95) {
            textInputbar.charCountLabelWarningColor = ThemeService.shared.theme.warningColor
        } else {
            textInputbar.charCountLabelWarningColor = ThemeService.shared.theme.errorColor
        }
    }
    
    func setTitleWith(username: String?) {
        if let username = username {
            navigationItem.title = L10n.writeTo(username)
        } else {
            navigationItem.title = L10n.writeMessage
        }
    }
    
    override func didPressRightButton(_ sender: Any?) {
        textView.refreshFirstResponder()
        dataSource.sendMessage(messageText: textView.text)
        super.didPressRightButton(sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Social.userProfileSegue.rawValue {
            let profileViewController = segue.destination as? UserProfileViewController
            profileViewController?.userID = userID
            profileViewController?.username = username
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.item == dataSource.tableView(tableView, numberOfRowsInSection: indexPath.section)-1 {
            dataSource.retrieveData(forced: false) {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: UIView) {
        dismiss(animated: true, completion: nil)
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false
        super.scrollViewDidEndDecelerating(scrollView)
    }
    
}
