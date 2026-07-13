//
//  ChallengeDetailViewModel.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/17/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import SwiftUI
import ReactiveSwift
import Habitica_Models

enum ChallengeButtonState {
    case uninitialized, join, leave, publishDisabled, publishEnabled, viewParticipants, endChallenge
}

protocol ChallengeDetailViewModelInputs {
    func viewDidLoad()
    func setChallenge(_ challenge: ChallengeProtocol)
}

protocol ChallengeDetailViewModelOutputs {
    var cellModelsSignal: Signal<[MultiModelDataSourceSection], Never> { get }
    var reloadTableSignal: Signal<Void, Never> { get }
    var animateUpdatesSignal: Signal<(), Never> { get }
    var nextViewControllerSignal: Signal<UIViewController, Never> { get }
}

protocol ChallengeDetailViewModelProtocol {
    var inputs: ChallengeDetailViewModelInputs { get }
    var outputs: ChallengeDetailViewModelOutputs { get }
}

class ChallengeDetailViewModel: ChallengeDetailViewModelProtocol, ChallengeDetailViewModelInputs, ChallengeDetailViewModelOutputs, ResizableTableViewCellDelegate, ChallengeCreatorCellDelegate {
    var inputs: ChallengeDetailViewModelInputs { return self }
    var outputs: ChallengeDetailViewModelOutputs { return self }
    
    let cellModelsSignal: Signal<[MultiModelDataSourceSection], Never>
    let reloadTableSignal: Signal<Void, Never>
    let animateUpdatesSignal: Signal<(), Never>
    let nextViewControllerSignal: Signal<UIViewController, Never>
    
    let challengeID: String?
    
    let challengeProperty: MutableProperty<ChallengeProtocol?>
    let challengeMembershipProperty = MutableProperty<ChallengeMembershipProtocol?>(nil)
    let challengeCreatorProperty = MutableProperty<MemberProtocol?>(nil)
    let viewDidLoadProperty = MutableProperty(())
    let reloadTableProperty = MutableProperty(())
    let animateUpdatesProperty = MutableProperty(())
    let nextViewControllerProperty = MutableProperty<UIViewController?>(nil)
    
    let cellModelsProperty: MutableProperty<[MultiModelDataSourceSection]> = MutableProperty<[MultiModelDataSourceSection]>([])
    let infoSectionProperty: MutableProperty<MultiModelDataSourceSection> = MutableProperty<MultiModelDataSourceSection>(MultiModelDataSourceSection())
    let habitsSectionProperty: MutableProperty<MultiModelDataSourceSection> = MutableProperty<MultiModelDataSourceSection>(MultiModelDataSourceSection())
    let dailiesSectionProperty: MutableProperty<MultiModelDataSourceSection> = MutableProperty<MultiModelDataSourceSection>(MultiModelDataSourceSection())
    let todosSectionProperty: MutableProperty<MultiModelDataSourceSection> = MutableProperty<MultiModelDataSourceSection>(MultiModelDataSourceSection())
    let rewardsSectionProperty: MutableProperty<MultiModelDataSourceSection> = MutableProperty<MultiModelDataSourceSection>(MultiModelDataSourceSection())
    let endSectionProperty: MutableProperty<MultiModelDataSourceSection> = MutableProperty<MultiModelDataSourceSection>(MultiModelDataSourceSection())
    
    let mainButtonItemProperty: MutableProperty<ButtonCellMultiModelDataSourceItem?> = MutableProperty<ButtonCellMultiModelDataSourceItem?>(nil)
    let endButtonItemProperty: MutableProperty<ButtonCellMultiModelDataSourceItem?> = MutableProperty<ButtonCellMultiModelDataSourceItem?>(nil)
    let doubleEndButtonItemProperty: MutableProperty<DoubleButtonMultiModelDataSourceItem?> = MutableProperty<DoubleButtonMultiModelDataSourceItem?>(nil)
    
    let joinLeaveStyleProvider: JoinLeaveButtonAttributeProvider
    let publishStyleProvider: PublishButtonAttributeProvider
    let participantsStyleProvider: ParticipantsButtonAttributeProvider
    let endChallengeStyleProvider: EndChallengeButtonAttributeProvider
    
    var joinInteractor: JoinChallengeInteractor?
    var leaveInteractor: LeaveChallengeInteractor?
    
