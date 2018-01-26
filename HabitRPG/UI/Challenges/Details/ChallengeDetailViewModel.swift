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
    var cellModelsSignal: Signal<[FixedSizeDataSourceSection], NoError> { get }
    var reloadTableSignal: Signal<Void, NoError> { get }
    var animateUpdatesSignal: Signal<(), NoError> { get }
}

protocol ChallengeDetailViewModelProtocol {
    var inputs: ChallengeDetailViewModelInputs { get }
    var outputs: ChallengeDetailViewModelOutputs { get }
}

class ChallengeDetailViewModel: ChallengeDetailViewModelProtocol, ChallengeDetailViewModelInputs, ChallengeDetailViewModelOutputs, ResizableTableViewCellDelegate {
    var inputs: ChallengeDetailViewModelInputs { return self }
    var outputs: ChallengeDetailViewModelOutputs { return self }
    
    let cellModelsSignal: Signal<[FixedSizeDataSourceSection], NoError>
    let reloadTableSignal: Signal<Void, NoError>
    let animateUpdatesSignal: Signal<(), NoError>
    
    let challengeProperty: MutableProperty<Challenge>
    let viewDidLoadProperty = MutableProperty(())
    let reloadTableProperty = MutableProperty(())
    let animateUpdatesProperty = MutableProperty(())
    
    let cellModelsProperty: MutableProperty<[FixedSizeDataSourceSection]> = MutableProperty<[FixedSizeDataSourceSection]>([])
    let infoSectionProperty: MutableProperty<FixedSizeDataSourceSection> = MutableProperty<FixedSizeDataSourceSection>(FixedSizeDataSourceSection())
    let habitsSectionProperty: MutableProperty<FixedSizeDataSourceSection> = MutableProperty<FixedSizeDataSourceSection>(FixedSizeDataSourceSection())
    let dailiesSectionProperty: MutableProperty<FixedSizeDataSourceSection> = MutableProperty<FixedSizeDataSourceSection>(FixedSizeDataSourceSection())
    let todosSectionProperty: MutableProperty<FixedSizeDataSourceSection> = MutableProperty<FixedSizeDataSourceSection>(FixedSizeDataSourceSection())
    let rewardsSectionProperty: MutableProperty<FixedSizeDataSourceSection> = MutableProperty<FixedSizeDataSourceSection>(FixedSizeDataSourceSection())
    let endSectionProperty: MutableProperty<FixedSizeDataSourceSection> = MutableProperty<FixedSizeDataSourceSection>(FixedSizeDataSourceSection())
    
    let mainButtonItemProperty: MutableProperty<ButtonCellFixedSizeDataSourceItem?> = MutableProperty<ButtonCellFixedSizeDataSourceItem?>(nil)
    let endButtonItemProperty: MutableProperty<ButtonCellFixedSizeDataSourceItem?> = MutableProperty<ButtonCellFixedSizeDataSourceItem?>(nil)
    let doubleEndButtonItemProperty: MutableProperty<DoubleButtonFixedSizeDataSourceItem?> = MutableProperty<DoubleButtonFixedSizeDataSourceItem?>(nil)
    
    let joinLeaveStyleProvider: JoinLeaveButtonAttributeProvider
    let publishStyleProvider: PublishButtonAttributeProvider
    let participantsStyleProvider: ParticipantsButtonAttributeProvider
    let endChallengeStyleProvider: EndChallengeButtonAttributeProvider
    
    init(challenge: Challenge) {
        challengeProperty = MutableProperty<Challenge>(challenge)
        reloadTableSignal = reloadTableProperty.signal
        animateUpdatesSignal = animateUpdatesProperty.signal
        
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
            .map { sectionTuple -> [FixedSizeDataSourceSection] in
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
            let infoItem = ChallengeFixedSizeDataSourceItem<ChallengeDetailInfoTableViewCell>(challenge, identifier: "info")
            let creatorItem = ChallengeFixedSizeDataSourceItem<ChallengeCreatorTableViewCell>(challenge, identifier: "creator")
            let categoryItem = ChallengeResizableFixedSizeDataSourceItem<ChallengeCategoriesTableViewCell>(challenge, resizingDelegate: self, identifier: "categories")
            let descriptionItem = ChallengeResizableFixedSizeDataSourceItem<ChallengeDescriptionTableViewCell>(challenge, resizingDelegate: self, identifier: "description")
            
            let infoSection = FixedSizeDataSourceSection()
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
            let habitsSection = FixedSizeDataSourceSection()
            habitsSection.title = "Habits"
            habitsSection.items = challenge.habits?.map({ (task) -> FixedSizeDataSourceItem in
                return ChallengeTaskFixedSizeDataSourceItem<HabitTableViewCell>(task, identifier: "habit")
            })
            self.habitsSectionProperty.value = habitsSection
            
            let dailiesSection = FixedSizeDataSourceSection()
            dailiesSection.title = "Dailies"
            dailiesSection.items = challenge.dailies?.map({ (task) -> FixedSizeDataSourceItem in
                return ChallengeTaskFixedSizeDataSourceItem<DailyTableViewCell>(task, identifier: "daily")
            })
            self.dailiesSectionProperty.value = dailiesSection
            
            let todosSection = FixedSizeDataSourceSection()
            todosSection.title = "Todos"
            todosSection.items = challenge.todos?.map({ (task) -> FixedSizeDataSourceItem in
                return ChallengeTaskFixedSizeDataSourceItem<ToDoTableViewCell>(task, identifier: "todo")
            })
            self.todosSectionProperty.value = todosSection
            
            let rewardsSection = FixedSizeDataSourceSection()
            rewardsSection.title = "Rewards"
            self.rewardsSectionProperty.value = rewardsSection
        }
    }
    
