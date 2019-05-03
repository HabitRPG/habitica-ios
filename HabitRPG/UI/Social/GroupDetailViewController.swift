//
//  GroupTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 10.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift
import Down
import Crashlytics

class GroupDetailViewController: HRPGUIViewController, UITextViewDelegate, Themeable {
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
    @IBOutlet weak var leaveButtonWrapper: UIView?
    
    var leaveInteractor: LeaveGroupInteractor?
    private let (lifetime, token) = Lifetime.make()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupDescriptionTextView?.delegate = self
        
        let margins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        groupDescriptionStackView?.layoutMargins = margins
        groupDescriptionStackView?.isLayoutMarginsRelativeArrangement = true
        
        disposable.inner.add(groupProperty.signal.skipNil()
            .on(failed: { error in
                Crashlytics.sharedInstance().recordError(error)
            })
            .observeValues({[weak self] group in
                self?.updateData(group: group)
        }))
        
        self.leaveInteractor = LeaveGroupInteractor(presentingViewController: self)
        
        ThemeService.shared.addThemeable(themable: self)
    }
    
    func applyTheme(theme: Theme) {
        groupNameLabel?.textColor = theme.primaryTextColor
        scrollView?.backgroundColor = theme.windowBackgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disposable.inner.add(self.leaveInteractor?.reactive.take(during: self.lifetime)
            .flatMap(.latest, { _ in
                return self.userRepository.retrieveUser()
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
        Down(markdownString: group.groupDescription ?? "").toHabiticaAttributedStringAsync {[weak self] markDownString in
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
        } else if segue.identifier == StoryboardSegue.Social.invitationSegue.rawValue {
            let destination = segue.destination as? UINavigationController
            if let invitationViewController = destination?.topViewController as? InviteMembersViewController {
                invitationViewController.groupID = groupID
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return !RouterHandler.shared.handle(url: URL)
    }
}