    private let socialRepository = SocialRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    init(challenge: ChallengeProtocol) {
        self.challengeID = challenge.id
        challengeProperty = MutableProperty<ChallengeProtocol?>(challenge)
        reloadTableSignal = reloadTableProperty.signal
        animateUpdatesSignal = animateUpdatesProperty.signal
        nextViewControllerSignal = nextViewControllerProperty.signal.skipNil()
        
        self.joinInteractor = JoinChallengeInteractor()
        if let viewController = UIApplication.topViewController() {
            self.leaveInteractor = LeaveChallengeInteractor(presentingViewController: viewController)
        }
        
        joinLeaveStyleProvider = JoinLeaveButtonAttributeProvider(challenge)
        publishStyleProvider = PublishButtonAttributeProvider(challenge, userID: socialRepository.currentUserId)
        participantsStyleProvider = ParticipantsButtonAttributeProvider(challenge, userID: socialRepository.currentUserId)
        endChallengeStyleProvider = EndChallengeButtonAttributeProvider(challenge, userID: socialRepository.currentUserId)
        
        let initialCellModelsSignal = cellModelsProperty.signal.sample(on: viewDidLoadProperty.signal)
        
        cellModelsSignal = Signal.merge(cellModelsProperty.signal, initialCellModelsSignal)
        setup(challenge: challenge)
        reloadChallenge()
    }
    
    init(challengeID: String) {
        self.challengeID = challengeID
        
        challengeProperty = MutableProperty<ChallengeProtocol?>(nil)
        reloadTableSignal = reloadTableProperty.signal
        animateUpdatesSignal = animateUpdatesProperty.signal
        nextViewControllerSignal = nextViewControllerProperty.signal.skipNil()
        
        self.joinInteractor = JoinChallengeInteractor()
        if let viewController = UIApplication.topViewController() {
            self.leaveInteractor = LeaveChallengeInteractor(presentingViewController: viewController)
        }
        
        joinLeaveStyleProvider = JoinLeaveButtonAttributeProvider(nil)
        publishStyleProvider = PublishButtonAttributeProvider(nil, userID: socialRepository.currentUserId)
        participantsStyleProvider = ParticipantsButtonAttributeProvider(nil, userID: socialRepository.currentUserId)
        endChallengeStyleProvider = EndChallengeButtonAttributeProvider(nil, userID: socialRepository.currentUserId)
        
        let initialCellModelsSignal = cellModelsProperty.signal.sample(on: viewDidLoadProperty.signal)
        
        cellModelsSignal = Signal.merge(cellModelsProperty.signal, initialCellModelsSignal)
        
        setup(challenge: nil)
        reloadChallenge()
    }
    
    private func setup(_ challenge: ChallengeProtocol?) {
        
    }
        
    private func setup(challenge: ChallengeProtocol?) {
        Signal.combineLatest(infoSectionProperty.signal,
                   habitsSectionProperty.signal,
                   dailiesSectionProperty.signal,
                   todosSectionProperty.signal,
                   rewardsSectionProperty.signal,
                   endSectionProperty.signal)
            .map { sectionTuple -> [MultiModelDataSourceSection] in
                return [sectionTuple.0, sectionTuple.1, sectionTuple.2, sectionTuple.3, sectionTuple.4, sectionTuple.5]
            }
            .observeValues {[weak self] sections in
                self?.cellModelsProperty.value = sections.filter { $0.items?.count ?? 0 > 0 }
        }
        
        setupInfo()
        setupButtons()
        
        challengeProperty.signal.observeValues {[weak self] newChallenge in
            self?.joinLeaveStyleProvider.challengeProperty.value = newChallenge
            self?.publishStyleProvider.challengeProperty.value = newChallenge
            self?.participantsStyleProvider.challengeProperty.value = newChallenge
            self?.endChallengeStyleProvider.challengeProperty.value = newChallenge
        }
        
        challengeMembershipProperty.signal.observeValues {[weak self] (membership) in
            self?.joinLeaveStyleProvider.challengeMembershipProperty.value = membership
        }
        
        joinLeaveStyleProvider.challengeUpdatedProperty.signal.observeValues {[weak self] _ in
            self?.reloadChallenge()
        }
        
        joinLeaveStyleProvider.buttonStateSignal.sample(on: joinLeaveStyleProvider.buttonPressedProperty.signal).observeValues { [weak self] (state) in
            guard let challenge = self?.challengeProperty.value else {
                return
            }
            if state == .join {
                self?.joinInteractor?.run(with: challenge)
            } else {
                self?.leaveInteractor?.run(with: challenge)
            }
        }
    }
    
