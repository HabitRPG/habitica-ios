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

enum ChallengeButtonState {
    case uninitialized, join, leave, publishDisabled, publishEnabled, viewParticipants, endChallenge
}

protocol ChallengeDetailViewModelInputs {
    func viewDidLoad()
    func setChallenge(_ challenge: Challenge)
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
    
    let challengeProperty: MutableProperty<Challenge>
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
    
    init(challenge: Challenge) {
        challengeProperty = MutableProperty<Challenge>(challenge)
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
            habitsSection.items = challenge.habits?.map({ (task) -> MultiModelDataSourceItem in
                return ChallengeTaskMultiModelDataSourceItem<HabitTableViewCell>(task, Challenge.isJoinable(challenge: challenge), identifier: "habit")
            })
            self.habitsSectionProperty.value = habitsSection
            
            let dailiesSection = MultiModelDataSourceSection()
            dailiesSection.title = "Dailies"
            dailiesSection.items = challenge.dailies?.map({ (task) -> MultiModelDataSourceItem in
                return ChallengeTaskMultiModelDataSourceItem<DailyTableViewCell>(task, Challenge.isJoinable(challenge: challenge), identifier: "daily")
            })
            self.dailiesSectionProperty.value = dailiesSection
            
            let todosSection = MultiModelDataSourceSection()
            todosSection.title = "Todos"
            todosSection.items = challenge.todos?.map({ (task) -> MultiModelDataSourceItem in
                return ChallengeTaskMultiModelDataSourceItem<ToDoTableViewCell>(task, Challenge.isJoinable(challenge: challenge), identifier: "todo")
            })
            self.todosSectionProperty.value = todosSection
            
            let rewardsSection = MultiModelDataSourceSection()
            rewardsSection.title = "Rewards"
            rewardsSection.items = challenge.rewards?.map({ (task) -> MultiModelDataSourceItem in
                return RewardMultiModelDataSourceItem<ChallengeRewardTableViewCell>(task, identifier: "reward")
            })
            self.rewardsSectionProperty.value = rewardsSection
        }
    }
    
    func setupButtons() {
        let ownedChallengeSignal = challengeProperty.signal.filter(Challenge.isOwner(of:))
        let unownedChallengeSignal = challengeProperty.signal.filter({ !Challenge.isOwner(of: $0) })
        
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
        ownedChallengeSignal.filter(Challenge.isPublished(_:)).observeValues { _ in
            self.mainButtonItemProperty.value = ButtonCellMultiModelDataSourceItem(attributeProvider: self.participantsStyleProvider, inputs: self.participantsStyleProvider, identifier: "mainButton")
        }
        ownedChallengeSignal.filter({ !Challenge.isPublished($0) }).observeValues { _ in
            self.mainButtonItemProperty.value = ButtonCellMultiModelDataSourceItem(attributeProvider: self.publishStyleProvider, inputs: self.publishStyleProvider, identifier: "mainButton")
        }
        
        unownedChallengeSignal.observeValues { _ in
            self.doubleEndButtonItemProperty.value = nil
        }
        unownedChallengeSignal.filter(Challenge.isJoinable(challenge:)).observeValues { _ in
            self.mainButtonItemProperty.value = ButtonCellMultiModelDataSourceItem(attributeProvider: self.joinLeaveStyleProvider, inputs: self.joinLeaveStyleProvider, identifier: "mainButton")
            self.endButtonItemProperty.value = nil
            self.doubleEndButtonItemProperty.value = nil
        }
        unownedChallengeSignal.filter({ !Challenge.isJoinable(challenge: $0) }).observeValues { _ in
            self.endButtonItemProperty.value = ButtonCellMultiModelDataSourceItem(attributeProvider: self.joinLeaveStyleProvider, inputs: self.joinLeaveStyleProvider, identifier: "mainButton")
        }
    }
    
    func reloadChallenge(challenge: Challenge) {
        loadFromStorage(challenge)
        HRPGManager.shared().fetch(challenge, onSuccess: {
            self.loadFromStorage(challenge)
            self.reloadChallengeTasks(challenge: challenge)
        }, onError: {})
    }
    
    func reloadChallengeTasks(challenge: Challenge) {
        HRPGManager.shared().fetchChallengeTasks(challenge, onSuccess: {[weak self] () in
            self?.setChallenge(challenge)
            }, onError: nil)
    }
    
    func loadFromStorage(_ challenge: Challenge) {
        if let challengeId = challenge.id {
            let entity = NSEntityDescription.entity(forEntityName: "Challenge", in: HRPGManager.shared().getManagedObjectContext())
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            fetchRequest.entity = entity
            fetchRequest.predicate = NSPredicate(format: "id == %@", challengeId)
            do {
                guard let challenges = try HRPGManager.shared().getManagedObjectContext().fetch(fetchRequest) as? [Challenge] else {
                    return
                }
                if challenges.count > 0 {
                    let loadedChallenge = challenges[0]
                    self.setChallenge(loadedChallenge)
                }
            } catch {
            }
        }
    }
    
    // MARK: Resizing delegate
    
    func cellResized() {
        animateUpdatesProperty.value = ()
    }
    
    // MARK: Creator delegate
    
    func userPressed(_ user: User) {
        let secondStoryBoard = UIStoryboard(name: "Social", bundle: nil)
        if let userViewController: HRPGUserProfileViewController = secondStoryBoard.instantiateViewController(withIdentifier: "UserProfileViewController") as? HRPGUserProfileViewController {
            userViewController.userID = user.id
            userViewController.username = user.username
            nextViewControllerProperty.value = userViewController
        }
    }
    
    func messagePressed(user: User) {
        let secondStoryBoard = UIStoryboard(name: "Social", bundle: nil)
        if let chatViewController: HRPGInboxChatViewController = secondStoryBoard.instantiateViewController(withIdentifier: "InboxChatViewController") as? HRPGInboxChatViewController {
            chatViewController.userID = user.id
            chatViewController.username = user.username
            chatViewController.isPresentedModally = true
            nextViewControllerProperty.value = chatViewController
        }
    }
    
    // MARK: ChallengeDetailViewModelInputs
    
    func viewDidLoad() {
        viewDidLoadProperty.value = ()
    }
    
    func setChallenge(_ challenge: Challenge) {
        challengeProperty.value = challenge
    }
}

