//
//  FAQTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class FAQTableViewController: HRPGBaseViewController {
    
    private let searchBar = UISearchBar()
    private let resetTutorialButton = UIButton()
    
    private let dataSource = FAQTableViewDataSource()
    private var selectedIndexPath: IndexPath?
    
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
        resetTutorialButton.setTitleColor(UIColor.purple400(), for: .normal)
        resetTutorialButton.addTarget(self, action: #selector(resetTutorials), for: .touchUpInside)
        resetTutorialButton.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: 70)
        tableView.tableFooterView = resetTutorialButton
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        perform(segue: StoryboardSegue.Main.faqDetailSegue)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Main.faqDetailSegue.rawValue, let indexPath = selectedIndexPath {
            if let detailViewController = segue.destination as? FAQDetailViewController {
                detailViewController.index = indexPath.item
            }
        }
    }
    
    @objc
    func resetTutorials() {
        
    }
}
