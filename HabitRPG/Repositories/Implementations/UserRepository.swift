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
        return currentUserIDProducer.skipNil().flatMap(.latest) {[weak self] (userID) in
            return self?.localRepository.getUser(userID) ?? SignalProducer.empty
        }
    }
    
    func allocate(attributePoint: String) -> Signal<StatsProtocol?, NoError> {
        let call = AllocateAttributePointCall(attribute: attributePoint)
        call.fire()
        return call.objectSignal.on(value: {[weak self] stats in
            if let userId = self?.currentUserId, let stats = stats {
                self?.localRepository.save(userId, stats: stats)
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
        return call.objectSignal.on(value: {[weak self] skillResponse in
                if let response = skillResponse {
                    self?.localRepository.save(userID: self?.currentUserId, skillResponse: response)
                }
            let toastView = ToastView(title: L10n.Skills.useSkill(skill.text ?? ""),
                                      rightIcon: HabiticaIcons.imageOfMagic,
                                      rightText: "-\(skill.mana)",
                rightTextColor: UIColor.blue10(),
                background: .blue)
                ToastManager.show(toast: toastView)
            })
    }
    
    func useTransformationItem(item: SpecialItemProtocol, targetId: String) -> Signal<EmptyResponseProtocol?, NoError> {
        let call = UseTransformationItemCall(item: item, target: targetId)
        call.fire()
        return call.objectSignal.on(value: {[weak self] _ in
            self?.localRepository.usedTransformationItem(userID: self?.currentUserId ?? "", key: item.key ?? "")
            let toastView = ToastView(title: L10n.Skills.usedTransformationItem(item.text ?? ""), background: .gray)
            ToastManager.show(toast: toastView)
        })
    }
    
    func runCron(tasks: [TaskProtocol]) -> Signal<UserProtocol?, NoError> {
        getUser().take(first: 1).on(value: {[weak self]user in
            self?.localRepository.updateCall {
                user.needsCron = false
            }
        }).start()
        if tasks.isEmpty == false {
            var signal = taskRepository.score(task: tasks[0], direction: .up)
            for task in tasks.dropFirst() {
                signal = signal.flatMap(.concat, { _ in
                    return self.taskRepository.score(task: task, direction: .up)
                })
            }
            return signal.flatMap(.latest, {[weak self] _ -> Signal<EmptyResponseProtocol?, NoError> in
                let call = RunCronCall()
                call.fire()
                return call.objectSignal
            }).flatMap(.latest, {[weak self] _ -> Signal<UserProtocol?, NoError> in
                return self?.retrieveUser() ?? Signal.empty
            })
        } else {
            let call = RunCronCall()
            call.fire()
            return call.objectSignal.flatMap(.latest, {[weak self] (_) in
                return self?.retrieveUser() ?? Signal.empty
            })
        }
    }
    
    func updateUser(_ updateDict: [String: Encodable]) -> Signal<UserProtocol?, NoError> {
        let call = UpdateUserCall(updateDict)
        call.fire()
        return call.objectSignal.on(value: handleUserUpdate())
    }
    
    func updateUser(key: String, value: Encodable) -> Signal<UserProtocol?, NoError> {
        return updateUser([key: value])
    }
    
    func updateDayStartTime(_ time: Int) -> Signal<UserProtocol?, NoError> {
        let call = UpdateDayStartTimeCall(time)
        call.fire()
        return call.objectSignal.on(value: handleUserUpdate())
    }
    
    func sleep() -> Signal<EmptyResponseProtocol?, NoError> {
        let call = SleepCall()
        call.fire()
        return call.objectSignal.on(value: {[weak self]_ in
            if let userID = self?.currentUserId {
                self?.localRepository.toggleSleep(userID)
            }
        })
    }
    
    func login(username: String, password: String) -> Signal<LoginResponseProtocol?, NoError> {
        let call = LocalLoginCall(username: username, password: password)
        call.fire()
        return call.objectSignal.merge(with: call.responseSignal.map({ _ -> LoginResponseProtocol? in
            return nil
        }))
            .on(value: { loginResponse in
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
        return call.objectSignal.flatMap(.latest, {[weak self] (_) in
            return self?.retrieveUser() ?? Signal.empty
        })
    }
    
    func deleteAccount(password: String) -> Signal<HTTPURLResponse, NoError> {
        let call = DeleteAccountCall(password: password)
        call.fire()
        return call.httpResponseSignal.on(value: {[weak self] response in
            if response.statusCode == 200 {
                self?.logoutAccount()
            }
        })
    }
    
    func logoutAccount() {
        localRepository.clearDatabase()
        if let userID = currentUserId {
            AuthenticationManager.shared.clearAuthentication(userId: userID)
        }
        deregisterPushDevice().observeCompleted {}
        let defaults = UserDefaults()
        defaults.set("", forKey: "habitFilter")
        defaults.set("", forKey: "dailyFilter")
        defaults.set("", forKey: "todoFilter")
    }
    
    func updateEmail(newEmail: String, password: String) -> Signal<UserProtocol, ReactiveSwiftRealmError> {
        let call = UpdateEmailCall(newEmail: newEmail, password: password)
        call.fire()
        return call.objectSignal.flatMap(.concat, {[weak self] (_) in
            return self?.getUser().take(first: 1) ?? SignalProducer.empty
        }).on(value: {[weak self]user in
            self?.localRepository.updateCall({
                if let local = user.authentication?.local {
                    local.email = newEmail
                }
            })
        })
    }
    
    func updateUsername(newUsername: String, password: String? = nil) -> Signal<UserProtocol, ReactiveSwiftRealmError> {
        let call = UpdateUsernameCall(username: newUsername, password: password)
        call.fire()
        return call.objectSignal
            .filter({ (response) -> Bool in
                return response != nil
            })
            .flatMap(.concat, {[weak self] (_) in
            return self?.getUser().take(first: 1) ?? SignalProducer.empty
        }).on(value: {[weak self]user in
            self?.localRepository.updateCall({
                if let local = user.authentication?.local {
                    local.username = newUsername
                    user.flags?.verifiedUsername = true
                }
            })
            ToastManager.show(text: L10n.usernameConfirmedToast, color: .green)
        })
    }
    
    func verifyUsername(_ newUsername: String) -> Signal<VerifyUsernameResponse?, NoError> {
        let call = VerifyUsernameCall(username: newUsername)
        call.fire()
        return call.objectSignal
    }
    
    func updatePassword(newPassword: String, password: String, confirmPassword: String) -> Signal<EmptyResponseProtocol?, NoError> {
        let call = UpdatePasswordCall(newPassword: newPassword, oldPassword: password, confirmPassword: confirmPassword)
        call.fire()
        return call.objectSignal
    }
    
    func revive() -> Signal<UserProtocol?, NoError> {
        let call = ReviveUserCall()
        call.fire()
        return call.objectSignal.flatMap(.latest, {[weak self] (_) in
            return self?.retrieveUser() ?? Signal.empty
        })
    }
    
    func getUserStyleWithOutfitFor(class habiticaClass: HabiticaClass, userID: String? = nil) -> SignalProducer<UserStyleProtocol, ReactiveSwiftRealmError> {
        return localRepository.getUserStyleWithOutfitFor(class: habiticaClass, userID: userID ?? currentUserId ?? "")
    }
    
    func getInAppRewards() -> SignalProducer<ReactiveResults<[InAppRewardProtocol]>, ReactiveSwiftRealmError> {
        return localRepository.getInAppRewards(userID: currentUserId ?? "")
    }
    
    func retrieveInAppRewards() -> Signal<[InAppRewardProtocol]?, NoError> {
        let call = RetrieveInAppRewardsCall(language: LanguageHandler.getAppLanguage().code)
        call.fire()
        return call.arraySignal.on(value: { inAppRewards in
            if let userID = self.currentUserId, let inAppRewards = inAppRewards {
                self.localRepository.save(userID: userID, inAppRewards: inAppRewards)
            }
        })
    }
    
    func buyCustomReward(reward: TaskProtocol) -> Signal<TaskResponseProtocol?, NoError> {
        return taskRepository.score(task: reward, direction: .down)
    }
    
    func disableClassSystem() -> Signal<UserProtocol?, NoError> {
        let call = DisableClassesCall()
        call.fire()
        return call.objectSignal.on(value: handleUserUpdate())
    }
    
    func selectClass(_ habiticaClass: HabiticaClass) -> Signal<UserProtocol?, NoError> {
        let call = SelectClassCall(class: habiticaClass)
        call.fire()
        return call.objectSignal.on(value: handleUserUpdate())
    }
    
    func reroll() -> Signal<UserProtocol?, NoError> {
        let call = RerollCall()
        call.fire()
        return call.objectSignal.on(value: handleUserUpdate())
    }
    
    func sendPasswordResetEmail(email: String) -> Signal<EmptyResponseProtocol?, NoError> {
        let call = SendPasswordResetEmailCall(email: email)
        call.fire()
        return call.objectSignal
    }
    
    func purchaseGems(receipt: [String: Any], recipient: String? = nil) -> Signal<EmptyResponseProtocol?, NoError> {
        let call = PurchaseGemsCall(receipt: receipt, recipient: recipient)
        call.fire()
        return call.objectSignal
    }
    
    func purchaseNoRenewSubscription(identifier: String, receipt: [String: Any], recipient: String? = nil) -> Signal<EmptyResponseProtocol?, NoError> {
        let call = PurchaseNoRenewSubscriptionCall(identifier: identifier, receipt: receipt, recipient: recipient)
        call.fire()
        return call.objectSignal
    }
    
    func subscribe(sku: String, receipt: String) -> Signal<EmptyResponseProtocol?, NoError> {
        let call = SubscribeCall(sku: sku, receipt: receipt)
        call.fire()
        return call.objectSignal
    }
    
    func getTags() -> SignalProducer<ReactiveResults<[TagProtocol]>, ReactiveSwiftRealmError> {
        return currentUserIDProducer.skipNil().flatMap(.latest, {[weak self] (userID) in
            return self?.localRepository.getTags(userID: userID) ?? SignalProducer.empty
        })
    }
    
    func retrieveInboxMessages() -> Signal<[InboxMessageProtocol]?, NoError> {
        let call = RetrieveInboxMessagesCall()
        call.fire()
        return call.arraySignal.on(value: {[weak self] messages in
            if let messages = messages, let userID = self?.currentUserId {
                self?.localRepository.save(userID: userID, messages: messages)
            }
        })
    }
    
    func registerPushDevice(user: UserProtocol) -> Signal<EmptyResponseProtocol?, NoError> {
        if let deviceID = UserDefaults().string(forKey: "PushNotificationDeviceToken") {
            if user.pushDevices.contains(where: { (pushDevice) -> Bool in
                return pushDevice.regId == deviceID
            }) != true {
                let call = RegisterPushDeviceCall(regID: deviceID)
                call.fire()
                return call.objectSignal
            }
        }
        return Signal.empty
    }
    
    func deregisterPushDevice() -> Signal<EmptyResponseProtocol?, NoError> {
        if let deviceID = UserDefaults().string(forKey: "PushNotificationDeviceToken") {
            let call = DeregisterPushDeviceCall(regID: deviceID)
            call.fire()
            return call.objectSignal
        }
        return Signal.empty
    }
    
    private func handleUserUpdate() -> ((UserProtocol?) -> Void) {
        return { updatedUser in
            if let userID = self.currentUserId, let updatedUser = updatedUser {
                self.localRepository.updateUser(id: userID, updateUser: updatedUser)
            }
        }
    }

}
