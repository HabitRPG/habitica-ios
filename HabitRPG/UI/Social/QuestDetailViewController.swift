//
//  QuestDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 08.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift
import Down

class QuestDetailViewController: BaseUIViewController {
    
    private let socialRepository = SocialRepository()
    private let inventoryRepository = InventoryRepository()
    private let userRepository = UserRepository()

    private let disposable = ScopedDisposable(CompositeDisposable())
    
    var questKey: String?
    var groupID: String?
    var participants = [QuestParticipantProtocol]()
    var isQuestActive = false
    
    private let headerView: QuestTitleView = {
        let view = QuestTitleView()
        view.insets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return view
    }()
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var questTypeHeader: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var invitationsHeader: UILabel!
    @IBOutlet weak var invitationsStackView: UIStackView!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var abortButton: UIButton!
    @IBOutlet weak var forceStartButton: UIButton!
    @IBOutlet weak var questBossView: UIStackView!
    @IBOutlet weak var bossImageView: UIImageView!
    @IBOutlet weak var bosNameLabel: UILabel!
    @IBOutlet weak var healthIconView: UIImageView!
    @IBOutlet weak var bossHealthlabel: UILabel!
    @IBOutlet weak var bossDifficultyImageView: UIImageView!
    @IBOutlet weak var bossDifficultyLabel: UILabel!
    @IBOutlet weak var descriptionHeaderView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderCoordinator = TopHeaderCoordinator(topHeaderNavigationController: hrpgTopHeaderNavigationController(), scrollView: scrollView)
        topHeaderCoordinator.followScrollView = false
        
