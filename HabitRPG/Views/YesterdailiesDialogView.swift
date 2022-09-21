//
//  YesterdailiesDialogView.swift
//  Habitica
//
//  Created by Phillip on 08.06.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift

class YesterdailiesDialogView: UIViewController, UITableViewDelegate, UITableViewDataSource, Themeable {

    @IBOutlet weak var yesterdailiesHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var yesterdailiesTableView: UITableView!
    @IBOutlet weak var tableViewWrapper: UIView!
    
    let taskRepository = TaskRepository()
    private let userRepository = UserRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    var tasks: [TaskProtocol]?

    override func viewDidLoad() {
        super.viewDidLoad()

        yesterdailiesTableView.delegate = self
        yesterdailiesTableView.dataSource = self

        let nib = UINib.init(nibName: "YesterdailyTaskCell", bundle: Bundle.main)
        yesterdailiesTableView.register(nib, forCellReuseIdentifier: "Cell")
        yesterdailiesTableView.rowHeight = UITableView.automaticDimension
        yesterdailiesTableView.estimatedRowHeight = 60
                
        ThemeService.shared.addThemeable(themable: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.cornerRadius = 16
    }
    
    func applyTheme(theme: Theme) {
        view.backgroundColor = theme.contentBackgroundColor
        yesterdailiesTableView.backgroundColor = theme.windowBackgroundColor
        yesterdailiesTableView.reloadData()
        yesterdailiesTableView.superview?.backgroundColor = theme.windowBackgroundColor
    }

    override func viewWillLayoutSubviews() {
        view.frame = CGRect(x: 0, y: view.frame.origin.y, width: view.superview?.frame.width ?? 0, height: 480)
        super.viewWillLayoutSubviews()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? YesterdailyTaskCell
        if let tasks = tasks {
            cell?.configure(task: tasks[indexPath.item])
            cell?.checkbox.wasTouched = {[weak self] in
                self?.checkedCell(indexPath)
            }
            cell?.onChecklistItemChecked = {[weak self] item in
                self?.checkChecklistItem(indexPath, item: item)
            }
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkedCell(indexPath)
    }

    private func checkedCell(_ indexPath: IndexPath) {
        if let tasks = tasks {
            tasks[indexPath.item].completed = !tasks[indexPath.item].completed
            yesterdailiesTableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    private func checkChecklistItem(_ indexPath: IndexPath, item: ChecklistItemProtocol) {
        item.completed = !item.completed
        yesterdailiesTableView.reloadRows(at: [indexPath], with: .fade)
    }

    func runCron() {
        handleDismiss()
    }
    
    func handleDismiss() {
        UserManager.shared.yesterdailiesDialog = nil
        var completedTasks = [TaskProtocol]()
        var completedChecklistItems = [(TaskProtocol, ChecklistItemProtocol)]()
        if let tasks = tasks {
            for task in tasks {
                if task.completed {
                    completedTasks.append(task)
                }
                for item in task.checklist where item.completed {
                    completedChecklistItems.append((task, item))
                }
            }
        }
        userRepository.runCron(checklistItems: completedChecklistItems, tasks: completedTasks)
    }
}
