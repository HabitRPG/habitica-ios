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
    
    var group: GroupProtocol? {
        didSet {
            if let group = self.group {
                updateData(group: group)
            }
        }
    }
    
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
        
        let margins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        groupDescriptionStackView?.layoutMargins = margins
        groupDescriptionStackView?.isLayoutMarginsRelativeArrangement = true
        
        self.leaveInteractor = LeaveGroupInteractor(presentingViewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disposable.inner.add(self.leaveInteractor?.reactive.take(during: self.lifetime).observeCompleted {})
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        groupDescriptionTextView?.textContainerInset = UIEdgeInsets.zero
        groupDescriptionTextView?.textContainer.lineFragmentPadding = 0
    }
    
    func updateData(group: GroupProtocol) {
        groupNameLabel?.text = group.name
        groupDescriptionTextView?.attributedText = try? Down(markdownString: group.groupDescription ?? "").toHabiticaAttributedString()
    }
    
    @IBAction func leaveButtonTapped(_ sender: Any) {
        if let groupID = self.group?.id {
            leaveInteractor?.run(with: groupID)
        }
    }
}
