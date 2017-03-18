//
//  ChallengeFilterAlert.swift
//  Habitica
//
//  Created by Phillip Thelen on 15/03/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import Foundation
import PopupDialog

protocol ChallengeFilterChangedDelegate: class {
    func challengeFilterChanged(showOwned: Bool, showNotOwned: Bool, shownGuilds: [String])
}

class ChallengeFilterAlert: UIViewController {

    @IBOutlet weak private var doneButton: UIButton!
    @IBOutlet weak private var allGroupsButton: UIButton!
    @IBOutlet weak private var noGroupsButton: UIButton!
    @IBOutlet weak private var groupListView: TZStackView!
    @IBOutlet weak private var ownedButton: LabeledCheckboxView!
    @IBOutlet weak private var notOwnedButton: LabeledCheckboxView!

    @IBOutlet weak private var heightConstraint: NSLayoutConstraint!

    weak var delegate: ChallengeFilterChangedDelegate?

    var managedObjectContext: NSManagedObjectContext?

    var showOwned = true
    var showNotOwned = true
    var shownGuilds = [String]()

    var initShownGuilds = false

    var groups = [Group]()

    init() {
        super.init(nibName: "ChallengeFilterAlert", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        groupListView.axis = .vertical
        groupListView.spacing = 12

        ownedButton.isChecked = showOwned
        notOwnedButton.isChecked = showNotOwned
        ownedButton.checkedAction = {[weak self] isChecked in
            self?.showOwned = isChecked
            self?.updateDelegate()
        }
        notOwnedButton.checkedAction = {[weak self] isChecked in
            self?.showNotOwned = isChecked
            self?.updateDelegate()
        }

        fetchGroups()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let window = self.view.window {
        self.heightConstraint.constant = window.frame.size.height - 200
        }
    }

    @IBAction func doneTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func allGroupsTapped(_ sender: Any) {
        shownGuilds.removeAll()
        for group in groups {
            shownGuilds.append(group.id)
        }
        if let subviews = groupListView.arrangedSubviews as? [LabeledCheckboxView] {
            for view in subviews {
                view.isChecked = true
            }
        }
        updateDelegate()
    }

    @IBAction func noGroupsTapped(_ sender: Any) {
        shownGuilds.removeAll()
        if let subviews = groupListView.arrangedSubviews as? [LabeledCheckboxView] {
            for view in subviews {
                view.isChecked = false
            }
        }
        updateDelegate()
    }

    private func updateDelegate() {
        delegate?.challengeFilterChanged(showOwned: self.ownedButton.isChecked, showNotOwned: self.notOwnedButton.isChecked, shownGuilds: shownGuilds)
    }

    func fetchGroups() {
        if let managedObjectContext = self.managedObjectContext {
            let entity = NSEntityDescription.entity(forEntityName: "Group", in: managedObjectContext)
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            fetchRequest.entity = entity
            fetchRequest.predicate = NSPredicate(format: "challenges.@count > 0")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            do {
                guard let groups = try managedObjectContext.fetch(fetchRequest) as? [Group] else {
                    return
                }
                self.groups = groups
                if groups.count > 0 {
                    for group in groups {
                        let groupView = LabeledCheckboxView(frame: CGRect.zero)
                        groupView.text = group.name
                        if initShownGuilds {
                            shownGuilds.append(group.id)
                        }
                        groupView.isChecked = shownGuilds.contains(group.id)
                        groupView.numberOfLines = 0
                        groupView.textColor = UIColor(white: 0, alpha: 0.5)
                        groupView.checkedAction = { [weak self] isChecked in
                            if isChecked {
                                self?.shownGuilds.append(group.id)
                            } else {
                                if let index = self?.shownGuilds.index(of: group.id) {
                                    self?.shownGuilds.remove(at: index)
                                }
                            }
                            self?.updateDelegate()
                        }
                        groupListView.addArrangedSubview(groupView)
                    }
                }
            } catch {
            }
        }
    }
}
