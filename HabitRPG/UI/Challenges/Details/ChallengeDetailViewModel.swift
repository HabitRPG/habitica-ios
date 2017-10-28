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

enum ChallengeButtonCellState {
    case uninitialized, join, leave, publishDisabled, publishEnabled, viewParticipants
}

protocol ChallengeDetailViewModelInputs {
    func viewDidLoad()
    func setChallenge(_ challenge: Challenge?)
}

protocol ChallengeDetailViewModelOutputs {
    var cellModelsSignal: Signal<[FixedSizeDataSourceSection], NoError> { get }
}

protocol ChallengeDetailViewModelProtocol {
    var inputs: ChallengeDetailViewModelInputs { get }
    var outputs: ChallengeDetailViewModelOutputs { get }
}

class ChallengeDetailViewModel: ChallengeDetailViewModelProtocol, ChallengeDetailViewModelInputs, ChallengeDetailViewModelOutputs, HRPGButtonCellAttributeProvider, HRPGButtonCellModelInputs {
    let bgColorSignal: Signal<UIColor?, NoError>
    let titleSignal: Signal<String, NoError>
    let enabledSignal: Signal<Bool, NoError>
    
    var cellModelsSignal: Signal<[FixedSizeDataSourceSection], NoError>
    
    let challengeProperty: MutableProperty<Challenge?> = MutableProperty<Challenge?>(nil)
    let cellModelsProperty: MutableProperty<[FixedSizeDataSourceSection]> = MutableProperty<[FixedSizeDataSourceSection]>([])
    let buttonCellStateSignal: Signal<ChallengeButtonCellState, NoError>
    let buttonCellButtonPressed = MutableProperty()
    let buttonCellAwokeFromNib = MutableProperty()
    let viewDidLoadProperty = MutableProperty()
    
    init() {
        let joinableChallengeSignal = challengeProperty.signal.filter(isChallengeJoinable(challenge:)).map { _ in ChallengeButtonCellState.join }
        let leaveableChallengeSignal = challengeProperty.signal.filter({ !isChallengeJoinable(challenge: $0) }).map { _ in ChallengeButtonCellState.leave }
        let publishableChallengeSignal = challengeProperty.signal.filter(shouldBePublishable(challenge:)).map { _ in ChallengeButtonCellState.publishEnabled }
        let unpublishableChallengeSignal = challengeProperty.signal.filter(shouldBeUnpublishable(challenge:)).map { _ in ChallengeButtonCellState.publishEnabled }
        // TODO: need to handle view participants
        
        let buttonCellStateMergedSignal = Signal.merge(joinableChallengeSignal, leaveableChallengeSignal, publishableChallengeSignal, unpublishableChallengeSignal)
        
        buttonCellStateSignal = Signal.merge(buttonCellStateMergedSignal, buttonCellStateMergedSignal.sample(on: buttonCellAwokeFromNib.signal))
        
        let joinSignal = buttonCellStateSignal.filter { $0 == .join }
        let leaveSignal = buttonCellStateSignal.filter { $0 == .leave }
        let publishSignal = buttonCellStateSignal.filter { $0 == .publishEnabled || $0 == .publishDisabled }
        let participantsSignal =  buttonCellStateSignal.filter { $0 == .viewParticipants }
        
        let greenSignal = joinSignal.map { _ in UIColor.green100() }
        let purpleSignal = publishSignal.map { _ in UIColor.purple300() }
        let redSignal = leaveSignal.map { _ in UIColor.red100() }
        let greySignal = participantsSignal.map { _ in UIColor.gray600() }
        
        bgColorSignal = Signal.merge(greenSignal, redSignal, purpleSignal, greySignal)
        
        let joinTitleSignal = joinSignal.signal.map { _ in "Join Challenge" }
        let leaveTitleSignal = leaveSignal.signal.map { _ in "Leave Challenge" }
        let publishTitleSignal = publishSignal.signal.map { _ in "Publish Challenge" }
        let participantsTitleSignal = participantsSignal.signal.map { _ in "View Participant Progress" }
        
        titleSignal = Signal.merge(joinTitleSignal, leaveTitleSignal, publishTitleSignal, participantsTitleSignal)
        
        enabledSignal = buttonCellStateSignal.map { $0 != .publishDisabled }
        
        let initialCellModelsSignal = cellModelsProperty.signal.sample(on: viewDidLoadProperty.signal)
        
        cellModelsSignal = Signal.merge(cellModelsProperty.signal, initialCellModelsSignal)
        
        challengeProperty.signal.observeValues { [weak self] (challenge) in
            self?.cellModelsProperty.value = self?.generateCellModels(challenge: challenge) ?? []
        }
    }
    
