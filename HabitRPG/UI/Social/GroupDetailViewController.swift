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
    
    var groupID: String?
    
    let socialRepository = SocialRepository()
    let disposable = ScopedDisposable(CompositeDisposable())
    
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupDescriptionStackView: CollapsibleStackView!
    @IBOutlet weak var groupDescriptionTextView: UITextView!
    @IBOutlet weak var groupInformationStackView: CollapsibleStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let margins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        groupDescriptionStackView.layoutMargins = margins
        groupDescriptionStackView.isLayoutMarginsRelativeArrangement = true
        groupInformationStackView.layoutMargins = margins
        groupInformationStackView.isLayoutMarginsRelativeArrangement = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let groupID = self.groupID {
            disposable.inner.add(socialRepository.getGroup(groupID: groupID).on(value: { group in
                self.updateData(group: group)
            }).start())
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        groupDescriptionTextView.textContainerInset = UIEdgeInsets.zero
        groupDescriptionTextView.textContainer.lineFragmentPadding = 0
    }
    
    func updateData(group: GroupProtocol) {
        groupNameLabel.text = group.name
        groupDescriptionTextView.attributedText = try? Down(markdownString: group.groupDescription ?? "").toHabiticaAttributedString()
    }
}
