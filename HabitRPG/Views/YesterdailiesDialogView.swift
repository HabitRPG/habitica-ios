//
//  YesterdailiesDialogView.swift
//  Habitica
//
//  Created by Phillip on 08.06.17.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit
import PopupDialog

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

    var sharedManager: HRPGManager?
    var tasks: [Task]?
    var user: User?

    static func showDialog(presenter: UIViewController, sharedManager: HRPGManager) {
        let viewController = YesterdailiesDialogView(nibName: "YesterdailiesDialogView", bundle: Bundle.main)
        viewController.sharedManager = sharedManager
        viewController.user = sharedManager.getUser()
        let popup = PopupDialog(viewController: viewController)
        presenter.present(popup, animated: true) {
            viewController.handleDismiss()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        yesterdailiesTableView.delegate = self
        yesterdailiesTableView.dataSource = self

        let nib = UINib.init(nibName: "YesterdailyTaskCell", bundle: Bundle.main)
        yesterdailiesTableView.register(nib, forCellReuseIdentifier: "Cell")
        yesterdailiesTableView.rowHeight = UITableViewAutomaticDimension
        yesterdailiesTableView.estimatedRowHeight = 60

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "type == 'daily' && completed == false && isDue == true")
        do {
            tasks = try sharedManager?.getManagedObjectContext().fetch(fetchRequest) as? [Task]
        } catch {
            tasks = []
        }

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
        }
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        checkedCell(indexPath)
    }

    private func checkedCell(_ indexPath: IndexPath) {
        if let tasks = self.tasks {
            tasks[indexPath.item].completed = NSNumber(booleanLiteral: !(tasks[indexPath.item].completed?.boolValue ?? true))
            self.yesterdailiesTableView.reloadRows(at: [indexPath], with: .fade)
        }
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

    }
}
