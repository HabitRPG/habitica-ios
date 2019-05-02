//
//  ChallengeDetailViewModel.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/17/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
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
    
    private let socialRepository = SocialRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    init(challenge: ChallengeProtocol) {
        self.challengeID = challenge.id
        challengeProperty = MutableProperty<ChallengeProtocol?>(challenge)
        reloadTableSignal = reloadTableProperty.signal
        animateUpdatesSignal = animateUpdatesProperty.signal
        nextViewControllerSignal = nextViewControllerProperty.signal.skipNil()
        
        joinLeaveStyleProvider = JoinLeaveButtonAttributeProvider(challenge)
        publishStyleProvider = PublishButtonAttributeProvider(challenge)
        participantsStyleProvider = ParticipantsButtonAttributeProvider(challenge)
        endChallengeStyleProvider = EndChallengeButtonAttributeProvider(challenge)
        
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
        
        joinLeaveStyleProvider = JoinLeaveButtonAttributeProvider(nil)
        publishStyleProvider = PublishButtonAttributeProvider(nil)
        participantsStyleProvider = ParticipantsButtonAttributeProvider(nil)
        endChallengeStyleProvider = EndChallengeButtonAttributeProvider(nil)
        
        let initialCellModelsSignal = cellModelsProperty.signal.sample(on: viewDidLoadProperty.signal)
        
        cellModelsSignal = Signal.merge(cellModelsProperty.signal, initialCellModelsSignal)
        
        setup(challenge: nil)
        reloadChallenge()
    }
        
    private func setup(challenge: ChallengeProtocol?) {
        Signal.zip(infoSectionProperty.signal,
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
        
        setupButtons()
        
        setupInfo()
        
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
    }
    
    func setupInfo() {
        challengeProperty.signal.skipNil().combineLatest(with: challengeCreatorProperty.signal)
            .observeValues { (challenge, creator) in
            let infoItem = ChallengeMultiModelDataSourceItem<ChallengeDetailInfoTableViewCell>(challenge, identifier: "info")
                let creatorItem = ChallengeCreatorMultiModelDataSourceItem(challenge, creator: creator, cellDelegate: self, identifier: "creator")
            let categoryItem = ChallengeResizableMultiModelDataSourceItem<ChallengeCategoriesTableViewCell>(challenge, resizingDelegate: self, identifier: "categories")
            let descriptionItem = ChallengeResizableMultiModelDataSourceItem<ChallengeDescriptionTableViewCell>(challenge, resizingDelegate: self, identifier: "description")
            
            let infoSection = MultiModelDataSourceSection()
            if let mainButton = self.mainButtonItemProperty.value {
                infoSection.items = [infoItem, mainButton, creatorItem, categoryItem, descriptionItem]
            } else {
                infoSection.items = [infoItem, creatorItem, categoryItem, descriptionItem]
            }
            self.infoSectionProperty.value = infoSection
        }
    }
    
    func setupTasks() {
        disposable.inner.add(socialRepository.getChallengeTasks(challengeID: challengeProperty.value?.id ?? "").on(value: {[weak self] (tasks, _) in
            let habitsSection = MultiModelDataSourceSection()
            habitsSection.title = "Habits"
            habitsSection.items = tasks.filter({ (task) -> Bool in
                return task.type == TaskType.habit
            }).map({ (task) -> MultiModelDataSourceItem in
                return ChallengeTaskMultiModelDataSourceItem<HabitTableViewCell>(task, identifier: "habit")
            })
            self?.habitsSectionProperty.value = habitsSection
            
            let dailiesSection = MultiModelDataSourceSection()
            dailiesSection.title = "Dailies"
            dailiesSection.items = tasks.filter({ (task) -> Bool in
                return task.type == TaskType.daily
            }).map({ (task) -> MultiModelDataSourceItem in
                return ChallengeTaskMultiModelDataSourceItem<DailyTableViewCell>(task, identifier: "daily")
            })
            self?.dailiesSectionProperty.value = dailiesSection
            
            let todosSection = MultiModelDataSourceSection()
            todosSection.title = "Todos"
            todosSection.items = tasks.filter({ (task) -> Bool in
                return task.type == TaskType.todo
            }).map({ (task) -> MultiModelDataSourceItem in
                return ChallengeTaskMultiModelDataSourceItem<ToDoTableViewCell>(task, identifier: "todo")
            })
            self?.todosSectionProperty.value = todosSection
            
            let rewardsSection = MultiModelDataSourceSection()
            rewardsSection.title = "Rewards"
            rewardsSection.items = tasks.filter({ (task) -> Bool in
                return task.type == TaskType.reward
            }).map({ (task) -> MultiModelDataSourceItem in
                return RewardMultiModelDataSourceItem<ChallengeRewardTableViewCell>(task, identifier: "reward")
            })
            self?.rewardsSectionProperty.value = rewardsSection
        }).start())
    }
    
    func setupButtons() {
        let ownedChallengeSignal = challengeProperty.signal.skipNil().filter { (challenge) -> Bool in
            return challenge.isOwner()
        }
        let unownedChallengeSignal = challengeProperty.signal.skipNil().filter { (challenge) -> Bool in
            return !challenge.isOwner()
        }
        
        endButtonItemProperty.signal.skipNil().observeValues { (item) in
            let endSection = MultiModelDataSourceSection()
            endSection.items = [item]
            self.endSectionProperty.value = endSection
        }
        
        doubleEndButtonItemProperty.signal.skipNil().observeValues { (item) in
            let endSection = MultiModelDataSourceSection()
            endSection.items = [item]
            self.endSectionProperty.value = endSection
        }
        
        let endButtonNilSignal = endButtonItemProperty.signal.map { $0 == nil }
        let doubleEndButtonNilSignal = doubleEndButtonItemProperty.signal.map { $0 == nil }
        endButtonNilSignal.and(doubleEndButtonNilSignal).filter({ $0 }).observeValues({ _ in
            let endSection = MultiModelDataSourceSection()
            self.endSectionProperty.value = endSection
        })
        
        ownedChallengeSignal.observeValues {[weak self] _ in
            self?.doubleEndButtonItemProperty.value = DoubleButtonMultiModelDataSourceItem(identifier: "endButton", leftAttributeProvider: self?.joinLeaveStyleProvider, leftInputs: self?.joinLeaveStyleProvider,
                                                                                         rightAttributeProvider: self?.endChallengeStyleProvider, rightInputs: self?.endChallengeStyleProvider)
        }
        ownedChallengeSignal
            .filter({ (challenge) -> Bool in
                return challenge.isPublished()
            }).observeValues {[weak self] _ in
            self?.mainButtonItemProperty.value = ButtonCellMultiModelDataSourceItem(attributeProvider: self?.participantsStyleProvider, inputs: self?.participantsStyleProvider, identifier: "mainButton")
        }
        ownedChallengeSignal
            .filter({ (challenge) -> Bool in
                return !challenge.isPublished()
            }).observeValues {[weak self] _ in
            self?.mainButtonItemProperty.value = ButtonCellMultiModelDataSourceItem(attributeProvider: self?.publishStyleProvider, inputs: self?.publishStyleProvider, identifier: "mainButton")
        }
        
        unownedChallengeSignal.observeValues { _ in
            self.doubleEndButtonItemProperty.value = nil
        }
        unownedChallengeSignal.withLatest(from: challengeMembershipProperty.signal)
            .filter({ (_, membership) -> Bool in
                return membership == nil
            }).observeValues {[weak self] _ in
                self?.mainButtonItemProperty.value = ButtonCellMultiModelDataSourceItem(attributeProvider: self?.joinLeaveStyleProvider, inputs: self?.joinLeaveStyleProvider, identifier: "mainButton")
                self?.endButtonItemProperty.value = nil
                self?.doubleEndButtonItemProperty.value = nil
        }
        unownedChallengeSignal.withLatest(from: challengeMembershipProperty.signal)
            .filter({ (_, membership) -> Bool in
                return membership != nil
            }).observeValues {[weak self] _ in
                self?.endButtonItemProperty.value = ButtonCellMultiModelDataSourceItem(attributeProvider: self?.joinLeaveStyleProvider, inputs: self?.joinLeaveStyleProvider, identifier: "mainButton")
        }
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
        if let chatViewController: HRPGInboxChatViewController = secondStoryBoard.instantiateViewController(withIdentifier: "InboxChatViewController") as? HRPGInboxChatViewController {
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
    func configure(with challenge: ChallengeProtocol)
}

// MARK: -

class ChallengeMultiModelDataSourceItem<T>: ConcreteMultiModelDataSourceItem<T> where T: UITableViewCell, T: ChallengeConfigurable {
    private let challenge: ChallengeProtocol
    
    init(_ challenge: ChallengeProtocol, identifier: String) {
        self.challenge = challenge
        super.init(identifier: identifier)
    }
    
    override func configureCell(_ cell: UITableViewCell) {
        if let clazzCell: T = cell as? T {
            clazzCell.configure(with: challenge)
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
    
    override func configureCell(_ cell: UITableViewCell) {
        super.configureCell(cell)
        
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
    
    override func configureCell(_ cell: UITableViewCell) {
        super.configureCell(cell)
        
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
    
    override func configureCell(_ cell: UITableViewCell) {
        if let clazzCell: T = cell as? T {
            clazzCell.configure(task: challengeTask)
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
    
    override func configureCell(_ cell: UITableViewCell) {
        if let clazzCell: T = cell as? T {
            clazzCell.configure(reward: challengeTask)
        }
    }
}
