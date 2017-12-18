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
    func setChallenge(_ challenge: Challenge?)
}

protocol ChallengeDetailViewModelOutputs {
    var cellModelsSignal: Signal<[FixedSizeDataSourceSection], NoError> { get }
}

protocol ChallengeDetailViewModelProtocol {
    var inputs: ChallengeDetailViewModelInputs { get }
    var outputs: ChallengeDetailViewModelOutputs { get }
}

class ChallengeDetailViewModel: ChallengeDetailViewModelProtocol, ChallengeDetailViewModelInputs, ChallengeDetailViewModelOutputs {
    var cellModelsSignal: Signal<[FixedSizeDataSourceSection], NoError>
    
    let challengeProperty: MutableProperty<Challenge?> = MutableProperty<Challenge?>(nil)
    let cellModelsProperty: MutableProperty<[FixedSizeDataSourceSection]> = MutableProperty<[FixedSizeDataSourceSection]>([])
    let viewDidLoadProperty = MutableProperty()
    
    let joinLeaveStyleProvider: JoinLeaveButtonAttributeProvider
    let publishStyleProvider: PublishButtonAttributeProvider
    let participantsStyleProvider: ParticipantsButtonAttributeProvider
    let endChallengeStyleProvider: EndChallengeButtonAttributeProvider
    
    init(challenge: Challenge) {
        joinLeaveStyleProvider = JoinLeaveButtonAttributeProvider(challenge)
        publishStyleProvider = PublishButtonAttributeProvider(challenge)
        participantsStyleProvider = ParticipantsButtonAttributeProvider(challenge)
        endChallengeStyleProvider = EndChallengeButtonAttributeProvider(challenge)
        
        let initialCellModelsSignal = cellModelsProperty.signal.sample(on: viewDidLoadProperty.signal)
        
        cellModelsSignal = Signal.merge(cellModelsProperty.signal, initialCellModelsSignal)
        
        challengeProperty.signal.observeValues { [weak self] (challenge) in
            self?.cellModelsProperty.value = self?.generateCellModels(challenge: challenge) ?? []
        }
        
        reloadChallenge(challenge: challenge)
    }
    
    func reloadChallenge(challenge: Challenge) {
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
                    reloadChallengeTasks(challenge: loadedChallenge)
                }
            } catch {
            }
        }
    }
    
    func reloadChallengeTasks(challenge: Challenge) {
        HRPGManager.shared().fetchChallengeTasks(challenge, onSuccess: {[weak self] () in
            self?.setChallenge(challenge)
            }, onError: nil)
    }
    
    func generateCellModels(challenge: Challenge?) -> [FixedSizeDataSourceSection] {
        let infoSection = FixedSizeDataSourceSection()
        let habitsSection = FixedSizeDataSourceSection()
        let dailiesSection = FixedSizeDataSourceSection()
        let todosSection = FixedSizeDataSourceSection()
        let rewardsSection = FixedSizeDataSourceSection()
        let endSection = FixedSizeDataSourceSection()
        
        if let challenge = challenge {
            var endButtonItem = ButtonCellFixedSizeDataSourceItem(attributeProvider: joinLeaveStyleProvider, inputs: joinLeaveStyleProvider, identifier: "endButton")
            var doubleEndButtonItem = ButtonCellFixedSizeDataSourceItem(attributeProvider: endChallengeStyleProvider, inputs: endChallengeStyleProvider, identifier: "doubleEndButton")
            
            let infoItem = ChallengeFixedSizeDataSourceItem<ChallengeDetailInfoTableViewCell>(challenge, identifier: "info")
            var mainButtonItem: ButtonCellFixedSizeDataSourceItem?
            if (isOwner(of: challenge)) {
                if (isChallengePublished(challenge)) {
                    mainButtonItem = ButtonCellFixedSizeDataSourceItem(attributeProvider: participantsStyleProvider, inputs: participantsStyleProvider, identifier: "mainButton")
                } else {
                    mainButtonItem = ButtonCellFixedSizeDataSourceItem(attributeProvider: publishStyleProvider, inputs: publishStyleProvider, identifier: "mainButton")
                }
                endSection.items = [doubleEndButtonItem]
            } else if (!isChallengeJoinable(challenge: challenge)) {
                endSection.items = [endButtonItem]
            } else {
                mainButtonItem = ButtonCellFixedSizeDataSourceItem(attributeProvider: joinLeaveStyleProvider, inputs: joinLeaveStyleProvider, identifier: "mainButton")
            }
            let creatorItem = ChallengeFixedSizeDataSourceItem<ChallengeCreatorTableViewCell>(challenge, identifier: "creator")
            let descriptionItem = ChallengeFixedSizeDataSourceItem<ChallengeDescriptionTableViewCell>(challenge, identifier: "description")
            
            if let buttonItem = mainButtonItem {
                infoSection.items = [infoItem, buttonItem, creatorItem, descriptionItem]
            } else {
                infoSection.items = [infoItem, creatorItem, descriptionItem]
            }
            
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
        
        let sections = [infoSection, habitsSection, dailiesSection, todosSection, rewardsSection, endSection]
        return sections.filter { $0.items?.count ?? 0 > 0 }
    }
    
    // MARK: ChallengeDetailViewModelInputs
    
    func viewDidLoad() {
        viewDidLoadProperty.value = ()
    }
    
    func setChallenge(_ challenge: Challenge?) {
        challengeProperty.value = challenge
    }
    
    // MARK: ChallengeDetailViewModelProtocol
    
    var inputs: ChallengeDetailViewModelInputs { return self }
    var outputs: ChallengeDetailViewModelOutputs { return self }
}

