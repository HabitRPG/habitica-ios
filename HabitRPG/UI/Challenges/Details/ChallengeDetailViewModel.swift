//
//  ChallengeDetailViewModel.swift
//  Habitica
//
//  Created by Elliot Schrock on 10/17/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result
import Habitica_Models

enum ChallengeButtonState {
    case uninitialized, join, leave, publishDisabled, publishEnabled, viewParticipants, endChallenge
}

protocol ChallengeDetailViewModelInputs {
    func viewDidLoad()
    func setChallenge(_ challenge: ChallengeProtocol)
}

protocol ChallengeDetailViewModelOutputs {
    var cellModelsSignal: Signal<[MultiModelDataSourceSection], NoError> { get }
    var reloadTableSignal: Signal<Void, NoError> { get }
    var animateUpdatesSignal: Signal<(), NoError> { get }
    var nextViewControllerSignal: Signal<UIViewController, NoError> { get }
}

protocol ChallengeDetailViewModelProtocol {
    var inputs: ChallengeDetailViewModelInputs { get }
    var outputs: ChallengeDetailViewModelOutputs { get }
}

class ChallengeDetailViewModel: ChallengeDetailViewModelProtocol, ChallengeDetailViewModelInputs, ChallengeDetailViewModelOutputs, ResizableTableViewCellDelegate, ChallengeCreatorCellDelegate {
    var inputs: ChallengeDetailViewModelInputs { return self }
    var outputs: ChallengeDetailViewModelOutputs { return self }
    
    let cellModelsSignal: Signal<[MultiModelDataSourceSection], NoError>
    let reloadTableSignal: Signal<Void, NoError>
    let animateUpdatesSignal: Signal<(), NoError>
    let nextViewControllerSignal: Signal<UIViewController, NoError>
    
    let challengeProperty: MutableProperty<ChallengeProtocol>
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
        challengeProperty = MutableProperty<ChallengeProtocol>(challenge)
        reloadTableSignal = reloadTableProperty.signal
        animateUpdatesSignal = animateUpdatesProperty.signal
        nextViewControllerSignal = nextViewControllerProperty.signal.skipNil()
        
        joinLeaveStyleProvider = JoinLeaveButtonAttributeProvider(challenge)
        publishStyleProvider = PublishButtonAttributeProvider(challenge)
        participantsStyleProvider = ParticipantsButtonAttributeProvider(challenge)
        endChallengeStyleProvider = EndChallengeButtonAttributeProvider(challenge)
        
        let initialCellModelsSignal = cellModelsProperty.signal.sample(on: viewDidLoadProperty.signal)
        
        cellModelsSignal = Signal.merge(cellModelsProperty.signal, initialCellModelsSignal)
        
        Signal.zip(infoSectionProperty.signal,
                   habitsSectionProperty.signal,
                   dailiesSectionProperty.signal,
                   todosSectionProperty.signal,
                   rewardsSectionProperty.signal,
                   endSectionProperty.signal)
            .map { sectionTuple -> [MultiModelDataSourceSection] in
                return [sectionTuple.0, sectionTuple.1, sectionTuple.2, sectionTuple.3, sectionTuple.4, sectionTuple.5]
            }
            .observeValues { sections in
                self.cellModelsProperty.value = sections.filter { $0.items?.count ?? 0 > 0 }
        }
        
        setupInfo()
        
        setupButtons()
        
        setupTasks()
        
        reloadChallenge(challenge: challenge)
        
        challengeProperty.signal.observeValues { newChallenge in
            self.joinLeaveStyleProvider.challengeProperty.value = newChallenge
            self.publishStyleProvider.challengeProperty.value = newChallenge
            self.participantsStyleProvider.challengeProperty.value = newChallenge
            self.endChallengeStyleProvider.challengeProperty.value = newChallenge
        }
        
        joinLeaveStyleProvider.challengeUpdatedProperty.signal.observeValues { _ in
            self.reloadChallenge(challenge: self.challengeProperty.value)
        }
        
