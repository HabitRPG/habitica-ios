//
//  YesterdailiesDialogView.swift
//  Habitica
//
//  Created by Phillip on 08.06.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import PopupDialog
import Habitica_Models
import ReactiveSwift
import Crashlytics

class YesterdailiesDialogView: UIViewController, UITableViewDelegate, UITableViewDataSource, Themeable {

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var yesterdailiesHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var yesterdailiesTableView: UITableView!
    @IBOutlet weak var checkinCountView: UILabel!
    @IBOutlet weak var nextCheckinCountView: UILabel!
    @IBOutlet weak var headerWrapperView: UIView!
    
    @IBOutlet weak var tableViewWrapper: UIView!
    @IBOutlet weak var checkinWrapper: UIView!
    @IBOutlet weak var checkinIcon: UIImageView!
    @IBOutlet weak var checkinIconHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkinTitle: UILabel!
    @IBOutlet weak var checkinDescription: UILabel!
    @IBOutlet weak var checkinYesterdaysDailiesLabel: UILabel!
    @IBOutlet weak var startDayButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    
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
        updateCheckinScreen()
        
        checkinYesterdaysDailiesLabel.text = L10n.checkinYesterdaysDalies
        startDayButton.setTitle(L10n.startMyDay, for: .normal)
        
        ThemeService.shared.addThemeable(themable: self)
    }
    
    func applyTheme(theme: Theme) {
        view.backgroundColor = theme.contentBackgroundColor
        startDayButton.tintColor = theme.tintColor
        startDayButton.backgroundColor = theme.offsetBackgroundColor
        headerWrapperView.backgroundColor = theme.offsetBackgroundColor
        tableViewWrapper.backgroundColor = theme.windowBackgroundColor
        checkinTitle.textColor = theme.primaryTextColor
        checkinDescription.textColor = theme.secondaryTextColor
        checkinCountView.textColor = theme.primaryTextColor
        separatorView.backgroundColor = theme.separatorColor
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let window = self.view.window {
            self.heightConstraint.constant = window.frame.size.height - 200
        }
        if #available(iOS 10.0, *) {
            yesterdailiesHeightConstraint.constant = yesterdailiesTableView.contentSize.height
        } else {
            yesterdailiesHeightConstraint.constant = yesterdailiesTableView.contentSize.height + 100
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? YesterdailyTaskCell
        if let tasks = self.tasks {
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
        if let tasks = self.tasks {
            tasks[indexPath.item].completed = !tasks[indexPath.item].completed
            self.yesterdailiesTableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    private func checkChecklistItem(_ indexPath: IndexPath, item: ChecklistItemProtocol) {
        item.completed = !item.completed
        self.yesterdailiesTableView.reloadRows(at: [indexPath], with: .fade)
    }

    func updateTitleBanner() {
        checkinCountView.text = L10n.welcomeBack
        nextCheckinCountView.text = nil
    }

    func updateCheckinScreen() {
        checkinIconHeightConstraint.constant = 0
        checkinTitle.text = nil
        checkinDescription.text = nil
    }

    @IBAction func allDoneTapped(_ sender: Any) {
        handleDismiss()
        self.dismiss(animated: true) {}
    }
    
    func handleDismiss() {
        UserManager.shared.yesterdailiesDialog = nil
        var completedTasks = [TaskProtocol]()
        if let tasks = self.tasks {
            for task in tasks where task.completed {
                completedTasks.append(task)
            }
        }
        userRepository.runCron(tasks: completedTasks)
            .on(failed: { error in
                Crashlytics.sharedInstance().recordError(error)
            })
            .observeCompleted {}
    }
}
