//
//  PartyDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 01.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import ReactiveSwift
import SwiftUI
import Habitica_Database

class PartyDetailViewController: GroupDetailViewController {
    
    private let inventoryRepository = InventoryRepository()
    
    @IBOutlet weak var membersStackview: CollapsibleStackView!
    
    @IBOutlet weak var invitationsListView: GroupInvitationListView!
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
    @IBOutlet weak var mainStackviewOffset: NSLayoutConstraint!
    @IBOutlet weak var partyChallengesButton: UIButton!
    
    @IBOutlet weak var membersTitleView: CollapsibleTitle!
    @IBOutlet weak var descriptionTitleView: CollapsibleTitle!
    @IBOutlet weak var inviteMemberButton: UIButton!
    
    var fetchMembersDisposable: Disposable?
    var questStateDisposable: CompositeDisposable?
    
    private var members: [MemberProtocol] = []
    private var invitations: [MemberProtocol] = []
    private var finishedInitialLoad = false
    private var selectedMember: MemberProtocol?

    private var isLeader: Bool {
        return groupProperty.value?.leaderID == userRepository.currentUserId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let groupNameLabel = self.groupNameLabel {
            mainStackView.setCustomSpacing(16, after: groupNameLabel)
        }
        
        questContentStackView.separatorColor = .clear
        
        questInvitationUserAvatarView.showPet = false
        questInvitationUserAvatarView.showMount = false
        questInvitationUserAvatarView.size = .compact
        
        questTitleDisclosureView.image = HabiticaIcons.imageOfDisclosureArrow
        questTitleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openQuestDetailView)))
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self] user in
            self?.update(user: user)
        }).start())
        
        disposable.inner.add(groupProperty.producer.skipNil()
            .map({ (group) -> String? in
                return group.id
            })
            .skipNil()
            .skipRepeats()
            .observe(on: QueueScheduler.main)
            .flatMap(.latest, {[weak self] groupID in
                return self?.socialRepository.getGroupMembers(groupID: groupID).flatMapError({ (_) -> SignalProducer<ReactiveResults<[MemberProtocol]>, Never> in
                    return SignalProducer.empty
                }).combineLatest(with: self?.socialRepository.retrieveGroupInvites(groupID: groupID) ?? Signal.empty) ?? SignalProducer.empty
            }).on(value: {[weak self] (members, invites) in
                self?.members = members.value
                self?.invitations = invites ?? []
                self?.set(members: members.value, invites: invites)
                self?.finishedInitialLoad = true
        }).start())
        
        #if !targetEnvironment(macCatalyst)
        let refreshControl = HabiticaRefresControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        #endif
    }
    
    @objc
    private func refresh() {
        disposable.inner.add(socialRepository.retrieveGroup(groupID: groupID ?? "party")
            .flatMap(.latest, { _ in
                return self.socialRepository.retrieveGroupMembers(groupID: self.groupID ?? "party")
            })
            .observeCompleted {
                self.scrollView?.refreshControl?.endRefreshing()
            })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if finishedInitialLoad {
            socialRepository.retrieveGroupInvites(groupID: groupID ?? "").observeValues { invites in
                self.invitations = invites ?? []
                self.set(members: self.members, invites: invites)
            }
        }
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        
        partyChallengesButton.backgroundColor = theme.windowBackgroundColor
        partyChallengesButton.setTitleColor(theme.tintColor, for: .normal)
        questTitleContentView.backgroundColor = theme.windowBackgroundColor
        inviteMemberButton.backgroundColor = theme.windowBackgroundColor
        inviteMemberButton.setTitleColor(theme.tintColor, for: .normal)
        startQuestButton.backgroundColor = theme.windowBackgroundColor
        startQuestButton.setTitleColor(theme.tintColor, for: .normal)
        
        membersStackview.applyTheme(theme: theme)
        questContentStackView.applyTheme(theme: theme)
        questStackView.applyTheme(theme: theme)
        
        questStackView.backgroundColor = theme.contentBackgroundColor
        groupDescriptionStackView?.backgroundColor = theme.contentBackgroundColor
        membersStackview.backgroundColor = theme.contentBackgroundColor
    }
    
    override func populateText() {
        descriptionTitleView.text = L10n.Party.partyDescription
        membersTitleView.text = L10n.Groups.members
        partyChallengesButton.setTitle(L10n.Party.partyChallenges, for: .normal)
        inviteMemberButton.setTitle(L10n.Groups.findMembers, for: .normal)
        startQuestButton.setTitle(L10n.Party.startQuest, for: .normal)
        questInvitationAcceptButton.setTitle(L10n.accept, for: .normal)
        questInvitationRejectButton.setTitle(L10n.reject, for: .normal)
    }
    
    deinit {
        if let disposable = fetchMembersDisposable, !disposable.isDisposed {
            disposable.dispose()
        }
        if let disposable = questStateDisposable, !disposable.isDisposed {
            disposable.dispose()
        }
    }

    private func set(members: [MemberProtocol], invites: [MemberProtocol]?) {
        inviteMemberButton.isHidden = !isLeader
        for view in membersStackview.arrangedSubviews where view.tag == 1000 {
            view.removeFromSuperview()
        }
        let memberListView = MemberList(members: members, invites: invites, isLeader: isLeader, onTap: {[weak self] member in
            self?.selectedMember = member
            self?.perform(segue: StoryboardSegue.Social.userProfileSegue)
        }, onMoreTap: {[weak self] member in
            let sheet = HostingBottomSheetController(rootView: BottomSheetMenu(Text(member.profile?.name ?? ""), menuItems: {
                BottomSheetMenuitem(title: L10n.writeMessage) {
                    let viewController = StoryboardScene.Social.inboxChatNavigationController.instantiate()
                    (viewController.topViewController as? InboxChatViewController)?.userID = member.id
                    (viewController.topViewController as? InboxChatViewController)?.username = member.username
                    self?.present(viewController, animated: true, completion: nil)
                }
                if self?.isLeader == true && self?.groupProperty.value?.leaderID != member.id {
                    BottomSheetMenuitem(title: L10n.transferOwnership) {
                        self?.showTransferOwnershipDialog(memberID: member.id ?? "", displayName: member.profile?.name ?? "")

                    }
                    BottomSheetMenuitem(title: L10n.Party.removeFromParty) {
                        self?.showRemoveMemberDialog(memberID: member.id ?? "", displayName: member.profile?.name ?? "")

                    }
                }
            }))
            self?.present(sheet, animated: true)
        })
        let controller = UIHostingController(rootView: memberListView)
        controller.view.backgroundColor = .clear
        addChild(controller)
        controller.view.tag = 1000
        membersStackview.addArrangedSubview(controller.view)
        controller.didMove(toParent: self)
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
            
            partyQuestView.alpha = 1.0
            if questState.active {
                questInvitationUserView.isHidden = true
                if questState.members.contains(where: { participant -> Bool in
                    return participant.userID == inventoryRepository.currentUserId
                }) {
                questTitleContentView.detailLabel.text = L10n.Party.questParticipantCount(questState.members.filter({ (participant) -> Bool in
                    return participant.accepted
                }).count)
                } else {
                    questTitleContentView.detailLabel.text = L10n.Party.questNotParticipating
                    partyQuestView.alpha = 0.5
                }
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
            questTitleContentView.setNeedsLayout()
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
        if let collectedItems = user.party?.quest?.progress?.collectedItems, collectedItems > 0 {
            partyQuestView.setCollectedItems(collectedItems)
        }
        if questStateDisposable == nil {
            updateQuestStateInfo(questState: user.party?.quest)
        }
        
        let partyInvitations = user.invitations.filter { (invitation) -> Bool in
            return invitation.isPartyInvitation
        }
        if partyInvitations.isEmpty {
            invitationsListView.isHidden = true
            mainStackviewOffset.constant = 16
        } else {
            invitationsListView.isHidden = false
            mainStackviewOffset.constant = 0
        }
        invitationsListView.set(invitations: partyInvitations)
    }
    
    @IBAction func rejectQuestInvitation(_ sender: Any) {
        if let groupID = groupProperty.value?.id {
            disposable.inner.add(socialRepository.rejectQuestInvitation(groupID: groupID).observeCompleted {})
        }
    }
    
    @IBAction func acceptQuestInvitation(_ sender: Any) {
        if let groupID = groupProperty.value?.id {
            disposable.inner.add(socialRepository.acceptQuestInvitation(groupID: groupID).observeCompleted {})
        }
    }
    
    @objc
    private func openQuestDetailView() {
        perform(segue: StoryboardSegue.Social.questDetailSegue)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Social.questDetailSegue.rawValue {
            if let destination = segue.destination as? QuestDetailViewController {
                destination.groupID = groupProperty.value?.id
                destination.questKey = groupProperty.value?.quest?.key
            }
        } else if segue.identifier == StoryboardSegue.Social.userProfileSegue.rawValue {
            if let destination = segue.destination as? UserProfileViewController {
                destination.userID = selectedMember?.id
                destination.username = selectedMember?.username
            }
        }
        super.prepare(for: segue, sender: sender)
    }
    
    @IBAction func startQuestButtonTapped(_ sender: Any) {
        let itemNavigationController = StoryboardScene.Main.itemNavigationController.instantiate()
        let itemViewController = itemNavigationController.topViewController as? ItemsViewController
        itemViewController?.itemType = "quests"
        present(itemNavigationController, animated: true, completion: nil)
    }
    
    private func showTransferOwnershipDialog(memberID: String, displayName: String) {
        let alert = HabiticaAlertController(title: L10n.Party.transferOwnershipTitle, message: L10n.Party.transferOwnershipDescription(displayName))
        alert.addAction(title: L10n.transfer, style: .default, isMainAction: true) {[weak self] _ in
            self?.socialRepository.transferOwnership(groupID: self?.groupID ?? "", userID: memberID)
                .on(completed: {
                    ToastManager.show(text: L10n.Groups.transferredTo(displayName), color: .green)
                })
                .start()
        }
        alert.addCancelAction()
        alert.show()
    }
    
    @IBAction func openInviteView(_ sender: Any) {
        parent?.perform(segue: StoryboardSegue.Social.findMembersSegue)
    }
    
    private func showRemoveMemberDialog(memberID: String, displayName: String) {
        let alert = HabiticaAlertController(title: L10n.Party.removeMemberTitle(displayName))
        alert.addAction(title: L10n.remove, style: .destructive, isMainAction: true) {[weak self] _ in
            self?.socialRepository.removeMember(groupID: self?.groupID ?? "", userID: memberID)
                .flatMap(.latest, { _ in
                    return self?.socialRepository.retrieveGroupMembers(groupID: self?.groupID ?? "") ?? Signal.empty
                })
                .observeCompleted {
                    ToastManager.show(text: L10n.Groups.removed(displayName), color: .red)
                }
        }
        alert.addCancelAction()
        alert.show()
    }
}