        let borderView = UIView(frame: CGRect(x: 0, y: headerView.intrinsicContentSize.height, width: self.view.bounds.size.width, height: 1))
        borderView.backgroundColor = UIColor.gray500()
        headerView.addSubview(borderView)
        topHeaderCoordinator.alternativeHeader = headerView
        
        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            self?.set(user: user)
        }).start())
        if let questKey = questKey {
            disposable.inner.add(inventoryRepository.getQuest(key: questKey).skipNil().on(value: {[weak self]quest in
                self?.set(quest: quest)
            }).start())
        }
        if let groupID = groupID {
            disposable.inner.add(socialRepository.getGroup(groupID: groupID).skipNil()
                .on(value: {[weak self]group in
                self?.set(group: group)
            })
                .flatMap(.latest, {[weak self] (group) in
                    return self?.socialRepository.getMembers(userIDs: group.quest?.members.map({ user in
                        return user.userID ?? ""
                    }) ?? []) ?? SignalProducer.empty
                })
                .on(value: {[weak self](members, _) in
                    self?.set(members: members)
                })
                .start())
        }
        
        descriptionTextView.textContainerInset = UIEdgeInsets.zero
        descriptionTextView.textContainer.lineFragmentPadding = 0
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        scrollView.backgroundColor = theme.windowBackgroundColor
        backgroundView.backgroundColor = theme.contentBackgroundColor
        bossImageView.backgroundColor = theme.windowBackgroundColor
    }
    
    override func populateText() {
        rejectButton.setTitle(L10n.reject, for: .normal)
        acceptButton.setTitle(L10n.accept, for: .normal)
        cancelButton.setTitle(L10n.cancel, for: .normal)
        abortButton.setTitle(L10n.abort, for: .normal)
        forceStartButton.setTitle(L10n.forceStart, for: .normal)
        
        invitationsHeader.text = L10n.invitations
        descriptionHeaderView.text = L10n.description
    }
    
    private func set(user: UserProtocol) {
        let hideRSVPButtons = !(user.party?.quest?.rsvpNeeded ?? false)
        acceptButton.isHidden = hideRSVPButtons
        rejectButton.isHidden = hideRSVPButtons
    }
    
    private func set(quest: QuestProtocol) {
        descriptionTextView.attributedText = try? Down(markdownString: quest.notes ?? "").toHabiticaAttributedString()
        if quest.isBossQuest {
            questTypeHeader.text = L10n.Quests.bossBattle
            bossImageView.setImagewith(name: "quest_\(quest.key ?? "")")
            bosNameLabel.text = quest.boss?.name
            healthIconView.image = HabiticaIcons.imageOfHeartLightBg
            bossHealthlabel.text = "\(quest.boss?.health ?? 0) HP"
            bossDifficultyImageView.image = HabiticaIcons.imageOfDifficultyStars(difficulty: CGFloat(quest.boss?.strength ?? 0))
            
        } else {
            questTypeHeader.text = L10n.Quests.collectionQuest
            questBossView.isHidden = true
        }
        headerView.imageView.setImagewith(name: "inventory_quest_scroll_\(quest.key ?? "")")
        headerView.titleLabel.text = quest.text
    }
    
    private func set(group: GroupProtocol) {
        if let participants = group.quest?.members {
            self.participants = participants
        }
        isQuestActive = group.quest?.active ?? false
        if group.quest?.leaderID == userRepository.currentUserId {
            if isQuestActive {
                abortButton.isHidden = false
                cancelButton.isHidden = true
                forceStartButton.isHidden = true
            } else {
                abortButton.isHidden = true
                cancelButton.isHidden = false
                forceStartButton.isHidden = false
            }
        } else {
            abortButton.isHidden = true
            cancelButton.isHidden = true
            forceStartButton.isHidden = true
        }
        
        if let leaderID = group.quest?.leaderID {
            disposable.inner.add(socialRepository.getMember(userID: leaderID, retrieveIfNotFound: true).skipNil().take(first: 1) .on(value: {[weak self](questLeader) in
                self?.headerView.detailLabel.text = L10n.Quests.startedBy(questLeader.profile?.name ?? "")
                self?.headerView.setNeedsLayout()
            }).start())
        }
        
        let participantCount = group.quest?.members.count ?? 0
        if isQuestActive {
            let attributedText = NSMutableAttributedString(string: L10n.Quests.participantsHeader, attributes: [.foregroundColor: UIColor.gray200()])
            attributedText.append(NSAttributedString(string: " \(participantCount)", attributes: [.foregroundColor: UIColor.gray400()]))
            invitationsHeader.attributedText = attributedText
        } else {
            let respondedCount = group.quest?.members.filter({ (participant) -> Bool in
                return participant.responded
            }).count ?? 0
            let attributedText = NSMutableAttributedString(string: L10n.Quests.invitationsHeader, attributes: [.foregroundColor: UIColor.gray200()])
            attributedText.append(NSAttributedString(string: " \(respondedCount)/\(participantCount)", attributes: [.foregroundColor: UIColor.gray400()]))
            invitationsHeader.attributedText = attributedText
        }
    }
    
    private func set(members: [MemberProtocol]) {
        invitationsStackView.arrangedSubviews.filter { (view) -> Bool in
            return view as? QuestParticipantView != nil
            }.forEach { (view) in
                view.removeFromSuperview()
        }
        participants.forEach { (participant) in
            let view = QuestParticipantView()
            if let member = members.first(where: { (member) -> Bool in
                return member.id == participant.userID
            }) {
                view.configure(member: member)
            } else {
                view.usernameLabel.text = participant.userID
            }
            if !isQuestActive {
                view.configure(participant: participant)
            }
            invitationsStackView.addArrangedSubview(view)
        }
        invitationsStackView.setNeedsLayout()
    }
    
    @IBAction func rejectButtonTapped(_ sender: Any) {
        if let groupID = groupID {
            disposable.inner.add(socialRepository.rejectQuestInvitation(groupID: groupID).observeCompleted {})
        }
    }
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        if let groupID = groupID {
            disposable.inner.add(socialRepository.acceptQuestInvitation(groupID: groupID).observeCompleted {})
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        let alertController = HabiticaAlertController(title: nil, message: L10n.Quests.confirmCancelInvitation)
        alertController.addCancelAction()
        alertController.addAction(title: L10n.confirm, style: .destructive, isMainAction: true, handler: {[weak self] (_) in
            if let groupID = self?.groupID {
                self?.disposable.inner.add(self?.socialRepository.cancelQuestInvitation(groupID: groupID).observeCompleted {
                    self?.navigationController?.popViewController(animated: true)
                })
            }
        })
        alertController.show()
    }
    
    @IBAction func abortButtonTapped(_ sender: Any) {
        let alertController = HabiticaAlertController(title: nil, message: L10n.Quests.confirmAbort)
        alertController.addCancelAction()
        alertController.addAction(title: L10n.confirm, style: .destructive, isMainAction: true, handler: {[weak self] (_) in
            if let groupID = self?.groupID {
                self?.disposable.inner.add(self?.socialRepository.abortQuest(groupID: groupID).observeCompleted {
                    self?.navigationController?.popViewController(animated: true)
                })
            }
        })
        alertController.show()
    }
    
    @IBAction func forceStartButtonTapped(_ sender: Any) {
        let alertController = HabiticaAlertController(title: nil, message: L10n.Quests.confirmForceStart)
        alertController.addCancelAction()
        alertController.addAction(title: L10n.confirm, style: .default, isMainAction: true, handler: {[weak self] (_) in
            if let groupID = self?.groupID {
                self?.disposable.inner.add(self?.socialRepository.forceStartQuest(groupID: groupID).observeCompleted {})
            }
        })
        alertController.show()
    }
}