protocol ChallengeButtonStyleProvider: HRPGButtonAttributeProvider, HRPGButtonModelInputs {
    var challengeUpdatedSignal: Signal<Bool, NoError> { get }
}

class JoinLeaveButtonAttributeProvider: ChallengeButtonStyleProvider {
    
    let challengeProperty: MutableProperty<Challenge?> = MutableProperty<Challenge?>(nil)
    
    let buttonStateSignal: Signal<ChallengeButtonState, NoError>
    let buttonPressedProperty = MutableProperty()
    
    let challengeUpdatedSignal: Signal<Bool, NoError>
    let challengeUpdatedProperty = MutableProperty()
    
    let promptProperty = MutableProperty<UIAlertController?>(nil)
    
    let bgColorSignal: Signal<UIColor?, NoError>
    let titleSignal: Signal<String, NoError>
    let enabledSignal: Signal<Bool, NoError>
    
    init(_ challenge: Challenge?) {
        challengeUpdatedSignal = challengeUpdatedProperty.signal.map { _ in true }
        
        let joinableChallengeSignal = challengeProperty.signal.filter(isChallengeJoinable(challenge:)).map { _ in ChallengeButtonState.join }
        let leaveableChallengeSignal = challengeProperty.signal.filter({ !isChallengeJoinable(challenge: $0) }).map { _ in ChallengeButtonState.leave }
        
        buttonStateSignal = Signal.merge(joinableChallengeSignal, leaveableChallengeSignal).sample(on: triggerStyleProperty.signal)
        
        let joinStyleSignal = buttonStateSignal.filter { $0 == .join }
        let leaveStyleSignal = buttonStateSignal.filter { $0 == .leave }
        
        let greenSignal = joinStyleSignal.map { _ in UIColor.green100() }
        let joinTitleSignal = joinStyleSignal.signal.map { _ in "Join Challenge" }
        
        let redSignal = leaveStyleSignal.map { _ in UIColor.red100() }
        let leaveTitleSignal = leaveStyleSignal.signal.map { _ in "Leave Challenge" }
        
        bgColorSignal = Signal.merge(greenSignal, redSignal)
        titleSignal = Signal.merge(joinTitleSignal, leaveTitleSignal)
        enabledSignal = buttonStateSignal.map { $0 != .publishDisabled }
        
        buttonStateSignal.sample(on: buttonPressedProperty.signal).observeValues { [weak self] (state) in
            if (state == .join) {
                HRPGManager.shared().join(self?.challengeProperty.value, onSuccess: {
                    self?.challengeUpdatedProperty.value = ()
                }, onError: nil)
            } else {
                self?.promptProperty.value = self?.leavePrompt()
            }
        }
        
        challengeProperty.value = challenge
    }
    
