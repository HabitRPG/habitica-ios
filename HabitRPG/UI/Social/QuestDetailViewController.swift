//
//  QuestDetailViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 08.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
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
    @IBOutlet weak var contentWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var questTypeHeader: UILabel!
    @IBOutlet weak var descriptionTextView: MarkdownTextView!
    @IBOutlet weak var invitationsHeader: UILabel!
    @IBOutlet weak var invitationsStackView: UIStackView!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var abortButton: UIButton!
    @IBOutlet weak var forceStartButton: UIButton!
    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var questBossView: UIStackView!
    @IBOutlet weak var bossImageView: NetworkImageView!
    @IBOutlet weak var bosNameLabel: UILabel!
    @IBOutlet weak var healthIconView: UIImageView!
    @IBOutlet weak var bossHealthlabel: UILabel!
    @IBOutlet weak var bossDifficultyImageView: UIImageView!
    @IBOutlet weak var bossDifficultyLabel: UILabel!
    @IBOutlet weak var descriptionHeaderView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let topHeaderNavigationController = navigationController as? TopHeaderViewController {
            topHeaderCoordinator = TopHeaderCoordinator(topHeaderNavigationController: topHeaderNavigationController, scrollView: scrollView)
        }
        topHeaderCoordinator?.followScrollView = false
        topHeaderCoordinator?.hideHeader = true

        let borderView = UIView()
        borderView.backgroundColor = UIColor.gray500
        headerView.addSubview(borderView)

        scrollView.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        borderView.translatesAutoresizingMaskIntoConstraints = false
        let headerHeight: CGFloat = 87
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            headerView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: headerHeight),
            borderView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            borderView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 1)
        ])

        for constraint in scrollView.constraints {
            if let firstItem = constraint.firstItem as? UIStackView,
               constraint.firstAttribute == .top,
               constraint.secondItem === scrollView,
               constraint.constant == 16 {
                constraint.constant += headerHeight + 8
                break
            }
        }
        
        loadUser()
        if let questKey = questKey {
            loadQuest(questKey: questKey)
        }
        if let groupID = groupID {
            loadGroup(groupID: groupID)
        }
        
        descriptionTextView.textContainerInset = UIEdgeInsets.zero
        descriptionTextView.textContainer.lineFragmentPadding = 0
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.topHeaderCoordinator?.showHideHeader(show: false, animated: false)
        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let safeLeft = view.safeAreaInsets.left
        let safeRight = view.safeAreaInsets.right
        let totalPadding = max(15, safeLeft) + max(15, safeRight)
        contentWidthConstraint.constant = -totalPadding
        contentLeadingConstraint.constant = max(15, safeLeft)
        buttonLeadingConstraint.constant = max(0, safeLeft - 16)
        buttonTrailingConstraint.constant = max(0, safeRight - 16)

        let isLandscape = view.bounds.width > view.bounds.height
        headerView.backgroundColor = isLandscape ? ThemeService.shared.theme.contentBackgroundColor : .clear
        headerView.insets = UIEdgeInsets(top: 0, left: max(16, safeLeft), bottom: 0, right: max(16, safeRight))
    }

    private func loadUser() {
        disposable.inner.add(userRepository.getUser().on(value: {[weak self]user in
            self?.set(user: user)
            if self?.groupID == nil {
                if let groupID = user.party?.id {
                    self?.loadGroup(groupID: groupID)
                }
            }
        }).start())
    }
    
    private func loadGroup(groupID: String) {
        disposable.inner.add(socialRepository.getGroup(groupID: groupID).skipNil()
            .on(value: {[weak self]group in
            self?.set(group: group)
                if self?.questKey == nil {
                    if let questKey = group.quest?.key {
                        self?.loadQuest(questKey: questKey)
                    }
                }
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
    
    private func loadQuest(questKey: String) {
        disposable.inner.add(inventoryRepository.getQuest(key: questKey).skipNil().on(value: {[weak self]quest in
            self?.set(quest: quest)
        }).start())
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
        leaveButton.setTitle(L10n.leave, for: .normal)
        
        invitationsHeader.text = L10n.invitations
        descriptionHeaderView.text = L10n.description
    }
    
    private var hideRSVPButtons = false
    
    private func set(user: UserProtocol) {
        hideRSVPButtons = !(user.party?.quest?.rsvpNeeded ?? false)
        acceptButton.isHidden = hideRSVPButtons
        rejectButton.isHidden = hideRSVPButtons
    }
    
    private func set(quest: QuestProtocol) {
        descriptionTextView.setMarkdownString(quest.notes)
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
        headerView.imageView.setImagewith(name: quest.imageName)
        headerView.titleLabel.text = quest.text
    }
    
    private func set(group: GroupProtocol) {
        if let participants = group.quest?.members {
            self.participants = participants
        }
        isQuestActive = group.quest?.active ?? false
        if group.quest?.leaderID == userRepository.currentUserId || group.leaderID == userRepository.currentUserId {
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
        
        if group.quest?.leaderID != userRepository.currentUserId {
            leaveButton.isHidden = !(isQuestActive && participants.contains(where: { participant in
                return participant.userID == userRepository.currentUserId && participant.accepted
            }))
        } else {
            leaveButton.isHidden = true
        }
        
        if let leaderID = group.quest?.leaderID {
            disposable.inner.add(socialRepository.getMember(userID: leaderID, retrieveIfNotFound: true).skipNil().take(first: 1) .on(value: {[weak self](questLeader) in
                self?.headerView.detailLabel.text = L10n.Quests.startedBy(questLeader.profile?.name ?? "")
                self?.headerView.setNeedsLayout()
            }).start())
        }
        
        if isQuestActive {
            let participantCount = group.quest?.members.filter({ participant in
                return participant.accepted
            }).count ?? 0
            let attributedText = NSMutableAttributedString(string: L10n.Quests.participantsHeader, attributes: [.foregroundColor: UIColor.gray200])
            attributedText.append(NSAttributedString(string: " \(participantCount)", attributes: [.foregroundColor: UIColor.gray400]))
            print(attributedText)
            invitationsHeader.attributedText = attributedText
        } else {
            let participantCount = group.quest?.members.count ?? 0
            let respondedCount = group.quest?.members.filter({ (participant) -> Bool in
                return participant.responded
            }).count ?? 0
            let attributedText = NSMutableAttributedString(string: L10n.Quests.invitationsHeader, attributes: [.foregroundColor: UIColor.gray200])
            attributedText.append(NSAttributedString(string: " \(respondedCount)/\(participantCount)", attributes: [.foregroundColor: UIColor.gray400]))
            invitationsHeader.attributedText = attributedText
        }
    }
    
    private func set(members: [MemberProtocol]) {
        invitationsStackView.arrangedSubviews.filter { (view) -> Bool in
            return view is QuestParticipantView
            }.forEach { (view) in
                view.removeFromSuperview()
        }
        participants.forEach { (participant) in
            if isQuestActive && participant.accepted != true {
                return
            }
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
            view.addHeightConstraint(height: 56)
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
        alertController.addAction(title: L10n.confirm, style: .destructive, isMainAction: true, handler: {[weak self] (_) in
            if let groupID = self?.groupID {
                self?.disposable.inner.add(self?.socialRepository.cancelQuestInvitation(groupID: groupID).observeCompleted {
                    self?.navigationController?.popViewController(animated: true)
                })
            }
        })
        alertController.addCancelAction()
        alertController.show()
    }
    
    @IBAction func abortButtonTapped(_ sender: Any) {
        let alertController = HabiticaAlertController(title: nil, message: L10n.Quests.confirmAbort)
        alertController.addAction(title: L10n.confirm, style: .destructive, isMainAction: true, handler: {[weak self] (_) in
            if let groupID = self?.groupID {
                self?.disposable.inner.add(self?.socialRepository.abortQuest(groupID: groupID).observeCompleted {
                    self?.navigationController?.popViewController(animated: true)
                })
            }
        })
        alertController.addCancelAction()
        alertController.show()
    }
    
    @IBAction func forceStartButtonTapped(_ sender: Any) {
        let alertController = HabiticaAlertController(title: nil, message: L10n.Quests.confirmForceStart)
        alertController.addAction(title: L10n.confirm, style: .default, isMainAction: true, handler: {[weak self] (_) in
            if let groupID = self?.groupID {
                self?.disposable.inner.add(self?.socialRepository.forceStartQuest(groupID: groupID).observeCompleted {})
            }
        })
        alertController.addCancelAction()
        alertController.show()
    }
    
    @IBAction func leaveButtonTapped(_ sender: Any) {
        let alertController = HabiticaAlertController(title: nil, message: isQuestActive ? L10n.Quests.confirmLeave : L10n.Quests.confirmLeaveNostart)
        alertController.addAction(title: L10n.confirm, style: .default, isMainAction: true, handler: {[weak self] (_) in
            if let groupID = self?.groupID {
                self?.disposable.inner.add(self?.socialRepository.leaveQuest(groupID: groupID).observeCompleted {
                    self?.navigationController?.popViewController(animated: true)
                })
            }
        })
        alertController.addCancelAction()
        alertController.show()
    }
}
