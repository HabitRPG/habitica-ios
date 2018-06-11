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
    
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var questStackView: CollapsibleStackView!
    @IBOutlet weak var questStackViewTitle: CollapsibleTitle!
    @IBOutlet weak var questContentStackView: SeparatedStackView!
    @IBOutlet weak var startQuestButton: UIButton!
    @IBOutlet weak var questInvitationButtons: UIView!
    @IBOutlet weak var questInvitationRejectButton: UIButton!
    @IBOutlet weak var questInvitationAcceptButton: UIButton!
    @IBOutlet weak var questInvitationUserView: UIView!
    @IBOutlet weak var questInvitationUserAvatarView: AvatarView!
    @IBOutlet weak var questInvitationuserLabel: UILabel!
    @IBOutlet weak var questTitleView: UIView!
    @IBOutlet weak var questTitleContentView: QuestTitleView!
    @IBOutlet weak var questTitleDisclosureView: UIImageView!
    @IBOutlet weak var partyQuestView: PartyQuestView!
    
    var fetchMembersDisposable: Disposable?
    var questStateDisposable: CompositeDisposable?
    
    private var selectedMember: MemberProtocol?
    
    override var group: GroupProtocol? {
        didSet {
            fetchMembers()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *), let groupNameLabel = self.groupNameLabel {
            mainStackView.setCustomSpacing(16, after: groupNameLabel)
        }
        
        let margins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        membersStackview.layoutMargins = margins
        membersStackview.isLayoutMarginsRelativeArrangement = true
        membersStackview.separatorBetweenItems = true
        questContentStackView.layoutMargins = margins
        questContentStackView.isLayoutMarginsRelativeArrangement = true
        questContentStackView.separatorBetweenItems = true
        questContentStackView.separatorInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        questStackViewTitle.insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        questInvitationUserAvatarView.showPet = false
        questInvitationUserAvatarView.showMount = false
        questInvitationUserAvatarView.size = .compact
        
        questTitleDisclosureView.image = HabiticaIcons.imageOfDisclosureArrow
        questTitleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openQuestDetailView)))
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.update(user: user)
        }).start())
    }
    
    deinit {
        if let disposable = fetchMembersDisposable, !disposable.isDisposed {
            disposable.dispose()
        }
        if let disposable = questStateDisposable, !disposable.isDisposed {
            disposable.dispose()
        }
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
            view.viewTapped = {[weak self] in
                self?.selectedMember = member
                self?.perform(segue: StoryboardSegue.Social.userProfileSegue)
            }
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
            questStateDisposable?.add(inventoryRepository.getQuest(key: key).on(value: {[weak self] quest in
                self?.questTitleContentView.titleLabel.text = quest?.text
                self?.questTitleContentView.setNeedsLayout()
                if let quest = quest, questState.active {
                    self?.partyQuestView.configure(state: questState, quest: quest)
                    self?.partyQuestView.isHidden = false
                    self?.questContentStackView.setBorders()
                } else {
                    self?.partyQuestView.isHidden = true
                }
            }).start())
            questTitleContentView.imageView.setImagewith(name: "inventory_quest_scroll_\(questState.key ?? "")")
            
            if questState.active {
                questInvitationUserView.isHidden = true
                questTitleContentView.detailLabel.text = L10n.Party.questParticipantCount(questState.members.filter({ (participant) -> Bool in
                    return participant.accepted
                }).count)
            } else {
                let numberResponded = questState.members.filter { (participant) -> Bool in
                    return participant.responded
                }.count
                questTitleContentView.detailLabel.text = L10n.Party.questNumberResponded(numberResponded, questState.members.count)
                
                if let leaderID = questState.leaderID, leaderID != (userRepository.currentUserId ?? "") {
                    questStateDisposable?.add(socialRepository.getMember(userID: leaderID, retrieveIfNotFound: true).skipNil().on(value: {[weak self] (questLeader) in
                        self?.questInvitationUserView.isHidden = false
                        self?.questContentStackView.setBorders()
                        self?.questInvitationuserLabel.text = L10n.Party.invitedToQuest(questLeader.profile?.name ?? "")
                        self?.questInvitationUserAvatarView.avatar = AvatarViewModel(avatar: questLeader)
                    }).start())
                } else {
                    questInvitationUserView.isHidden = true
                }
            }
            self.questTitleContentView.setNeedsLayout()
        } else {
            startQuestButton.isHidden = false
            questTitleView.isHidden = true
            partyQuestView.isHidden = true
            questInvitationUserView.isHidden = true
        }
        questContentStackView.setBorders()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Social.questDetailSegue.rawValue {
            if let destination = segue.destination as? QuestDetailViewController {
                destination.groupID = group?.id
                destination.questKey = group?.quest?.key
            }
        } else if segue.identifier == StoryboardSegue.Social.userProfileSegue.rawValue {
            if let destination = segue.destination as? UserProfileViewController {
                destination.userID = selectedMember?.id
                destination.username = selectedMember?.profile?.name
            }
        }
        super.prepare(for: segue, sender: sender)
    }
    
    @IBAction func startQuestButtonTapped(_ sender: Any) {
        let itemNavigationController = StoryboardScene.Main.itemNavigationController.instantiate()
        let itemViewController = itemNavigationController.topViewController as? ItemsViewController
        itemViewController?.itemType = "quests"
        self.present(itemNavigationController, animated: true, completion: nil)
    }
}