    func leavePrompt() -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("Leave Challenge?", comment: ""),
                                      message: NSLocalizedString("Do you want to leave the challenge and keep or delete the tasks?", comment: ""),
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Keep tasks", comment: ""), style: .default, handler: { (_) in
            HRPGManager.shared().leave(self.challengeProperty.value, keepTasks: true, onSuccess: {
                self.challengeUpdatedProperty.value = ()
            }, onError: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete tasks", comment: ""), style: .default, handler: { (_) in
            HRPGManager.shared().leave(self.challengeProperty.value, keepTasks: false, onSuccess: {
                self.challengeUpdatedProperty.value = ()
            }, onError: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (_) in }))
        
        return alert
    }
    
    // MARK: HRPGButtonAttributeProvider functions
    
    let triggerStyleProperty: MutableProperty = MutableProperty()
    func triggerStyle() {
        self.triggerStyleProperty.value = ()
    }
    
    // MARK: HRPGButtonModelInputs functions
    
    func hrpgButtonPressed() {
        buttonPressedProperty.value = ()
    }
}

class PublishButtonAttributeProvider: HRPGButtonAttributeProvider, HRPGButtonModelInputs {
    let challengeProperty: MutableProperty<Challenge?> = MutableProperty<Challenge?>(nil)
    
    let buttonStateSignal: Signal<ChallengeButtonState, NoError>
    let buttonPressedProperty = MutableProperty()
    
    let bgColorSignal: Signal<UIColor?, NoError>
    let titleSignal: Signal<String, NoError>
    let enabledSignal: Signal<Bool, NoError>
    
    init(_ challenge: Challenge?) {
        let publishableChallengeSignal = challengeProperty.signal.filter(shouldBePublishable(challenge:)).map { _ in ChallengeButtonState.publishEnabled }
        let unpublishableChallengeSignal = challengeProperty.signal.filter(shouldBeUnpublishable(challenge:)).map { _ in ChallengeButtonState.publishDisabled }
        
        buttonStateSignal = Signal.merge(publishableChallengeSignal, unpublishableChallengeSignal).sample(on: triggerStyleProperty.signal)
        
        let publishSignal = buttonStateSignal.filter { $0 == .publishEnabled || $0 == .publishDisabled }
        
        bgColorSignal = publishSignal.map { _ in UIColor.purple300() }
        titleSignal = publishSignal.signal.map { _ in "Publish Challenge" }
        enabledSignal = buttonStateSignal.map { $0 != .publishDisabled }
        
        buttonStateSignal.sample(on: buttonPressedProperty.signal).observeValues { (state) in
            if state == .publishEnabled {
                //TODO: publish challenge
            }
        }
        
        challengeProperty.value = challenge
    }
    
    // MARK: HRPGButtonAttributeProvider functions
    
    let triggerStyleProperty = MutableProperty()
    func triggerStyle() {
        triggerStyleProperty.value = ()
    }
    
    // MARK: HRPGButtonModelInputs functions
    
    func hrpgButtonPressed() {
        buttonPressedProperty.value = ()
    }
}

class ParticipantsButtonAttributeProvider: HRPGButtonAttributeProvider, HRPGButtonModelInputs {
    let challengeProperty: MutableProperty<Challenge?> = MutableProperty<Challenge?>(nil)
    
    let buttonStateSignal: Signal<ChallengeButtonState, NoError>
    let buttonPressedProperty = MutableProperty()
    
    let bgColorSignal: Signal<UIColor?, NoError>
    let titleSignal: Signal<String, NoError>
    let enabledSignal: Signal<Bool, NoError>
    
