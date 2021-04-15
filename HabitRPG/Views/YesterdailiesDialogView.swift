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

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var yesterdailiesHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var yesterdailiesTableView: UITableView!
    @IBOutlet weak var checkinCountView: UILabel!
    @IBOutlet weak var nextCheckinCountView: UILabel!
    @IBOutlet weak var headerWrapperView: UIView!
    
    @IBOutlet weak var tableViewWrapper: UIView!
    @IBOutlet weak var checkinYesterdaysDailiesLabel: UILabel!
    @IBOutlet weak var startDayButton: UIButton!
    
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

        updateTitleBanner()
        
        startDayButton.setTitle(L10n.startMyDay, for: .normal)
        
        ThemeService.shared.addThemeable(themable: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.cornerRadius = 16
        view.superview?.superview?.cornerRadius = 16
        
        startDayButton.layer.shadowRadius = 2
        startDayButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        startDayButton.layer.shadowOpacity = 0.5
        startDayButton.layer.masksToBounds = false
    }
    
    func applyTheme(theme: Theme) {
        view.backgroundColor = theme.contentBackgroundColor
        startDayButton.setTitleColor(.white, for: .normal)
        startDayButton.backgroundColor = theme.fixedTintColor
        tableViewWrapper.backgroundColor = theme.windowBackgroundColor
        checkinCountView.textColor = theme.primaryTextColor
        nextCheckinCountView.textColor = theme.secondaryTextColor
        startDayButton.layer.shadowColor = ThemeService.shared.theme.buttonShadowColor.cgColor
        yesterdailiesTableView.reloadData()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let window = view.window {
            heightConstraint.constant = window.frame.size.height - 300
        }
            yesterdailiesHeightConstraint.constant = yesterdailiesTableView.contentSize.height
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

    func updateTitleBanner() {
        checkinCountView.text = L10n.welcomeBack
        nextCheckinCountView.text = L10n.checkinYesterdaysDalies
    }

    @IBAction func allDoneTapped(_ sender: Any) {
        handleDismiss()
        dismiss(animated: true) {}
    }
    
    func handleDismiss() {
        UserManager.shared.yesterdailiesDialog = nil
        var completedTasks = [TaskProtocol]()
        if let tasks = tasks {
            for task in tasks where task.completed {
                completedTasks.append(task)
            }
        }
        userRepository.runCron(tasks: completedTasks)
    }
}
