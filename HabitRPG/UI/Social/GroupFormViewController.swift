//
//  GroupFormViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 09.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import Eureka
import ReactiveSwift

enum GroupFormTags {
    static let name = "name"
    static let summary = "summary"
    static let groupDescription = "description"
    static let leaderChallenges = "leaderChallenges"
    static let newLeader = "newLeader"
}

class GroupFormViewController: FormViewController {
    
    private var group = SocialRepository().getNewGroup()
    var groupID: String?
    var isParty = false
    var leaderID: String?
    private var isCreating: Bool {
        return groupID == nil
    }
    
    private let socialRepository = SocialRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form
            +++ Section { _ in
            }
            <<< TextRow(GroupFormTags.name) { row in
                row.title = L10n.name
                row.cell.tintColor = ThemeService.shared.theme.tintColor
                row.add(rule: RuleRequired(msg: L10n.Groups.errorNameRequired))
                row.validationOptions = .validatesOnChange
            }
            <<< TextAreaRow(GroupFormTags.summary) { row in
                row.placeholder = L10n.summary
                row.cell.tintColor = ThemeService.shared.theme.tintColor
                row.textAreaHeight = TextAreaHeight.fixed(cellHeight: 200)
                row.hidden = Condition.function([], { (_) -> Bool in
                    return self.isParty
                })
            }
            <<< TextAreaRow(GroupFormTags.groupDescription) { row in
                row.placeholder = L10n.description
                row.cell.tintColor = ThemeService.shared.theme.tintColor
                row.textAreaHeight = TextAreaHeight.fixed(cellHeight: 350)
            }
            <<< SwitchRow(GroupFormTags.leaderChallenges) { row in
                row.title = L10n.Groups.leaderChallenges
                row.cell.tintColor = ThemeService.shared.theme.tintColor
        }
            <<< PushRow<LabeledFormValue<String>>(GroupFormTags.newLeader) { row in
                row.title = L10n.Groups.assignNewLeader
                row.hidden = Condition.function([], { (_) -> Bool in
                    return self.isCreating || !self.isParty
                })
        }
        
        loadGroup()
    }
    
    private func loadGroup() {
        if let groupID = groupID {
            if let group = socialRepository.getEditableGroup(id: groupID) {
                self.group = group
                self.leaderID = group.leaderID
                self.isParty = group.type == "party"
                self.form.setValues([
                    GroupFormTags.name: group.name,
                    GroupFormTags.summary: group.summary,
                    GroupFormTags.groupDescription: group.groupDescription,
                    GroupFormTags.leaderChallenges: group.leaderOnlyChallenges
                    ])
                if let row = self.form.rowBy(tag: GroupFormTags.newLeader) as? PushRow<LabeledFormValue<String>> {
                    row.value = row.options?.first(where: { (formValue) -> Bool in
                        return formValue.value == self.leaderID
                    })
                }
                self.form.rows.forEach({ (row) in
                    row.reload()
                    row.evaluateHidden()
                })
            }
            disposable.inner.add(socialRepository.getGroupMembers(groupID: groupID)
                .map({ (members, _) -> [LabeledFormValue<String>] in
                    return members.map({ (member) in
                        return LabeledFormValue<String>(value: member.id ?? "", label: member.profile?.name ?? "")
                    })
                })
                .on(value: {[weak self]formValues in
                    if let row = self?.form.rowBy(tag: GroupFormTags.newLeader) as? PushRow<LabeledFormValue<String>> {
                        row.options = formValues
                        row.value = formValues.first(where: { (formValue) -> Bool in
                            return formValue.value == self?.leaderID
                        })
                        row.reload()
                    }
                }).start())
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if save() {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func save() -> Bool {
        let errors = form.validate()
        if errors.isEmpty == false {
            let alert = HabiticaAlertController(title: errors[0].msg)
            alert.addCloseAction()
            alert.show()
            return false
        }
        let values = form.values()
        group.name = values[GroupFormTags.name] as? String
        if values[GroupFormTags.summary] != nil {
            group.summary = values[GroupFormTags.summary] as? String
        }
        group.groupDescription = values[GroupFormTags.groupDescription] as? String
        group.leaderOnlyChallenges = (values[GroupFormTags.leaderChallenges] as? Bool) ?? false
        group.leaderID = (values[GroupFormTags.newLeader] as? LabeledFormValue<String>)?.value
        if isParty {
            group.type = "party"
            group.privacy = "private"
        }
        if isCreating {
            socialRepository.createGroup(group).observeCompleted {}
        } else {
            socialRepository.updateGroup(group).observeCompleted {}
        }
        return true
    }
}
