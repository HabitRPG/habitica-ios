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

class GroupDetailViewController: HRPGUIViewController {
    
    var groupProperty = MutableProperty<GroupProtocol?>(nil)
    
    let socialRepository = SocialRepository()
    let userRepository = UserRepository()
    let disposable = ScopedDisposable(CompositeDisposable())
    
    @IBOutlet weak var groupNameLabel: UILabel?
    @IBOutlet weak var groupDescriptionStackView: CollapsibleStackView?
    @IBOutlet weak var groupDescriptionTextView: UITextView?
    @IBOutlet weak var leaveButton: UIButton?
    @IBOutlet weak var leaveButtonWrapper: UIView?
    
    var leaveInteractor: LeaveGroupInteractor?
    private let (lifetime, token) = Lifetime.make()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let margins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        groupDescriptionStackView?.layoutMargins = margins
        groupDescriptionStackView?.isLayoutMarginsRelativeArrangement = true
        
        disposable.inner.add(groupProperty.signal.skipNil().observeValues({[weak self] group in
                self?.updateData(group: group)
        }))
        
        self.leaveInteractor = LeaveGroupInteractor(presentingViewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disposable.inner.add(self.leaveInteractor?.reactive.take(during: self.lifetime).observeCompleted {})
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        groupDescriptionTextView?.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        groupDescriptionTextView?.textContainer.lineFragmentPadding = 0
    }
    
    func updateData(group: GroupProtocol) {
        groupNameLabel?.text = group.name
        groupDescriptionTextView?.attributedText = try? Down(markdownString: group.groupDescription ?? "").toHabiticaAttributedString()
    }
    
    @IBAction func leaveButtonTapped(_ sender: Any) {
        if let groupID = self.groupProperty.value?.id {
            leaveInteractor?.run(with: groupID)
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
