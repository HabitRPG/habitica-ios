//
//  ChallengeDetailTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 01/03/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit

class ChallengeDetailTableViewController: HRPGBaseViewController {

    var challengeId: String?
    var challenge: Challenge?
    var headerView: ChallengeDetailHeaderView = .fromNib()
    
    var dataSource: HRPGCoreDataDataSource?
    weak var navController: HRPGTopHeaderNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchChallenge()
        
        registerCell(fromNib: "HRPGHabitTableViewCell", withName: "habit")
        registerCell(fromNib: "HRPGDailyTableViewCell", withName: "daily")
        registerCell(fromNib: "HRPGToDoTableViewCell", withName: "todo")
        registerCell(fromNib: "HRPGRewardTableViewCell", withName: "reward")
        
        configureTableView()
    }
    
    private func registerCell(fromNib nibName: String, withName: String) {
        
        let optionNib = UINib.init(nibName: nibName, bundle: nil)
        self.tableView.register(optionNib, forCellReuseIdentifier: withName)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navController = self.navigationController as? HRPGTopHeaderNavigationController
        guard let navController = self.navController else {
            return
        }
        navController.setAlternativeHeaderView(self.headerView)
        self.tableView.contentInset = UIEdgeInsets(top: navController.getContentInset(), left: 0 as CGFloat, bottom: 0 as CGFloat, right: 0 as CGFloat)
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: navController.getContentInset(), left: 0 as CGFloat, bottom: 0 as CGFloat, right: 0 as CGFloat)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let navController = self.navController {
            navController.removeAlternativeHeaderView()
        }
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Table view data source

    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        let configureCell = {(c, object, indexPath) in
            guard let cell = c as! HRPGTaskTableViewCell? else {
                return;
            }
            guard let task = object as! Task? else {
                return;
            }
            cell.configure(for: task)
            } as TableViewCellConfigureBlock
        let configureFetchRequest = {[weak self] fetchRequest in
            fetchRequest?.sortDescriptors = [NSSortDescriptor(key: "type", ascending: false), NSSortDescriptor(key: "order", ascending: false)]
            guard let weakSelf = self else {
                return;
            }
            fetchRequest?.predicate = NSPredicate(format: "challengeID == %@", weakSelf.challengeId!)
            } as FetchRequestConfigureBlock
        self.dataSource = HRPGCoreDataDataSource(managedObjectContext: self.managedObjectContext, entityName: "Task", cellIdentifier: "Cell", configureCellBlock: configureCell, fetchRequest: configureFetchRequest, asDelegateFor: self.tableView)
        self.dataSource?.sectionNameKeyPath = "type"
        self.dataSource?.cellIdentifierBlock = {(item, indexPath) in
            guard let task = item as! Task? else {
                return "";
            }
            return task.type
        } as CellIdentifierBlock
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 58))
        view.backgroundColor = UIColor.gray500()
        let label = UILabel(frame: CGRect(x: 0, y: 25, width: self.view.frame.size.width, height: 21))
        label.textColor = UIColor.gray200()
        let sectionName = self.dataSource?.tableView(self.tableView, titleForHeaderInSection: section)
        if sectionName == "habit" {
            label.text = NSLocalizedString("Challenge Habits", comment: "").uppercased()
        } else  if sectionName == "daily" {
            label.text = NSLocalizedString("Challenge Dailies", comment: "").uppercased()
        } else if sectionName == "todo" {
            label.text = NSLocalizedString("Challenge To-Dos", comment: "").uppercased()
        } else  if sectionName == "reward" {
            label.text = NSLocalizedString("Challenge Rewards", comment: "").uppercased()
        }
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textAlignment = .center
        view.addSubview(label)
        return view
    }
    
    func fetchChallenge() {
        guard let challengeId = self.challengeId else {
            return;
        }
        let entity = NSEntityDescription.entity(forEntityName: "Challenge", in: self.managedObjectContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity;
        fetchRequest.predicate = NSPredicate(format: "id == %@", challengeId)
        do {
            let challenges = try self.managedObjectContext.fetch(fetchRequest) as! [Challenge]
            if challenges.count > 0 {
                let challenge = challenges[0]
                self.tableView.reloadData()
                self.headerView.set(challenge: challenge)
                self.challenge = challenge
            }
        } catch {
        }
    }
}
