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

class YesterdailiesDialogView: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var yesterdailiesHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var yesterdailiesTableView: UITableView!
    @IBOutlet weak var checkinCountView: UILabel!
    @IBOutlet weak var nextCheckinCountView: UILabel!
    
    @IBOutlet weak var checkinWrapper: UIView!
    @IBOutlet weak var checkinIcon: UIImageView!
    @IBOutlet weak var checkinIconHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkinTitle: UILabel!
    @IBOutlet weak var checkinDescription: UILabel!

    private let taskRepository = TaskRepository()
    private let userRepository = UserRepository()
    var tasks: [TaskProtocol]?

    @objc
    static func showDialog() -> YesterdailiesDialogView {
        let viewController = YesterdailiesDialogView(nibName: "YesterdailiesDialogView", bundle: Bundle.main)

        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)
        viewController.userRepository.getUser().filter { (user) -> Bool in
            return user.needsCron
        }.withLatest(from: viewController.taskRepository.retrieveTasks(dueOnDay: yesterday).skipNil())
            .map({ (user, tasks) in
                return (user, tasks.filter({ task in
                    return task.isDue && !task.completed
                }))
            })
            .on(completed: {
                UserManager.shared.yesterdailiesDialog = nil
            }, value: { (user, tasks) in
                let userTasks = tasks ?? []
                var hasUncompletedDailies = false
                for task in userTasks {
                    if task.type == "daily" && !task.completed {
                        hasUncompletedDailies = true
                        break
                    }
                }
                
                if !user.needsCron {
                    return
                }
                if !hasUncompletedDailies {
                    viewController.userRepository.runCron(tasks: []).observeCompleted {}
                    return
                }
                viewController.tasks = tasks
                let popup = PopupDialog(viewController: viewController)
                if var topController = UIApplication.shared.keyWindow?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    if let controller = topController as? MainTabBarController {
                        controller.present(popup, animated: true) {
                        }
                    }
                }
            }).start()
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        yesterdailiesTableView.delegate = self
        yesterdailiesTableView.dataSource = self

        let nib = UINib.init(nibName: "YesterdailyTaskCell", bundle: Bundle.main)
        yesterdailiesTableView.register(nib, forCellReuseIdentifier: "Cell")
        yesterdailiesTableView.rowHeight = UITableViewAutomaticDimension
        yesterdailiesTableView.estimatedRowHeight = 60

        updateTitleBanner()
        updateCheckinScreen()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let window = self.view.window {
            self.heightConstraint.constant = window.frame.size.height - 200
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
        checkinCountView.text = NSLocalizedString("Welcome Back!", comment: "")
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
        var completedTasks = [TaskProtocol]()
        if let tasks = self.tasks {
            for task in tasks where task.completed {
                completedTasks.append(task)
            }
        }
        userRepository.runCron(tasks: completedTasks).observeCompleted {}
    }
}