    init(_ challenge: Challenge) {
        let participantsViewableSignal = challengeProperty.signal.filter(isOwner(of:)).filter(isChallengePublished(_:)).filter({ !isChallengeJoinable(challenge: $0)}).map { _ in ChallengeButtonState.viewParticipants }
        
        buttonStateSignal = participantsViewableSignal.sample(on: triggerStyleProperty.signal)
        
        let participantsSignal =  buttonStateSignal.filter { $0 == .viewParticipants }
        
        bgColorSignal = participantsSignal.map { _ in UIColor.gray600() }
        titleSignal = participantsSignal.signal.map { _ in "View Participant Progress" }
        enabledSignal = buttonStateSignal.map { $0 != .publishDisabled }
    }
    
    // MARK: HRPGButtonAttributeProvider functions
    
    let triggerStyleProperty = MutableProperty()
    func triggerStyle() {
        triggerStyleProperty.value = ()
    }
    
    // MARK: HRPGButtonModelInputs functions
    
    func hrpgButtonPressed() {
        buttonPressedProperty.value = ()
    }
}

class EndChallengeButtonAttributeProvider: HRPGButtonAttributeProvider, HRPGButtonModelInputs {
    let challengeProperty: MutableProperty<Challenge?> = MutableProperty<Challenge?>(nil)
    
    let buttonStateSignal: Signal<ChallengeButtonState, NoError>
    let buttonPressedProperty = MutableProperty()
    
    let bgColorSignal: Signal<UIColor?, NoError>
    let titleSignal: Signal<String, NoError>
    let enabledSignal: Signal<Bool, NoError>
    
    init(_ challenge: Challenge) {
        let endableSignal = challengeProperty.signal.filter(isOwner(of:)).map { _ in ChallengeButtonState.endChallenge }
        
        buttonStateSignal = endableSignal.sample(on: triggerStyleProperty.signal)
        
        let endSignal =  buttonStateSignal.filter { $0 == .endChallenge }
        
        bgColorSignal = endSignal.map { _ in UIColor.red100() }
        titleSignal = endSignal.signal.map { _ in "End Challenge" }
        enabledSignal = buttonStateSignal.map { $0 != .publishDisabled }
    }
    
    // MARK: HRPGButtonAttributeProvider functions
    
    let triggerStyleProperty = MutableProperty()
    func triggerStyle() {
        triggerStyleProperty.value = ()
    }
    
    // MARK: HRPGButtonModelInputs functions
    
    func hrpgButtonPressed() {
        buttonPressedProperty.value = ()
    }
}

func shouldBePublishable(challenge: Challenge?) -> Bool {
    if !isOwner(of: challenge) {
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
    if !isOwner(of: challenge) {
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
    if !isOwner(of: challenge) {
        return true
    } else {
        let hasDailies = challenge?.dailies?.count ?? 0 > 0
        let hasHabits = challenge?.habits?.count ?? 0 > 0
        let hasTodos = challenge?.todos?.count ?? 0 > 0
        let hasRewards = challenge?.rewards?.count ?? 0 > 0
        
        return hasDailies || hasHabits || hasTodos || hasRewards
    }
}

func isOwner(of challenge: Challenge?) -> Bool {
    return false
}

func isChallengePublished(_ challenge: Challenge?) -> Bool {
    return false
}

func isChallengeEndable(_ challenge: Challenge?) -> Bool {
    return false
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
    let attributeProvider: HRPGButtonAttributeProvider?
    let inputs: HRPGButtonModelInputs?
    
    init(attributeProvider: HRPGButtonAttributeProvider?, inputs: HRPGButtonModelInputs?, identifier: String) {
        self.attributeProvider = attributeProvider
        self.inputs = inputs
        super.init(identifier: identifier)
    }
    
    override func configureCell(_ cell: UITableViewCell) {
        if let buttonCell = cell as? ChallengeButtonTableViewCell {
            buttonCell.buttonViewModel.attributeProvider = attributeProvider
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