// MARK: -

protocol ChallengeConfigurable {
    func configure(with challenge: Challenge)
}

// MARK: -

class ChallengeMultiModelDataSourceItem<T>: ConcreteMultiModelDataSourceItem<T> where T: UITableViewCell, T: ChallengeConfigurable {
    private let challenge: Challenge
    
    init(_ challenge: Challenge, identifier: String) {
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
    private let challenge: Challenge
    private weak var cellDelegate: ChallengeCreatorCellDelegate?
    
    init(_ challenge: Challenge, cellDelegate: ChallengeCreatorCellDelegate, identifier: String) {
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
    
    init(_ challenge: Challenge, resizingDelegate: ResizableTableViewCellDelegate?, identifier: String) {
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
    private let challengeTask: ChallengeTask
    private let isLocked: Bool
    
    public init(_ challengeTask: ChallengeTask, _ isLocked: Bool, identifier: String) {
        self.challengeTask = challengeTask
        self.isLocked = isLocked
        super.init(identifier: identifier)
    }
    
    override func configureCell(_ cell: UITableViewCell) {
        if let clazzCell: T = cell as? T {
            clazzCell.isLocked = isLocked
            clazzCell.configure(task: challengeTask)
        }
    }
}

// MARK: -

class RewardMultiModelDataSourceItem<T>: ConcreteMultiModelDataSourceItem<T> where T: ChallengeRewardTableViewCell {
    private let challengeTask: ChallengeTask
    
    public init(_ challengeTask: ChallengeTask, identifier: String) {
        self.challengeTask = challengeTask
        super.init(identifier: identifier)
    }
    
    override func configureCell(_ cell: UITableViewCell) {
        if let clazzCell: T = cell as? T {
            clazzCell.configure(reward: challengeTask)
        }
    }
}