    func setupInfo() {
        Signal.combineLatest(challengeProperty.signal.skipNil(), challengeMembershipProperty.signal, challengeCreatorProperty.signal)
            .observeValues {[weak self] (challenge, membership, creator) in
            guard let self = self else { return }
            let infoItem = ChallengeDetailHeaderItem(challenge)
            let isParticipating = membership != nil
            let ctaItem = ChallengeDetailCTAItem(isParticipating: isParticipating) {[weak self] in
                guard let self = self, let challenge = self.challengeProperty.value else { return }
                if isParticipating {
                    self.leaveInteractor?.run(with: challenge)
                } else {
                    self.joinInteractor?.run(with: challenge)
                }
            }
            let creatorItem = ChallengeDetailCreatorItem(challenge: challenge, creator: creator, isOwner: challenge.isOwner(self.socialRepository.currentUserId), delegate: self)
            let categoryItem = ChallengeDetailCategoriesItem(challenge)
            let descriptionItem = ChallengeDetailDescriptionItem(challenge)

            let infoSection = MultiModelDataSourceSection()
            infoSection.items = [infoItem, ctaItem, creatorItem, categoryItem, descriptionItem]
            self.infoSectionProperty.value = infoSection
        }
    }
    
    func setupTasks() {
        disposable.inner.add(socialRepository.getChallengeTasks(challengeID: challengeProperty.value?.id ?? "").on(value: {[weak self] (tasks, _) in
            let habitsSection = MultiModelDataSourceSection()
            habitsSection.title = L10n.challengeHabits
            habitsSection.items = tasks.filter({ (task) -> Bool in
                return task.type == TaskType.habit
            }).map({ (task) -> MultiModelDataSourceItem in
                return ChallengeDetailTaskRowItem(task)
            })
            self?.habitsSectionProperty.value = habitsSection
            
            let dailiesSection = MultiModelDataSourceSection()
            dailiesSection.title = L10n.challengeDailies
            dailiesSection.items = tasks.filter({ (task) -> Bool in
                return task.type == TaskType.daily
            }).map({ (task) -> MultiModelDataSourceItem in
                return ChallengeDetailTaskRowItem(task)
            })
            self?.dailiesSectionProperty.value = dailiesSection
            
            let todosSection = MultiModelDataSourceSection()
            todosSection.title = L10n.challengeTodos
            todosSection.items = tasks.filter({ (task) -> Bool in
                return task.type == TaskType.todo
            }).map({ (task) -> MultiModelDataSourceItem in
                return ChallengeDetailTaskRowItem(task)
            })
            self?.todosSectionProperty.value = todosSection
            
            let rewardsSection = MultiModelDataSourceSection()
            rewardsSection.title = L10n.challengeRewards
            rewardsSection.items = tasks.filter({ (task) -> Bool in
                return task.type == TaskType.reward
            }).map({ (task) -> MultiModelDataSourceItem in
                return ChallengeDetailTaskRowItem(task)
            })
            self?.rewardsSectionProperty.value = rewardsSection
        }).start())
    }
    
    func setupButtons() {
        endSectionProperty.value = MultiModelDataSourceSection()
    }
    
    func reloadChallenge() {
        DispatchQueue.main.async {[weak self] in
            self?.socialRepository.retrieveChallenge(challengeID: self?.challengeID ?? "").observeCompleted { }
        }
    }
    
    // MARK: Resizing delegate
    
    func cellResized() {
        animateUpdatesProperty.value = ()
    }
    
    // MARK: Creator delegate
    
    func userPressed(_ member: MemberProtocol) {
        let secondStoryBoard = UIStoryboard(name: "Social", bundle: nil)
        if let userViewController: UserProfileViewController = secondStoryBoard.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController {
            userViewController.userID = member.id
            userViewController.username = member.profile?.name
            nextViewControllerProperty.value = userViewController
        }
    }
    
    func messagePressed(member: MemberProtocol) {
        let secondStoryBoard = UIStoryboard(name: "Social", bundle: nil)
        if let chatViewController: InboxChatViewController = secondStoryBoard.instantiateViewController(withIdentifier: "InboxChatViewController") as? InboxChatViewController {
            chatViewController.userID = member.id
            chatViewController.username = member.profile?.name
            chatViewController.isPresentedModally = true
            nextViewControllerProperty.value = chatViewController
        }
    }
    
    // MARK: ChallengeDetailViewModelInputs
    
