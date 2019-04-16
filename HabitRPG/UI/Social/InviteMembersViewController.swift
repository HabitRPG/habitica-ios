//
//  InviteMembersViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 20.07.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Eureka

struct InviteMembersFormTags {
    static let invitationType = "TypeRow"
    static let userIDSection = "userIDSection"
    static let usernameSection = "usernameSection"
    static let emailsSection = "emailsSection"
    static let qrCodeButton = "qrCodeButton"
}

class InviteMembersViewController: FormViewController {
    
    var groupID: String?
    
    private let configRepository = ConfigRepository()
    private let socialRepository = SocialRepository()
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var invitationType: String {
        if let formValue = form.values()[InviteMembersFormTags.invitationType] {
            if let labeledValue = formValue as? LabeledFormValue<String> {
                return labeledValue.value
            }
        }
        return ""
    }
    
    var members: [String: Any] {
        var members: [String: Any] = [:]

        if let section = form.sectionBy(tag: InviteMembersFormTags.userIDSection) {
            var sectionMembers = [String]()
            for row in section {
                if let textRow = row as? TextRow, let value = textRow.value {
                    sectionMembers.append(value)
                }
            }
            members["uuids"] = sectionMembers
        }
        if let section = form.sectionBy(tag: InviteMembersFormTags.usernameSection) {
            var sectionMembers = [String]()
            for row in section {
                if let textRow = row as? TextRow, let value = textRow.value {
                    sectionMembers.append(value)
                }
            }
            members["usernames"] = sectionMembers
        }
        if let section = form.sectionBy(tag: InviteMembersFormTags.emailsSection) {
            var sectionMembers = [[String: String]]()
            for row in section {
                if let textRow = row as? TextRow, let value = textRow.value {
                    sectionMembers.append([
                        "email": value,
                        "name": value
                        ])
                }
            }
            members["emails"] = sectionMembers
        }
        return members
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = L10n.Titles.inviteMembers
        form +++ MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete],
                                    header: L10n.username) { section in
                                        section.tag = InviteMembersFormTags.usernameSection

                                        section.addButtonProvider = { section in
                                            return ButtonRow { row in
                                                row.title = L10n.Groups.Invite.addUsername
                                                row.cellSetup({ (cell, _) in
                                                    cell.tintColor = ThemeService.shared.theme.tintColor
                                                })
                                            }
                                        }
                                        section.multivaluedRowToInsertAt = { index in
                                            return TextRow { row in
                                                row.cellSetup({ (cell, _) in
                                                    cell.tintColor = ThemeService.shared.theme.tintColor
                                                    cell.textField.autocapitalizationType = .none
                                                })
                                            }
                                        }
        }
        form +++ MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete],
                                    header: L10n.email) { section in
                                        section.tag = InviteMembersFormTags.emailsSection
                                        
                                        section.addButtonProvider = { section in
                                            return ButtonRow { row in
                                                row.title = L10n.Groups.Invite.addEmail
                                                row.cellSetup({ (cell, _) in
                                                    cell.tintColor = ThemeService.shared.theme.tintColor
                                                })
                                            }
                                        }
                                        section.multivaluedRowToInsertAt = { index in
                                            return TextRow { row in
                                                row.cellSetup({ (cell, _) in
                                                    cell.tintColor = ThemeService.shared.theme.tintColor
                                                    cell.textField.keyboardType = .emailAddress
                                                    cell.textField.autocapitalizationType = .none
                                                })
                                            }
                                        }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isEditing = true
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        doneButton.isEnabled = false
        if let groupID = groupID {
            socialRepository.invite(toGroup: groupID, members: members)
                .on(event: { _ in
                    self.doneButton.isEnabled = true
                })
                .skipNil()
                .observeValues { _ in
                    self.dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}
