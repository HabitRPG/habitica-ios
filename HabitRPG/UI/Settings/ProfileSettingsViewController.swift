//
//  ProfileSettingsViewController.swift
//  Habitica
//
//  Created by Phillip on 20.10.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class ProfileSettingsViewController: BaseSettingsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = L10n.Titles.profile
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if indexPath.item == 0 {
            cell.textLabel?.text = L10n.displayName
            cell.detailTextLabel?.text = user?.profile?.name
        } else if indexPath.item == 1 {
            cell.textLabel?.text = L10n.photoUrl
            cell.detailTextLabel?.text = user?.profile?.photoUrl
        } else if indexPath.item == 2 {
            cell.textLabel?.text = L10n.aboutText
            cell.detailTextLabel?.text = user?.profile?.blurb
        }
        cell.detailTextLabel?.textColor = ThemeService.shared.theme.secondaryTextColor
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            showEditAlert(title: L10n.Settings.changeDisplayName, message: "", value: user?.profile?.name, action: {[weak self] (newValue) in
                self?.updateValue(path: "profile.name", newValue: newValue, indexPath: indexPath)
            })
        } else if indexPath.item == 1 {
            showEditAlert(title: L10n.Settings.changePhotoUrl, message: "", value: user?.profile?.photoUrl, action: {[weak self] (newValue) in
                self?.updateValue(path: "profile.url", newValue: newValue, indexPath: indexPath)
            })
        } else if indexPath.item == 2 {
            showEditAlert(title: L10n.Settings.changeAboutMessage, message: "", value: user?.profile?.blurb, action: {[weak self] (newValue) in
                self?.updateValue(path: "profile.blurb", newValue: newValue, indexPath: indexPath)
            })
        }
    }
    
    private func showEditAlert(title: String, message: String, value: String?, action: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.cancelAction())
        alertController.addAction(UIAlertAction(title: L10n.save, style: .default, handler: { (_) in
            if let textFields = alertController.textFields, !textFields.isEmpty {
                let textField = textFields[0]
                action(textField.text)
            }
        }))
        alertController.addTextField { (textField) in
            textField.text = value
        }
        alertController.setSourceInCenter(view)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func updateValue(path: String, newValue: String?, indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let value = newValue else {
            return
        }
        userRepository.updateUser(key: path, value: value).observeCompleted {}
    }
}
