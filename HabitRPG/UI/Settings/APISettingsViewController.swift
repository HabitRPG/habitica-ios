//
//  APISettingsViewController.swift
//  Habitica
//
//  Created by Phillip on 20.10.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class APISettingsViewController: BaseSettingsViewController {
    
    var showAPIKey = false
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let authManager = AuthenticationManager.shared
        if indexPath.item == 0 {
            cell.textLabel?.text = NSLocalizedString("User ID", comment: "")
            cell.detailTextLabel?.text = authManager.currentUserId
        } else if indexPath.item == 1 {
            cell.textLabel?.text = NSLocalizedString("API Key", comment: "")
            if showAPIKey {
                cell.detailTextLabel?.text = authManager.currentUserKey
            } else {
                cell.detailTextLabel?.text = NSLocalizedString("Tap to show", comment: "")
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return "Copy these for use in third party applications. However, think of your API Token like a password, and do not share it publicly. You may occasionally be asked for your User ID, but never post your API Token where others can see it, including on Github."
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.item == 1 && !showAPIKey {
            showAPIKey = true
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? HRPGCopyTableViewCell {
            cell.selectedCell()
        }
    }
}
