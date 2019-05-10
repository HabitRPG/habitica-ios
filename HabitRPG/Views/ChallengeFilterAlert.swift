//
//  ChallengeFilterAlert.swift
//  Habitica
//
//  Created by Phillip Thelen on 15/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import PopupDialog
import Habitica_Models
import ReactiveSwift

protocol ChallengeFilterChangedDelegate: class {
    func challengeFilterChanged(showOwned: Bool, showNotOwned: Bool, shownGuilds: [String])
}

class ChallengeFilterAlert: UIViewController, Themeable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var middleSeparator: UIView!
    @IBOutlet weak var groupsTitleLabel: UILabel!
    @IBOutlet weak var ownershipTitleLabel: UILabel!
    
    @IBOutlet weak private var doneButton: UIButton!
    @IBOutlet weak private var allGroupsButton: UIButton!
    @IBOutlet weak private var noGroupsButton: UIButton!
    @IBOutlet weak private var groupListView: UIStackView!
    @IBOutlet weak private var ownedButton: LabeledCheckboxView!
    @IBOutlet weak private var notOwnedButton: LabeledCheckboxView!

    @IBOutlet weak private var heightConstraint: NSLayoutConstraint!

    weak var delegate: ChallengeFilterChangedDelegate?
    
    private let socialRepository = SocialRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    var showOwned = true
    var showNotOwned = true
    var shownGuilds = [String]()

    var initShownGuilds = false

    var groups = [GroupProtocol]()

    init() {
        super.init(nibName: "ChallengeFilterAlert", bundle: nil)
    }
    
    func applyTheme(theme: Theme) {
        view.backgroundColor = theme.contentBackgroundColor
        titleLabel.textColor = theme.primaryTextColor
        topSeparator.backgroundColor = theme.separatorColor
        middleSeparator.backgroundColor = theme.separatorColor
        groupsTitleLabel.textColor = theme.ternaryTextColor
        ownershipTitleLabel.textColor = theme.ternaryTextColor
        doneButton.setTitleColor(theme.tintColor, for: .normal)
        allGroupsButton.setTitleColor(theme.tintColor, for: .normal)
        noGroupsButton.setTitleColor(theme.tintColor, for: .normal)
        ownedButton.tintColor = theme.tintColor
        ownedButton.textColor = theme.primaryTextColor
        notOwnedButton.tintColor = theme.tintColor
        notOwnedButton.textColor = theme.primaryTextColor
        groupListView.arrangedSubviews.forEach { (view) in
            if let checkview = view as? LabeledCheckboxView {
                checkview.tintColor = theme.tintColor
            }
        }
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

        disposable.inner.add(socialRepository.getChallengesDistinctGroups().on(value: {[weak self]challenges in
            self?.set(challenges: challenges.value)
        }).start())
        
        ThemeService.shared.addThemeable(themable: self)
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
            shownGuilds.append(group.id ?? "")
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
    
    private func set(challenges: [ChallengeProtocol]) {
        for challenge in challenges {
            guard let groupID = challenge.groupID else {
                return
            }
            let groupView = LabeledCheckboxView(frame: CGRect.zero)
            groupView.text = challenge.groupName
            if initShownGuilds {
                shownGuilds.append(groupID)
            }
            groupView.isChecked = shownGuilds.contains(groupID)
            groupView.numberOfLines = 0
            groupView.textColor = ThemeService.shared.theme.secondaryTextColor
            groupView.tintColor = ThemeService.shared.theme.tintColor
            groupView.checkedAction = { [weak self] isChecked in
                if isChecked {
                    self?.shownGuilds.append(groupID)
                } else {
                    if let index = self?.shownGuilds.index(of: groupID) {
                        self?.shownGuilds.remove(at: index)
                    }
                }
                self?.updateDelegate()
            }
            groupListView.addArrangedSubview(groupView)
        }
    }
}