    func viewDidLoad() {
        viewDidLoadProperty.value = ()
        
        disposable.inner.add(socialRepository.getChallenge(challengeID: challengeID ?? "")
            .skipNil()
            .on(value: {[weak self] challenge in
                self?.setChallenge(challenge)
            })
            .map { challenge in
                return challenge.leaderID
            }
            .skipNil()
            .observe(on: QueueScheduler.main)
            .flatMap(.latest, {[weak self] leaderID in
                return self?.socialRepository.getMember(userID: leaderID, retrieveIfNotFound: true) ?? SignalProducer.empty
            })
            .on(value: {[weak self] creator in
                self?.challengeCreatorProperty.value = creator
            })
            .start())
        
        if let challengeID = self.challengeID {
            disposable.inner.add(socialRepository.getChallengeMembership(challengeID: challengeID).on(value: {[weak self] membership in
                self?.setChallengeMembership(membership)
            }).start())
        }
        
        setupTasks()
    }
    
    func setChallenge(_ challenge: ChallengeProtocol) {
        challengeProperty.value = challenge
    }
    
    func setChallengeMembership(_ membership: ChallengeMembershipProtocol?) {
        challengeMembershipProperty.value = membership
    }
}

// MARK: -

protocol ChallengeConfigurable {
    func configure(with challenge: ChallengeProtocol, userID: String?)
}

// MARK: -

class ChallengeMultiModelDataSourceItem<T>: ConcreteMultiModelDataSourceItem<T> where T: UITableViewCell, T: ChallengeConfigurable {
    private let challenge: ChallengeProtocol
    
    init(_ challenge: ChallengeProtocol, identifier: String) {
        self.challenge = challenge
        super.init(identifier: identifier)
    }
    
    override func configureCell(_ cell: UITableViewCell, userID: String?) {
        if let clazzCell: T = cell as? T {
            clazzCell.configure(with: challenge, userID: userID)
        }
    }
}

// MARK: -

class ChallengeCreatorMultiModelDataSourceItem: ChallengeMultiModelDataSourceItem<ChallengeCreatorTableViewCell> {
    private let challenge: ChallengeProtocol
    private let creator: MemberProtocol?
    private weak var cellDelegate: ChallengeCreatorCellDelegate?
    
    init(_ challenge: ChallengeProtocol, creator: MemberProtocol?, cellDelegate: ChallengeCreatorCellDelegate, identifier: String) {
        self.challenge = challenge
        self.creator = creator
        self.cellDelegate = cellDelegate
        super.init(challenge, identifier: identifier)
    }
    
    override func configureCell(_ cell: UITableViewCell, userID: String?) {
        super.configureCell(cell, userID: userID)
        
        if let creatorCell = cell as? ChallengeCreatorTableViewCell {
            creatorCell.delegate = cellDelegate
            creatorCell.configure(member: creator)
        }
    }
}

// MARK: -

class ChallengeResizableMultiModelDataSourceItem<T>: ChallengeMultiModelDataSourceItem<T> where T: ChallengeConfigurable, T: ResizableTableViewCell {
    weak var resizingDelegate: ResizableTableViewCellDelegate?
    
    init(_ challenge: ChallengeProtocol, resizingDelegate: ResizableTableViewCellDelegate?, identifier: String) {
        super.init(challenge, identifier: identifier)
        
        self.resizingDelegate = resizingDelegate
    }
    
    override func configureCell(_ cell: UITableViewCell, userID: String?) {
        super.configureCell(cell, userID: userID)
        
        if let clazzCell: T = cell as? T {
            clazzCell.resizingDelegate = resizingDelegate
        }
    }
}

// MARK: -

class ChallengeTaskMultiModelDataSourceItem<T>: ConcreteMultiModelDataSourceItem<T> where T: TaskTableViewCell {
    private let challengeTask: TaskProtocol
    
    public init(_ challengeTask: TaskProtocol, identifier: String) {
        self.challengeTask = challengeTask
        super.init(identifier: identifier)
    }
    
    override func configureCell(_ cell: UITableViewCell, userID: String?) {
        if let clazzCell: T = cell as? T {
            clazzCell.configure(task: challengeTask, isLocked: true)
        }
    }
}

// MARK: -

class RewardMultiModelDataSourceItem<T>: ConcreteMultiModelDataSourceItem<T> where T: ChallengeRewardTableViewCell {
    private let challengeTask: TaskProtocol
    
    public init(_ challengeTask: TaskProtocol, identifier: String) {
        self.challengeTask = challengeTask
        super.init(identifier: identifier)
    }
    
    override func configureCell(_ cell: UITableViewCell, userID: String?) {
        if let clazzCell: T = cell as? T {
            clazzCell.configure(reward: challengeTask)
        }
    }
}

