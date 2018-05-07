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

    private let inventoryRepository = InventoryRepository()
    
    @IBOutlet weak var membersStackview: CollapsibleStackView!
    
    @IBOutlet weak var questStackView: CollapsibleStackView!
    @IBOutlet weak var startQuestButton: UIButton!
    @IBOutlet weak var questInvitationButtons: UIView!
    @IBOutlet weak var questInvitationRejectButton: UIButton!
    @IBOutlet weak var questInvitationAcceptButton: UIButton!
    @IBOutlet weak var questInvitationUserView: UIView!
    @IBOutlet weak var questInvitationUserAvatarView: AvatarView!
    @IBOutlet weak var questInvitationuserLabel: UILabel!
    @IBOutlet weak var questTitleView: UIView!
    @IBOutlet weak var questScrollView: UIImageView!
    @IBOutlet weak var questTitleTextView: UILabel!
    @IBOutlet weak var questTitleDetailView: UILabel!
    @IBOutlet weak var questTitleDisclosureView: UIImageView!
    @IBOutlet weak var partyQuestView: PartyQuestView!
    
    var fetchMembersDisposable: Disposable?
    var questStateDisposable: CompositeDisposable?
    
    override var group: GroupProtocol? {
        didSet {
            fetchMembers()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let margins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        membersStackview.layoutMargins = margins
        membersStackview.isLayoutMarginsRelativeArrangement = true
        questStackView.layoutMargins = margins
        questStackView.isLayoutMarginsRelativeArrangement = true
        
        questInvitationUserAvatarView.showPet = false
        questInvitationUserAvatarView.showMount = false
        questInvitationUserAvatarView.size = .compact
        
        questTitleDisclosureView.image = HabiticaIcons.imageOfDisclosureArrow
        questTitleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openQuestDetailView)))
        
        disposable.inner.add(userRepository.getUser().on(value: { user in
            self.update(user: user)
        }).start())
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
    
    override func updateData(group: GroupProtocol) {
        super.updateData(group: group)
        
        updateQuestStateInfo(questState: group.quest)
    }
    
    private func updateQuestStateInfo(questState: QuestStateProtocol?) {
        if let disposable = questStateDisposable {
            disposable.dispose()
        }
        
        if let questState = questState, let key = questState.key {
            questStateDisposable = CompositeDisposable()
            startQuestButton.isHidden = true
            questTitleView.isHidden = false
            questStateDisposable?.add(inventoryRepository.getQuest(key: key).on(value: { quest in
                self.questTitleTextView.text = quest?.text
                if let quest = quest, questState.active {
                    self.partyQuestView.configure(state: questState, quest: quest)
                    self.partyQuestView.isHidden = false
                }
            }).start())
            questScrollView.setImagewith(name: "inventory_quest_scroll_\(questState.key ?? "")")
            
            if questState.active {
                questInvitationUserView.isHidden = true
                questTitleDetailView.text = L10n.Party.questParticipantCount(questState.members.filter({ (participant) -> Bool in
                    return participant.accepted
                }).count)
            } else {
                let numberResponded = questState.members.filter { (participant) -> Bool in
                    return participant.responded
                }.count
                questTitleDetailView.text = L10n.Party.questNumberResponded(numberResponded, questState.members.count)
                
                if let leaderID = questState.leaderID, leaderID != (userRepository.currentUserId ?? "") {
                    questStateDisposable?.add(socialRepository.getMember(userID: leaderID, retrieveIfNotFound: true).skipNil().on(value: { (questLeader) in
                        self.questInvitationUserView.isHidden = false
                        self.questInvitationuserLabel.text = L10n.Party.invitedToQuest(questLeader.profile?.name ?? "")
                        self.questInvitationUserAvatarView.avatar = AvatarViewModel(avatar: questLeader)
                    }).start())
                } else {
                    questInvitationUserView.isHidden = true
                }
            }
        } else {
            startQuestButton.isHidden = false
            questTitleView.isHidden = true
            partyQuestView.isHidden = true
            questInvitationUserView.isHidden = true
        }
    }
    
    private func update(user: UserProtocol) {
        questInvitationButtons.isHidden = !(user.party?.quest?.rsvpNeeded ?? false)
        if let pendingDamage = user.party?.quest?.progress?.up, pendingDamage > 0 {
            partyQuestView.setPendingDamage(pendingDamage)
        }
        if questStateDisposable == nil {
            updateQuestStateInfo(questState: user.party?.quest)
        }
    }
    
    @IBAction func rejectQuestInvitation(_ sender: Any) {
        if let groupID = group?.id {
            disposable.inner.add(socialRepository.rejectQuestInvitation(groupID: groupID).observeCompleted {})
        }
    }
    
    @IBAction func acceptQuestInvitation(_ sender: Any) {
        if let groupID = group?.id {
            disposable.inner.add(socialRepository.acceptQuestInvitation(groupID: groupID).observeCompleted {})
        }
    }
    
    @objc
    private func openQuestDetailView() {
        self.perform(segue: StoryboardSegue.Social.questDetailSegue)
    }
}