        disposable.inner.add(socialRepository.getChallenge(challengeID: challenge.id ?? "")
            .skipNil()
            .on(value: { challenge in
            self.setChallenge(challenge)
        }).start())
    }
    
    func setupInfo() {
        challengeProperty.signal.observeValues { (challenge) in
            let infoItem = ChallengeMultiModelDataSourceItem<ChallengeDetailInfoTableViewCell>(challenge, identifier: "info")
            let creatorItem = ChallengeCreatorMultiModelDataSourceItem(challenge, cellDelegate: self, identifier: "creator")
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
        challengeProperty.signal.observeValues { (challenge) in
            let habitsSection = MultiModelDataSourceSection()
            habitsSection.title = "Habits"
            habitsSection.items = challenge.habits.map({ (task) -> MultiModelDataSourceItem in
                return ChallengeTaskMultiModelDataSourceItem<HabitTableViewCell>(task, identifier: "habit")
            })
            self.habitsSectionProperty.value = habitsSection
            
            let dailiesSection = MultiModelDataSourceSection()
            dailiesSection.title = "Dailies"
            dailiesSection.items = challenge.dailies.map({ (task) -> MultiModelDataSourceItem in
                return ChallengeTaskMultiModelDataSourceItem<DailyTableViewCell>(task, identifier: "daily")
            })
            self.dailiesSectionProperty.value = dailiesSection
            
            let todosSection = MultiModelDataSourceSection()
            todosSection.title = "Todos"
            todosSection.items = challenge.todos.map({ (task) -> MultiModelDataSourceItem in
                return ChallengeTaskMultiModelDataSourceItem<ToDoTableViewCell>(task, identifier: "todo")
            })
            self.todosSectionProperty.value = todosSection
            
            let rewardsSection = MultiModelDataSourceSection()
            rewardsSection.title = "Rewards"
            rewardsSection.items = challenge.rewards.map({ (task) -> MultiModelDataSourceItem in
                return RewardMultiModelDataSourceItem<ChallengeRewardTableViewCell>(task, identifier: "reward")
            })
            self.rewardsSectionProperty.value = rewardsSection
        }
    }
    
    func setupButtons() {
        let ownedChallengeSignal = challengeProperty.signal.filter { (challenge) -> Bool in
            return challenge.isOwner()
        }
        let unownedChallengeSignal = challengeProperty.signal.filter { (challenge) -> Bool in
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
        
        ownedChallengeSignal.observeValues { _ in
            self.doubleEndButtonItemProperty.value = DoubleButtonMultiModelDataSourceItem(identifier: "endButton", leftAttributeProvider: self.joinLeaveStyleProvider, leftInputs: self.joinLeaveStyleProvider,
                                                                                         rightAttributeProvider: self.endChallengeStyleProvider, rightInputs: self.endChallengeStyleProvider)
        }
        ownedChallengeSignal
            .filter({ (challenge) -> Bool in
                return challenge.isPublished()
            }).observeValues { _ in
            self.mainButtonItemProperty.value = ButtonCellMultiModelDataSourceItem(attributeProvider: self.participantsStyleProvider, inputs: self.participantsStyleProvider, identifier: "mainButton")
        }
        ownedChallengeSignal
            .filter({ (challenge) -> Bool in
                return !challenge.isPublished()
            }).observeValues { _ in
            self.mainButtonItemProperty.value = ButtonCellMultiModelDataSourceItem(attributeProvider: self.publishStyleProvider, inputs: self.publishStyleProvider, identifier: "mainButton")
        }
        
        unownedChallengeSignal.observeValues { _ in
            self.doubleEndButtonItemProperty.value = nil
        }
        unownedChallengeSignal
            .filter({ (challenge) -> Bool in
                return challenge.isJoinable()
            }).observeValues { _ in
            self.mainButtonItemProperty.value = ButtonCellMultiModelDataSourceItem(attributeProvider: self.joinLeaveStyleProvider, inputs: self.joinLeaveStyleProvider, identifier: "mainButton")
            self.endButtonItemProperty.value = nil
            self.doubleEndButtonItemProperty.value = nil
        }
        unownedChallengeSignal
            .filter({ (challenge) -> Bool in
                return !challenge.isJoinable()
            }).observeValues { _ in
            self.endButtonItemProperty.value = ButtonCellMultiModelDataSourceItem(attributeProvider: self.joinLeaveStyleProvider, inputs: self.joinLeaveStyleProvider, identifier: "mainButton")
        }
    }
    
    func reloadChallenge(challenge: ChallengeProtocol) {
        socialRepository.retrieveChallenge(challengeID: challenge.id ?? "").observeCompleted {
            self.reloadChallengeTasks(challenge: challenge)
        }
    }
    
    func reloadChallengeTasks(challenge: ChallengeProtocol) {
    }
    
    // MARK: Resizing delegate
    
    func cellResized() {
        animateUpdatesProperty.value = ()
    }
    
    // MARK: Creator delegate
    
    func userPressed(_ user: UserProtocol) {
        let secondStoryBoard = UIStoryboard(name: "Social", bundle: nil)
        if let userViewController: UserProfileViewController = secondStoryBoard.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController {
            userViewController.userID = user.id
            userViewController.username = user.profile?.name
            nextViewControllerProperty.value = userViewController
        }
    }
    
    func messagePressed(user: UserProtocol) {
        let secondStoryBoard = UIStoryboard(name: "Social", bundle: nil)
        if let chatViewController: HRPGInboxChatViewController = secondStoryBoard.instantiateViewController(withIdentifier: "InboxChatViewController") as? HRPGInboxChatViewController {
            chatViewController.userID = user.id
            chatViewController.username = user.profile?.name
            chatViewController.isPresentedModally = true
            nextViewControllerProperty.value = chatViewController
        }
    }
    
    // MARK: ChallengeDetailViewModelInputs
    
    func viewDidLoad() {
        viewDidLoadProperty.value = ()
    }
    
    func setChallenge(_ challenge: ChallengeProtocol) {
        challengeProperty.value = challenge
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
    private weak var cellDelegate: ChallengeCreatorCellDelegate?
    
    init(_ challenge: ChallengeProtocol, cellDelegate: ChallengeCreatorCellDelegate, identifier: String) {
        self.challenge = challenge
        self.cellDelegate = cellDelegate
        super.init(challenge, identifier: identifier)
    }
    
    override func configureCell(_ cell: UITableViewCell) {
        super.configureCell(cell)
        
        if let creatorCell = cell as? ChallengeCreatorTableViewCell {
            creatorCell.delegate = cellDelegate
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
