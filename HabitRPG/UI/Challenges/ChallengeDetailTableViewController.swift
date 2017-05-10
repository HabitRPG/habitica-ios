//
//  ChallengeDetailTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 01/03/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit
import ReactiveSwift
import PopupDialog

class ChallengeDetailTableViewController: HRPGBaseViewController {

    var challengeId: String?
    var challenge: Challenge?
    var headerView: ChallengeDetailHeaderView? = .fromNib()

    var dataSource: HRPGCoreDataDataSource?
    weak var navController: HRPGTopHeaderNavigationController?

    var joinInteractor: JoinChallengeInteractor?
    var leaveInteractor: LeaveChallengeInteractor?
    private let (lifetime, token) = Lifetime.make()
    private var disposable: CompositeDisposable = CompositeDisposable()

    var displayedAlert: ChallengeDetailAlert?
    @IBOutlet weak private var joinLeaveButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.joinInteractor = JoinChallengeInteractor(self.sharedManager)
        self.leaveInteractor = LeaveChallengeInteractor(self.sharedManager, presentingViewController: self)

        fetchChallenge()

        registerCell(fromNib: "HabitTableViewCell", withName: "habit")
        registerCell(fromNib: "DailyTableViewCell", withName: "daily")
        registerCell(fromNib: "ToDoTableViewCell", withName: "todo")
        registerCell(fromNib: "RewardTableViewCell", withName: "reward")

        configureTableView()

        headerView?.showMoreAction = {
            let viewController = ChallengeDetailAlert(nibName: "ChallengeDetailAlert", bundle: Bundle.main)
            self.sharedManager.fetchChallengeTasks(self.challenge, onSuccess: {[weak self] () in
                viewController.challenge = self?.selectedChallenge
                }, onError: nil)
            viewController.challenge = self.challenge
            viewController.joinLeaveAction = {[weak self] isMember in
                guard let challenge = self?.challenge else {
                    return
                }
                if let weakSelf = self {
                    if isMember {
                        weakSelf.joinInteractor?.run(with: challenge)
                    } else {
                        weakSelf.leaveInteractor?.run(with: challenge)
                    }
                }
            }
            let popup = PopupDialog(viewController: viewController) {[weak self] in
                self?.displayedAlert = nil
            }
            self.displayedAlert = viewController
            self.present(popup, animated: true, completion: nil)
        }
    }

    private func registerCell(fromNib nibName: String, withName: String) {

        let optionNib = UINib.init(nibName: nibName, bundle: nil)
        self.tableView.register(optionNib, forCellReuseIdentifier: withName)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let subscriber = Observer<Bool, NSError>(value: {[weak self] in
            self?.handleJoinLeave(isMember: $0)
        })
        disposable = CompositeDisposable()
        disposable.add(self.joinInteractor?.reactive.observe(subscriber, during: self.lifetime))
        disposable.add(self.leaveInteractor?.reactive.observe(subscriber, during: self.lifetime))

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
        disposable.dispose()
        super.viewWillDisappear(animated)
    }

    // MARK: - Table view data source

    func configureTableView() {
        tableView.backgroundColor = UIColor.gray500()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        let configureCell = {(tableViewCell, object, indexPath) in
            guard let cell = tableViewCell as? TaskTableViewCell else {
                return
            }
            guard let task = object as? Task else {
                return
            }
            cell.configure(task: task)
            } as TableViewCellConfigureBlock
        let configureFetchRequest = {[weak self] fetchRequest in
            fetchRequest?.sortDescriptors = [NSSortDescriptor(key: "type", ascending: false), NSSortDescriptor(key: "order", ascending: false)]
            guard let weakSelf = self else {
                return
            }
            fetchRequest?.predicate = NSPredicate(format: "challengeID == %@", weakSelf.challengeId ?? "")
            } as FetchRequestConfigureBlock
        self.dataSource = HRPGCoreDataDataSource(managedObjectContext: self.managedObjectContext,
                                                 entityName: "Task",
                                                 cellIdentifier: "Cell",
                                                 configureCellBlock: configureCell,
                                                 fetchRequest: configureFetchRequest,
                                                 asDelegateFor: self.tableView)
        self.dataSource?.sectionNameKeyPath = "type"
        self.dataSource?.cellIdentifierBlock = {(item, indexPath) in
            guard let task = item as? Task else {
                return ""
            }
            return task.type
        } as CellIdentifierBlock
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 38))
        view.backgroundColor = UIColor.gray500()
        let label = UILabel(frame: CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: 21))
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

    @IBAction func joinLeaveTapped(_ sender: UIBarButtonItem) {
        if let challenge = self.challenge {
            if challenge.user?.id == sharedManager.user.id {
                self.leaveInteractor?.run(with: challenge)
            } else {
                self.joinInteractor?.run(with: challenge)
            }
        }
    }

    func handleJoinLeave(isMember: Bool) {
        if let alert = displayedAlert {
            alert.isMember = isMember
        }

        if isMember {
            joinLeaveButton.title = NSLocalizedString("Leave", comment: "")
            joinLeaveButton.tintColor = .red100()
        } else {
            joinLeaveButton.title = NSLocalizedString("Join", comment: "")
            joinLeaveButton.tintColor = .green100()
        }
    }

    func fetchChallenge() {
        guard let challengeId = self.challengeId else {
            return
        }
        let entity = NSEntityDescription.entity(forEntityName: "Challenge", in: self.managedObjectContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "id == %@", challengeId)
        do {
            guard let challenges = try self.managedObjectContext.fetch(fetchRequest) as? [Challenge] else {
                return
            }
            if challenges.count > 0 {
                let challenge = challenges[0]
                self.tableView.reloadData()
                self.headerView?.set(challenge: challenge)
                handleJoinLeave(isMember: ((challenge.user?.id) != nil))
                self.challenge = challenge
            }
        } catch {
        }
    }
}
