//
//  GroupTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift
import Down

class GroupDetailViewController: BaseUIViewController {
    var groupID: String?

    var groupProperty = MutableProperty<GroupProtocol?>(nil)
    
    let socialRepository = SocialRepository()
    let userRepository = UserRepository()
    let disposable = ScopedDisposable(CompositeDisposable())
    
    @IBOutlet weak var scrollView: UIScrollView?
    @IBOutlet weak var groupNameLabel: UILabel?
    @IBOutlet weak var groupDescriptionStackView: CollapsibleStackView?
    @IBOutlet weak var groupDescriptionTextView: UITextView?
    @IBOutlet weak var leaveButton: UIButton?
    
    var leaveInteractor: LeaveGroupInteractor?
    private let (lifetime, token) = Lifetime.make()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let margins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        groupDescriptionStackView?.layoutMargins = margins
        groupDescriptionStackView?.isLayoutMarginsRelativeArrangement = true
        
        disposable.inner.add(groupProperty.signal.skipNil()
            .observeValues({[weak self] group in
                self?.updateData(group: group)
        }))
        
        leaveInteractor = LeaveGroupInteractor(presentingViewController: self)
        
        ThemeService.shared.addThemeable(themable: self)
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        groupNameLabel?.textColor = theme.primaryTextColor
        scrollView?.backgroundColor = theme.contentBackgroundColor
        leaveButton?.backgroundColor = theme.errorColor
        groupDescriptionStackView?.applyTheme(theme: theme)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disposable.inner.add(leaveInteractor?.reactive.take(during: lifetime)
            .flatMap(.latest, {[weak self] _ in
                return self?.userRepository.retrieveUser() ?? Signal.empty
            })
            .observeCompleted {})
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        groupDescriptionTextView?.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        groupDescriptionTextView?.textContainer.lineFragmentPadding = 0
    }
    
    func updateData(group: GroupProtocol) {
        groupNameLabel?.text = group.name
        groupDescriptionTextView?.text = group.groupDescription
        Down(markdownString: group.groupDescription?.unicodeEmoji ?? "").toHabiticaAttributedStringAsync {[weak self] markDownString in
            self?.groupDescriptionTextView?.attributedText = markDownString
        }
    }
    
    @IBAction func leaveButtonTapped(_ sender: Any) {
        if let group = self.groupProperty.value {
            leaveInteractor?.run(with: group)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Social.challengesSegue.rawValue {
            let destination = segue.destination as? ChallengeTableViewController
            if let groupID = groupProperty.value?.id {
                destination?.dataSource.shownGuilds = [groupID]
                destination?.dataSource.isShowingJoinedChallenges = false
                destination?.segmentedFilterControl.selectedSegmentIndex = 1
            }
        }
    }
}
