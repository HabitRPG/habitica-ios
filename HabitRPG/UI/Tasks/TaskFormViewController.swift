//
//  TaskFormViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 14.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class TaskFormViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var topSection: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextField!
    
    @IBOutlet weak var controlsTitle: UILabel!
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var difficultyTitle: UILabel!
    @IBOutlet weak var difficultyView: UIView!
    @IBOutlet weak var resetStreakTitle: UILabel!
    @IBOutlet weak var resetStreakView: UIView!
    
    @IBOutlet weak var resetStreakControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableViewHeightConstraint.constant = tableView.contentSize.height
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextInputCell", for: indexPath)
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.size.width)
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "test"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else {
            return "CONTROLS"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1
        } else {
            return 20
        }
    }
}