    func generateCellModels(challenge: Challenge?) -> [FixedSizeDataSourceSection] {
        let infoSection = FixedSizeDataSourceSection()
        let habitsSection = FixedSizeDataSourceSection()
        let dailiesSection = FixedSizeDataSourceSection()
        let todosSection = FixedSizeDataSourceSection()
        let rewardsSection = FixedSizeDataSourceSection()
        
        if let challenge = challenge {
            let infoItem = ChallengeFixedSizeDataSourceItem<ChallengeDetailInfoTableViewCell>(challenge, identifier: "info")
            let buttonItem = ButtonCellFixedSizeDataSourceItem(attributeProvider: self, inputs: self, identifier: "button")
            let creatorItem = ChallengeFixedSizeDataSourceItem<ChallengeCreatorTableViewCell>(challenge, identifier: "creator")
            let descriptionItem = ChallengeFixedSizeDataSourceItem<ChallengeDescriptionTableViewCell>(challenge, identifier: "description")
            infoSection.items = [infoItem, buttonItem, creatorItem, descriptionItem]
            
            habitsSection.title = "Habits"
            habitsSection.items = challenge.habits?.map({ (task) -> FixedSizeDataSourceItem in
                return ChallengeTaskFixedSizeDataSourceItem<HabitTableViewCell>(task, identifier: "habit")
            })
            
            dailiesSection.title = "Dailies"
            dailiesSection.items = challenge.dailies?.map({ (task) -> FixedSizeDataSourceItem in
                return ChallengeTaskFixedSizeDataSourceItem<DailyTableViewCell>(task, identifier: "daily")
            })
            
            todosSection.title = "Todos"
            todosSection.items = challenge.todos?.map({ (task) -> FixedSizeDataSourceItem in
                return ChallengeTaskFixedSizeDataSourceItem<ToDoTableViewCell>(task, identifier: "todo")
            })
            
            rewardsSection.title = "Rewards"
//            rewardsSection.items = challengeProperty.value?.rewards?.map({ (task) -> FixedSizeDataSourceItem in
//                return ChallengeTaskFixedSizeDataSourceItem<RewaTab>(task, identifier: "reward")
//            })
        }
        
        let sections = [infoSection, habitsSection, dailiesSection, todosSection, rewardsSection]
        return sections.filter { $0.items?.count ?? 0 > 0 }
    }
    
    // MARK: ChallengeDetailViewModelInputs
    
    func viewDidLoad() {
        viewDidLoadProperty.value = ()
    }
    
    func setChallenge(_ challenge: Challenge?) {
        challengeProperty.value = challenge
    }
    
    // MARK: HRPGButtonCellAttributeProvider functions
    
    func didButtonCellAwakeFromNib() {
        self.buttonCellAwokeFromNib.value = ()
    }
    
    // MARK: HRPGButtonCellModelInputs functions
    
    func hrpgCellButtonPressed() {
        self.buttonCellButtonPressed.value = ()
    }
    
    // MARK: ChallengeDetailViewModelProtocol
    
    var inputs: ChallengeDetailViewModelInputs { return self }
    var outputs: ChallengeDetailViewModelOutputs { return self }
}

func shouldBePublishable(challenge: Challenge?) -> Bool {
    let isOwner = false
    if !isOwner {
        return false
    } else {
        let hasDailies = challenge?.dailies?.count ?? 0 > 0
        let hasHabits = challenge?.habits?.count ?? 0 > 0
        let hasTodos = challenge?.todos?.count ?? 0 > 0
        let hasRewards = challenge?.rewards?.count ?? 0 > 0
        
        return hasDailies || hasHabits || hasTodos || hasRewards
    }
}

func shouldBeUnpublishable(challenge: Challenge?) -> Bool {
    let isOwner = false
    if !isOwner {
        return false
    } else {
        let hasDailies = challenge?.dailies?.count ?? 0 > 0
        let hasHabits = challenge?.habits?.count ?? 0 > 0
        let hasTodos = challenge?.todos?.count ?? 0 > 0
        let hasRewards = challenge?.rewards?.count ?? 0 > 0
        
        return !(hasDailies || hasHabits || hasTodos || hasRewards)
    }
}

func shouldEnable(challenge: Challenge?) -> Bool {
    let isOwner = false
    if !isOwner {
        return true
    } else {
        let hasDailies = challenge?.dailies?.count ?? 0 > 0
        let hasHabits = challenge?.habits?.count ?? 0 > 0
        let hasTodos = challenge?.todos?.count ?? 0 > 0
        let hasRewards = challenge?.rewards?.count ?? 0 > 0
        
        return hasDailies || hasHabits || hasTodos || hasRewards
    }
}

func isChallengeJoinable(challenge: Challenge?) -> Bool {
    return challenge?.user == nil
}

class ConcreteFixedSizeDataSourceItem<T>: FixedSizeDataSourceItem where T: UITableViewCell {
    private let identifier: String
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    func cellIdentifier() -> String {
        return identifier
    }
    
    func cellClass() -> UITableViewCell.Type {
        return T.self
    }
    
    func configureCell(_ cell: UITableViewCell) {
        // NO OP: override me!
    }
}

class ButtonCellFixedSizeDataSourceItem: ConcreteFixedSizeDataSourceItem<ChallengeButtonTableViewCell> {
    let attributeProvider: HRPGButtonCellAttributeProvider?
    let inputs: HRPGButtonCellModelInputs?
    
    init(attributeProvider: HRPGButtonCellAttributeProvider?, inputs: HRPGButtonCellModelInputs?, identifier: String) {
        self.attributeProvider = attributeProvider
        self.inputs = inputs
        super.init(identifier: identifier)
    }
    
    override func configureCell(_ cell: UITableViewCell) {
        if let buttonCell = cell as? ChallengeButtonTableViewCell {
            buttonCell.attributeProvider = attributeProvider
            buttonCell.modelInputs = inputs
        }
    }
}

protocol ChallengeConfigurable {
    func configure(with challenge: Challenge)
}

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
