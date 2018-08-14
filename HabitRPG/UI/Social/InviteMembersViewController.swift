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
    static let emailsSection = "emailsSection"
    static let qrCodeButton = "qrCodeButton"
}

class InviteMembersViewController: FormViewController {
        
    var invitationType: String {
        if let formValue = form.values()[InviteMembersFormTags.invitationType] {
            if let labeledValue = formValue as? LabeledFormValue<String> {
                return labeledValue.value
            }
        }
        return ""
    }
    
    var members: [String] {
        var section: Section?
        if invitationType == "uuids" {
            section = form.sectionBy(tag: InviteMembersFormTags.userIDSection)
        } else {
            section = form.sectionBy(tag: InviteMembersFormTags.emailsSection)
        }
        
        var members = [String]()
        if let section = section {
            for row in section {
                if let textRow = row as? TextRow, let value = textRow.value {
                    members.append(value)
                }
            }
        }
        return members
    }
    
    private static let invitationTypes = [
        LabeledFormValue<String>(value: "uuids", label: L10n.userID),
        LabeledFormValue<String>(value: "emails", label: L10n.email)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section()
            <<< SegmentedRow<LabeledFormValue<String>>(InviteMembersFormTags.invitationType) { row in
                row.title = L10n.Groups.Invite.invitationType
                row.options = InviteMembersViewController.invitationTypes
                row.value = InviteMembersViewController.invitationTypes[0]
                row.cellSetup({ (cell, _) in
                    cell.tintColor = ThemeService.shared.theme.tintColor
                })
        }
        
        form +++ MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete],
                                    header: L10n.userID) { section in
                                        section.tag = InviteMembersFormTags.userIDSection
                                        section.hidden = Condition.function([InviteMembersFormTags.invitationType], { (form) -> Bool in
                                            return (form.values()[InviteMembersFormTags.invitationType] as? LabeledFormValue<String> )?.value == "emails"
                                        })
                                        section.addButtonProvider = { section in
                                            return ButtonRow { row in
                                                row.title = L10n.Groups.Invite.addUserid
                                                row.cellSetup({ (cell, _) in
                                                    cell.tintColor = ThemeService.shared.theme.tintColor
                                                })
                                            }
                                        }
                                        section.multivaluedRowToInsertAt = { index in
                                            return TextRow { row in
                                                row.cellSetup({ (cell, _) in
                                                    cell.tintColor = ThemeService.shared.theme.tintColor
                                                })
                                            }
                                        }
        }
        
        form +++ MultivaluedSection(multivaluedOptions: [.Reorder, .Insert, .Delete],
                                    header: L10n.email) { section in
                                        section.tag = InviteMembersFormTags.emailsSection
                                        section.hidden = Condition.function([InviteMembersFormTags.invitationType], { (form) -> Bool in
                                            return (form.values()[InviteMembersFormTags.invitationType] as? LabeledFormValue<String> )?.value == "uuids"
                                        })
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
                                                })
                                            }
                                        }
        }
        form +++ Section() { section in
            section.hidden = Condition.function([InviteMembersFormTags.invitationType], { (form) -> Bool in
                return (form.values()[InviteMembersFormTags.invitationType] as? LabeledFormValue<String> )?.value == "emails"
            })
        }
            <<< ButtonRow(InviteMembersFormTags.qrCodeButton) { row in
                row.title = L10n.scanQRCode
                row.cellSetup({ (cell, _) in
                    cell.tintColor = ThemeService.shared.theme.tintColor
                })
                row.onCellSelection({[weak self] (_, _) in
                    let viewController = StoryboardScene.Main.scanQRCodeNavController.instantiate()
                    self?.present(viewController, animated: true, completion: nil)
                })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.isEditing = true
    }

    @IBAction func unwindToList(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func unwindToListSave(_ segue: UIStoryboardSegue) {
        if let scannerViewController = segue.source as? HRPGQRCodeScannerViewController, let code = scannerViewController.scannedCode {
            var userIDSection = self.form.sectionBy(tag: InviteMembersFormTags.userIDSection)
            let row = TextRow(code) { row in
                row.value = code
            }
            let lastIndex = (userIDSection?.count ?? 1) - 1
            userIDSection?.insert(row, at: lastIndex)
        }
    }
}
