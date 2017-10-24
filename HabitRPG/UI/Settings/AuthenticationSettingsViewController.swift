//
//  AuthenticationSettingsViewController.swift
//  Habitica
//
//  Created by Phillip on 20.10.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

class AuthenticationSettingsViewController: BaseSettingsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("Authentication", comment: "")
        } else {
            return NSLocalizedString("Danger Zone", comment: "")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.textColor = UIColor.black
            if indexPath.item == 0 {
                cell.textLabel?.text = NSLocalizedString("Login Name", comment: "")
                cell.detailTextLabel?.text = user?.loginname
            } else if indexPath.item == 1 {
                cell.textLabel?.text = NSLocalizedString("E-Mail", comment: "")
                cell.detailTextLabel?.text = user?.email
            } else if indexPath.item == 2 {
                cell.textLabel?.text = NSLocalizedString("Login Methods", comment: "")
                var loginMethods = [String]()
                if user?.email != nil {
                    loginMethods.append(NSLocalizedString("Local", comment: ""))
                }
                if user?.facebookID != nil {
                    loginMethods.append("Facebook")
                }
                if user?.googleID != nil {
                    loginMethods.append("Google")
                }
                cell.detailTextLabel?.text = loginMethods.joined(separator: ", ")
            }
        } else {
            cell.textLabel?.textColor = UIColor.red50()
            if indexPath.item == 0 {
                cell.textLabel?.text = NSLocalizedString("Reset Account", comment: "")
                cell.detailTextLabel?.text = nil
            } else {
                cell.textLabel?.text = NSLocalizedString("Delete Account", comment: "")
                cell.detailTextLabel?.text = nil
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            if indexPath.item == 0 {
                showResetAccountAlert()
            } else {
                showDeleteAccountAlert()
            }
        }
    }
    
    private func showDeleteAccountAlert() {
        let alertController = HabiticaAlertController(title: NSLocalizedString("Delete Account", comment: ""))
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        let textView = UITextView()
        textView.text = NSLocalizedString("Are you sure? This will delete your account forever, and it can never be restored! You will need to register a new account to use Habitica again. Banked or spent Gems will not be refunded. If you're absolutely certain, type your password into the text box below.", comment: "")
        textView.font = UIFont.preferredFont(forTextStyle: .subheadline)
        textView.textColor = UIColor.gray100()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = false
        stackView.addArrangedSubview(textView)
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("Password", comment: "")
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        stackView.addArrangedSubview(textField)
        alertController.contentView = stackView
        
        alertController.addCancelAction()
        alertController.addAction(title: NSLocalizedString("Delete Account", comment: ""), style: .destructive, isMainAction: true) {[weak self] _ in
            HRPGManager.shared().deleteAccount(textField.text ?? "", successBlock: {
                HRPGManager.shared().logoutUser({
                    let storyboard = UIStoryboard(name: "Intro", bundle: nil)
                    let navigationController = storyboard.instantiateViewController(withIdentifier: "LoginTableViewController")
                    self?.present(navigationController, animated: true, completion: nil)
                })
            }, onError: nil)
        }
        alertController.show()
    }
    
    private func showResetAccountAlert() {
        let alertController = HabiticaAlertController(title: NSLocalizedString("Reset Account", comment: ""))
        
        let textView = UITextView()
        textView.text = NSLocalizedString("WARNING! This resets many parts of your account. This is highly discouraged, but some people find it useful in the beginning after playing with the site for a short time.\n\nYou will lose all your levels, gold, and experience points. All your tasks (except those from challenges) will be deleted permanently and you will lose all of their historical data. You will lose all your equipment but you will be able to buy it all back, including all limited edition equipment or subscriber Mystery items that you already own (you will need to be in the correct class to re-buy class-specific gear). You will keep your current class and your pets and mounts. You might prefer to use an Orb of Rebirth instead, which is a much safer option and which will preserve your tasks and equipment.", comment: "")
        textView.font = UIFont.preferredFont(forTextStyle: .subheadline)
        textView.textColor = UIColor.gray100()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = false
        alertController.contentView = textView
        
        alertController.addCancelAction()
        alertController.addAction(title: NSLocalizedString("Reset Account", comment: ""), style: .destructive, isMainAction: true) { _ in
            HRPGManager.shared().resetAccount(nil, onError: nil)
        }
        alertController.show()
        
    }
}
