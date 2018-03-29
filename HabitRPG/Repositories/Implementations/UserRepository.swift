//
//  UserRepository.swift
//  Habitica
//
//  Created by Phillip Thelen on 07.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import Habitica_Database
import Habitica_API_Client
import ReactiveSwift
import Result

class UserRepository: BaseRepository<UserLocalRepository> {
    
    var taskRepository = TaskRepository()
    
    func retrieveUser(withTasks: Bool = true) -> Signal<UserProtocol?, NoError> {
        let call = RetrieveUserCall()
        call.fire()
        let signal = call.objectSignal.on(value: {[weak self] user in
            if let user = user {
                self?.localRepository.save(user)
            }
        })
        if withTasks {
            let taskCall = RetrieveTasksCall()
            taskCall.fire()
            return signal.combineLatest(with: taskCall.arraySignal).on(value: {[weak self] (user, tasks) in
                if let tasks = tasks, let order = user?.tasksOrder {
                    self?.taskRepository.save(tasks, order: order)
                }
            }).map({ (user, _) in
                return user
            })
        } else {
            return signal
        }
    }
    
    func getUser() -> SignalProducer<UserProtocol, ReactiveSwiftRealmError> {
        if let userId = AuthenticationManager.shared.currentUserId {
            return localRepository.getUser(userId)
        } else {
            return SignalProducer {(sink, _) in
                sink.sendCompleted()
            }
        }
    }
    
    func allocate(attributePoint: String) -> Signal<StatsProtocol?, NoError> {
        let call = AllocateAttributePointCall(attribute: attributePoint)
        call.fire()
        return call.objectSignal.on(value: {stats in
            if let userId = AuthenticationManager.shared.currentUserId, let stats = stats {
                self.localRepository.save(userId, stats: stats)
            }
        })
    }
    
    func bulkAllocate(strength: Int, intelligence: Int, constitution: Int, perception: Int) -> Signal<StatsProtocol?, NoError> {
        let call = BulkAllocateAttributePointsCall(strength: strength, intelligence: intelligence, constitution: constitution, perception: perception)
        call.fire()
        return call.objectSignal.on(value: {stats in
            if let userId = AuthenticationManager.shared.currentUserId, let stats = stats {
                self.localRepository.save(userId, stats: stats)
            }
        })
    }
    
    func hasUserData() -> Bool {
        if let userId = AuthenticationManager.shared.currentUserId {
            return localRepository.hasUserData(id: userId)
        } else {
            return false
        }
    }
    
    func useSkill(skill: SkillProtocol, targetId: String? = nil) -> Signal<SkillResponseProtocol?, NoError> {
        let call = UseSkillCall(skill: skill, target: targetId)
        call.fire()
        return call.objectSignal.on(value: { skillResponse in
                if let response = skillResponse {
                    self.localRepository.save(response)
                }
            let toastView = ToastView(title: L10n.Skills.useSkill(skill.text ?? ""),
                                      rightIcon: HabiticaIcons.imageOfMagic,
                                      rightText: "-\(skill.mana)",
                rightTextColor: UIColor.blue10(),
                background: .blue)
                ToastManager.show(toast: toastView)
            })
    }
    
    func runCron(tasks: [TaskProtocol]) -> Signal<EmptyResponseProtocol?, NoError> {
        if tasks.count > 0 {
            var signal = taskRepository.score(task: tasks[0], direction: .up)
            for task in tasks {
                signal = signal.flatMap(.concat, { (_) in
                    return self.taskRepository.score(task: task, direction: .up)
                })
            }
            return signal.flatMap(.concat, { (_) -> Signal<EmptyResponseProtocol?, NoError> in
                let call = RunCronCall()
                call.fire()
                return call.objectSignal
            })
        } else {
            let call = RunCronCall()
            call.fire()
            return call.objectSignal
        }
    }
}
