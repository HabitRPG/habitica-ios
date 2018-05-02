//
//  PartyDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 01.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

class PartyDetailViewController: GroupDetailViewController {

    @IBOutlet weak var membersStackview: CollapsibleStackView!
    
    var fetchMembersDisposable: Disposable?
    override var group: GroupProtocol? {
        didSet {
            fetchMembers()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let margins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        membersStackview.arrangedSubviews[0].layoutMargins = margins
    }

    func fetchMembers() {
        guard let groupID = self.group?.id else {
            return
        }
        if let disposable = self.fetchMembersDisposable {
            disposable.dispose()
        }
        fetchMembersDisposable = socialRepository.getGroupMembers(groupID: groupID).on(value: {[weak self] (members, _) in
            self?.set(members: members)
        }).start()
    }

    private func set(members: [MemberProtocol]) {
        for view in membersStackview.arrangedSubviews {
            if let memberView = view as? MemberListView {
                memberView.removeFromSuperview()
            }
        }
        for member in members {
            let view = MemberListView()
            view.configure(member: member, isLeader: member.id == group?.leaderID)
            membersStackview.addArrangedSubview(view)
        }
    }
}