    func setupButtons() {
        let ownedChallengeSignal = challengeProperty.signal.filter(Challenge.isOwner(of:))
        let unownedChallengeSignal = challengeProperty.signal.filter({ !Challenge.isOwner(of: $0) })
        
        endButtonItemProperty.signal.skipNil().observeValues { (item) in
            let endSection = FixedSizeDataSourceSection()
            endSection.items = [item]
            self.endSectionProperty.value = endSection
        }
        
        doubleEndButtonItemProperty.signal.skipNil().observeValues { (item) in
            let endSection = FixedSizeDataSourceSection()
            endSection.items = [item]
            self.endSectionProperty.value = endSection
        }
        
        let endButtonNilSignal = endButtonItemProperty.signal.map { $0 == nil }
        let doubleEndButtonNilSignal = doubleEndButtonItemProperty.signal.map { $0 == nil }
        endButtonNilSignal.and(doubleEndButtonNilSignal).filter({ $0 }).observeValues({ _ in
            let endSection = FixedSizeDataSourceSection()
            self.endSectionProperty.value = endSection
            
        })
        
        ownedChallengeSignal.observeValues { _ in
            self.doubleEndButtonItemProperty.value = DoubleButtonFixedSizeDataSourceItem(identifier: "endButton", leftAttributeProvider: self.joinLeaveStyleProvider, leftInputs: self.joinLeaveStyleProvider,
                                                                                         rightAttributeProvider: self.endChallengeStyleProvider, rightInputs: self.endChallengeStyleProvider)
        }
        ownedChallengeSignal.filter(Challenge.isPublished(_:)).observeValues { _ in
            self.mainButtonItemProperty.value = ButtonCellFixedSizeDataSourceItem(attributeProvider: self.participantsStyleProvider, inputs: self.participantsStyleProvider, identifier: "mainButton")
        }
        ownedChallengeSignal.filter({ !Challenge.isPublished($0) }).observeValues { _ in
            self.mainButtonItemProperty.value = ButtonCellFixedSizeDataSourceItem(attributeProvider: self.publishStyleProvider, inputs: self.publishStyleProvider, identifier: "mainButton")
        }
        
        unownedChallengeSignal.observeValues { _ in
            self.doubleEndButtonItemProperty.value = nil
        }
        unownedChallengeSignal.filter(Challenge.isJoinable(challenge:)).observeValues { _ in
            self.mainButtonItemProperty.value = ButtonCellFixedSizeDataSourceItem(attributeProvider: self.joinLeaveStyleProvider, inputs: self.joinLeaveStyleProvider, identifier: "mainButton")
            self.endButtonItemProperty.value = nil
            self.doubleEndButtonItemProperty.value = nil
        }
        unownedChallengeSignal.filter({ !Challenge.isJoinable(challenge: $0) }).observeValues { _ in
            self.endButtonItemProperty.value = ButtonCellFixedSizeDataSourceItem(attributeProvider: self.joinLeaveStyleProvider, inputs: self.joinLeaveStyleProvider, identifier: "mainButton")
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

class ChallengeFixedSizeDataSourceItem<T>: ConcreteFixedSizeDataSourceItem<T> where T: UITableViewCell, T: ChallengeConfigurable {
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

class ChallengeResizableFixedSizeDataSourceItem<T>: ChallengeFixedSizeDataSourceItem<T> where T: ChallengeConfigurable, T: ResizableTableViewCell {
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

class ChallengeTaskFixedSizeDataSourceItem<T>: ConcreteFixedSizeDataSourceItem<T> where T: TaskTableViewCell {
    private let challengeTask: ChallengeTask
    
    public init(_ challengeTask: ChallengeTask, identifier: String) {
        self.challengeTask = challengeTask
        super.init(identifier: identifier)
    }
    
    override func configureCell(_ cell: UITableViewCell) {
        if let clazzCell: T = cell as? T {
            clazzCell.configure(task: challengeTask)
        }
    }
}