class ChallengeDetailTaskRowItem: ConcreteMultiModelDataSourceItem<UITableViewCell> {
    private let task: TaskProtocol

    init(_ task: TaskProtocol) {
        self.task = task
        super.init(identifier: "challengeDetailTaskRow")
    }

    override func configureCell(_ cell: UITableViewCell, userID: String?) {
        cell.contentConfiguration = UIHostingConfiguration {
            ChallengePlayerTaskRow(task: task)
        }
        .margins(.horizontal, 20)
        .margins(.vertical, 4)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
    }
}

class ChallengeDetailHeaderItem: ConcreteMultiModelDataSourceItem<UITableViewCell> {
    private let challenge: ChallengeProtocol

    init(_ challenge: ChallengeProtocol) {
        self.challenge = challenge
        super.init(identifier: "challengeDetailHeader")
    }

    override func configureCell(_ cell: UITableViewCell, userID: String?) {
        cell.contentConfiguration = UIHostingConfiguration {
            ChallengeDetailHeaderCard(challenge: challenge)
        }
        .margins(.horizontal, 20)
        .margins(.top, 6)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
    }
}

class ChallengeDetailCTAItem: ConcreteMultiModelDataSourceItem<UITableViewCell> {
    private let isParticipating: Bool
    private let onTap: () -> Void

    init(isParticipating: Bool, onTap: @escaping () -> Void) {
        self.isParticipating = isParticipating
        self.onTap = onTap
        super.init(identifier: "challengeDetailCTA")
    }

    override func configureCell(_ cell: UITableViewCell, userID: String?) {
        let onTap = self.onTap
        let isParticipating = self.isParticipating
        cell.contentConfiguration = UIHostingConfiguration {
            ChallengePillButton(isParticipating ? L10n.leaveChallenge : L10n.joinChallenge,
                                fill: isParticipating ? ChallengeTheme.leaveRed : ChallengeTheme.joinGreen,
                                textColor: isParticipating ? ChallengeTheme.leaveRedText : ChallengeTheme.joinGreenText,
                                weight: .bold,
                                action: onTap)
        }
        .margins(.horizontal, 20)
        .margins(.vertical, 6)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
    }
}

class ChallengeDetailCreatorItem: ConcreteMultiModelDataSourceItem<UITableViewCell> {
    private let challenge: ChallengeProtocol
    private let creator: MemberProtocol?
    private let isOwner: Bool
    private weak var delegate: ChallengeCreatorCellDelegate?

    init(challenge: ChallengeProtocol, creator: MemberProtocol?, isOwner: Bool, delegate: ChallengeCreatorCellDelegate?) {
        self.challenge = challenge
        self.creator = creator
        self.isOwner = isOwner
        self.delegate = delegate
        super.init(identifier: "challengeDetailCreator")
    }

    override func configureCell(_ cell: UITableViewCell, userID: String?) {
        let creator = self.creator
        let delegate = self.delegate
        cell.contentConfiguration = UIHostingConfiguration {
            ChallengeDetailCreatorCard(
                challenge: challenge,
                creator: creator,
                isOwner: isOwner,
                onUserTap: { if let creator = creator { delegate?.userPressed(creator) } },
                onMessageTap: { if let creator = creator { delegate?.messagePressed(member: creator) } }
            )
        }
        .margins(.horizontal, 20)
        .margins(.vertical, 4)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
    }
}

class ChallengeDetailCategoriesItem: ConcreteMultiModelDataSourceItem<UITableViewCell> {
    private let challenge: ChallengeProtocol

    init(_ challenge: ChallengeProtocol) {
        self.challenge = challenge
        super.init(identifier: "challengeDetailCategories")
    }

    override func configureCell(_ cell: UITableViewCell, userID: String?) {
        cell.contentConfiguration = UIHostingConfiguration {
            ChallengeDetailCategoriesCard(challenge: challenge)
        }
        .margins(.horizontal, 20)
        .margins(.vertical, 4)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
    }
}

class ChallengeDetailDescriptionItem: ConcreteMultiModelDataSourceItem<UITableViewCell> {
    private let challenge: ChallengeProtocol

    init(_ challenge: ChallengeProtocol) {
        self.challenge = challenge
        super.init(identifier: "challengeDetailDescription")
    }

    override func configureCell(_ cell: UITableViewCell, userID: String?) {
        cell.contentConfiguration = UIHostingConfiguration {
            ChallengeDetailDescriptionCard(challenge: challenge)
        }
        .margins(.horizontal, 20)
        .margins(.vertical, 4)
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
    }
}
