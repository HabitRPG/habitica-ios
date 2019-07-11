//
//  FAQTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift

class FAQTableViewController: BaseTableViewController {
    
    private let searchBar = UISearchBar()
    private let resetTutorialButton = UIButton()
    
    private let dataSource = FAQTableViewDataSource()
    private var selectedIndex: Int?
    
    private let userRepository = UserRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator.hideHeader = true
        topHeaderCoordinator.followScrollView = false
        
        dataSource.tableView = tableView
        
        searchBar.placeholder = L10n.search
        searchBar.delegate = dataSource
        searchBar.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: 44)
        tableView.tableHeaderView = searchBar
        
        resetTutorialButton.setTitle(L10n.resetTips, for: .normal)
        resetTutorialButton.addTarget(self, action: #selector(resetTutorials), for: .touchUpInside)
        resetTutorialButton.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: 70)
        tableView.tableFooterView = resetTutorialButton
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
    }
    
    override func populateText() {
        navigationItem.title = L10n.Titles.faq
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = dataSource.item(at: indexPath)?.index
        perform(segue: StoryboardSegue.Main.faqDetailSegue)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.faqDetailSegue.rawValue, let index = selectedIndex {
            if let detailViewController = segue.destination as? FAQDetailViewController {
                detailViewController.index = index
            }
        }
    }
    
    @objc
    func resetTutorials() {
        disposable.inner.add(userRepository.getUser().take(first: 1)
            .map({ (user) -> [TutorialStepProtocol]? in
                return user.flags?.tutorials
            })
            .skipNil()
            .map({ (steps) -> [String: Bool] in
                var stepDict = [String: Bool]()
                steps.forEach({ (step) in
                    stepDict["flags.tutorial.\(step.type ?? "").\(step.key ?? "")"] = false
                })
                return stepDict
            })
            .flatMap(.latest, {[weak self] (updateDict) in
                return self?.userRepository.updateUser(updateDict) ?? Signal.empty
            }).start())
    }
}
