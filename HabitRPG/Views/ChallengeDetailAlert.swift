//
//  ChallengeDetailAlert.swift
//  Habitica
//
//  Created by Phillip Thelen on 04/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Down

class ChallengeDetailAlert: UIViewController {

    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var notesLabel: UITextView!
    @IBOutlet weak private var ownerLabel: UILabel!
    @IBOutlet weak private var gemLabel: UILabel!
    @IBOutlet weak private var memberCountLabel: UILabel!
    @IBOutlet weak private var joinLeaveButton: UIButton!
    @IBOutlet weak private var heightConstraint: NSLayoutConstraint!

    @IBOutlet weak private var habitsList: ChallengeTaskListView!
    @IBOutlet weak private var dailiesList: ChallengeTaskListView!
    @IBOutlet weak private var todosList: ChallengeTaskListView!
    @IBOutlet weak private var rewardsList: ChallengeTaskListView!

    var joinLeaveAction: ((Bool) -> Void)?

    var challenge: Challenge? {
        didSet {
            if let challenge = self.challenge {
                configure(challenge)
            }
        }
    }

    var isMember: Bool = false {
        didSet {
            if !viewIsLoaded {
                return
            }
            if isMember {
                joinLeaveButton.setTitle(NSLocalizedString("Leave", comment: ""), for: .normal)
                joinLeaveButton.setTitleColor(.red100(), for: .normal)
            } else {
                joinLeaveButton.setTitle(NSLocalizedString("Join", comment: ""), for: .normal)
                joinLeaveButton.setTitleColor(.green100(), for: .normal)
            }
        }
    }

    private var viewIsLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        viewIsLoaded = true
        if let challenge = self.challenge {
            configure(challenge)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let window = self.view.window {
            self.heightConstraint.constant = window.frame.size.height - 200
        }
    }

    private func configure(_ challenge: Challenge, showTasks: Bool = true) {
        if !viewIsLoaded {
            return
        }
        nameLabel.text = challenge.name?.unicodeEmoji
        if let notes = challenge.notes {
            let markdownString = try? Down(markdownString: notes.unicodeEmoji).toHabiticaAttributedString()
            notesLabel.attributedText = markdownString
        }
        ownerLabel.text = challenge.leaderName?.unicodeEmoji
        gemLabel.text = challenge.prize?.stringValue
        memberCountLabel.text = challenge.memberCount?.stringValue
        isMember = challenge.user != nil

        habitsList.configure(tasks: challenge.habits?.sorted(by: { (first, second) -> Bool in
            (first.order?.intValue ?? 0) < (second.order?.intValue ?? 0)
        }))
        dailiesList.configure(tasks: challenge.dailies?.sorted(by: { (first, second) -> Bool in
            (first.order?.intValue ?? 0) < (second.order?.intValue ?? 0)
        }))
        todosList.configure(tasks: challenge.todos?.sorted(by: { (first, second) -> Bool in
            (first.order?.intValue ?? 0) < (second.order?.intValue ?? 0)
        }))
        rewardsList.configure(tasks: challenge.rewards?.sorted(by: { (first, second) -> Bool in
            (first.order?.intValue ?? 0) < (second.order?.intValue ?? 0)
        }))
    }

    @IBAction func joinLeaveTapped(_ sender: Any) {
        if let action = joinLeaveAction {
            action(!isMember)
        }
    }
}
