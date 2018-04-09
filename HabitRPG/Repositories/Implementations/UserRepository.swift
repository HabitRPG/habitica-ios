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
    var currentUserId: String? {
        return AuthenticationManager.shared.currentUserId
    }
    
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
        if let userId = currentUserId {
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
            if let userId = self.currentUserId, let stats = stats {
                self.localRepository.save(userId, stats: stats)
            }
        })
    }
    
    func bulkAllocate(strength: Int, intelligence: Int, constitution: Int, perception: Int) -> Signal<StatsProtocol?, NoError> {
        let call = BulkAllocateAttributePointsCall(strength: strength, intelligence: intelligence, constitution: constitution, perception: perception)
        call.fire()
        return call.objectSignal.on(value: {stats in
            if let userId = self.currentUserId, let stats = stats {
                self.localRepository.save(userId, stats: stats)
            }
        })
    }
    
    func hasUserData() -> Bool {
        if let userId = self.currentUserId {
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
    
    func updateUser(_ updateDict: [String: Any]) -> Signal<UserProtocol?, NoError> {
        let call = UpdateUserCall(updateDict)
        call.fire()
        return call.objectSignal
    }
    
    func updateUser(key: String, value: Any) -> Signal<UserProtocol?, NoError> {
        return updateUser([key: value])
    }
    
    func sleep() -> Signal<EmptyResponseProtocol?, NoError> {
        let call = SleepCall()
        call.fire()
        return call.objectSignal.on(value: { _ in
            if let userID = self.currentUserId {
                self.localRepository.toggleSleep(userID)
            }
        })
    }
    
    func login(username: String, password: String) -> Signal<LoginResponseProtocol?, NoError> {
        let call = LocalLoginCall(username: username, password: password)
        call.fire()
        return call.objectSignal.on(value: { loginResponse in
            if let response = loginResponse {
                AuthenticationManager.shared.currentUserId = response.id
                AuthenticationManager.shared.currentUserKey = response.apiToken
            }
        })
    }
    
    func register(username: String, password: String, confirmPassword: String, email: String) -> Signal<LoginResponseProtocol?, NoError> {
        let call = LocalRegisterCall(username: username, password: password, confirmPassword: confirmPassword, email: email)
        call.fire()
        return call.objectSignal.on(value: { loginResponse in
            if let response = loginResponse {
                AuthenticationManager.shared.currentUserId = response.id
                AuthenticationManager.shared.currentUserKey = response.apiToken
            }
        })
    }
    
    func login(userID: String, network: String, accessToken: String) -> Signal<LoginResponseProtocol?, NoError> {
        let call = SocialLoginCall(userID: userID, network: network, accessToken: accessToken)
        call.fire()
        return call.objectSignal.on(value: { loginResponse in
            if let response = loginResponse {
                AuthenticationManager.shared.currentUserId = response.id
                AuthenticationManager.shared.currentUserKey = response.apiToken
            }
        })
    }
    
    func resetAccount() -> Signal<UserProtocol?, NoError> {
        let call = ResetAccountCall()
        call.fire()
        return call.objectSignal.flatMap(.concat, { (_) in
            return self.retrieveUser()
        })
    }
    
    func deleteAccount(password: String) -> Signal<EmptyResponseProtocol?, NoError> {
        let call = DeleteAccountCall(password: password)
        call.fire()
        return call.objectSignal.on(value: { _ in
            self.logoutAccount()
        })
    }
    
    func logoutAccount() {
        localRepository.clearDatabase()
        if let userID = currentUserId {
            AuthenticationManager.shared.clearAuthentication(userId: userID)
        }
        let defaults = UserDefaults()
        defaults.set("", forKey: "habitFilter")
        defaults.set("", forKey: "dailyFilter")
        defaults.set("", forKey: "todoFilter")
    }
    
    func updateEmail(newEmail: String, password: String) -> Signal<UserProtocol, ReactiveSwiftRealmError> {
        let call = UpdateEmailCall(newEmail: newEmail, password: password)
        call.fire()
        return call.objectSignal.flatMap(.concat, { (_) in
            return self.getUser().take(first: 1)
        }).on(value: { user in
            self.localRepository.updateCall({
                if let local = user.authentication?.local {
                    local.email = newEmail
                }
            })
        })
    }
    
    func updateUsername(newUsername: String, password: String) -> Signal<UserProtocol, ReactiveSwiftRealmError> {
        let call = UpdateUsernameCall(username: newUsername, password: password)
        call.fire()
        return call.objectSignal.flatMap(.concat, { (_) in
            return self.getUser().take(first: 1)
        }).on(value: { user in
            self.localRepository.updateCall({
                if let local = user.authentication?.local {
                    local.username = newUsername
                }
            })
        })
    }
    
    func updatePassword(newPassword: String, password: String, confirmPassword: String) -> Signal<EmptyResponseProtocol?, NoError> {
        let call = UpdatePasswordCall(newPassword: newPassword, oldPassword: password, confirmPassword: confirmPassword)
        call.fire()
        return call.objectSignal
    }
}
