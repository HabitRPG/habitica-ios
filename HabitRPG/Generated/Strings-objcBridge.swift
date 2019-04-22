//
//  Strings-objcBridge.swift
//  Habitica
//
//  Created by Phillip Thelen on 30.01.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
// swiftlint:disable:next type_name
public class objcL10n: NSObject {
    @objc public static let close = L10n.close
    @objc public static let cancel = L10n.cancel
    @objc public static let reminder = L10n.reminder
    @objc public static let gems = L10n.gems
    @objc public static let subscription = L10n.subscription
    @objc public static let complete = L10n.complete
    @objc public static let accept = L10n.accept
    @objc public static let reject = L10n.reject
    @objc public static let reply = L10n.reply
    @objc public static let buy = L10n.buy
    @objc public static let success = L10n.success
    @objc public static let openAppStore = L10n.openAppStore
    @objc static let writeAMessage = L10n.writeAMessage
    @objc static let writeMessage = L10n.writeMessage
    @objc static let chooseTask = L10n.chooseTask
    @objc static let habits = L10n.Tasks.habits
    @objc static let dailies = L10n.Tasks.dailies
    @objc static let todos = L10n.Tasks.todos
    @objc static let filterByTags = L10n.filterByTags
    @objc static let clear = L10n.clear
    @objc static let titleFeedPet = L10n.Titles.feedPet
    @objc static let titleShops = L10n.Titles.shops
    @objc static let titleSkills = L10n.Titles.skills
    @objc static let titleSpells = L10n.Titles.spells
    @objc static let titleChooseRecipient = L10n.Titles.chooseRecipient

    @objc public static let all = L10n.all
    @objc public static let weak = L10n.weak
    @objc public static let strong = L10n.strong
    @objc public static let due = L10n.due
    @objc public static let grey = L10n.grey
    @objc public static let active = L10n.active
    @objc public static let dated = L10n.dated
    @objc public static let done = L10n.done
    @objc public static let save = L10n.save
    @objc public static let editTag = L10n.editTag
    @objc public static let createTag = L10n.createTag
    @objc public static let great = L10n.great
    @objc static let username = L10n.username
    @objc static let recipient = L10n.recipient
    
    @objc public static let unlockDropsTitle = L10n.unlockDropsTitle
    @objc public static let unlockDropsDescription = L10n.unlockDropsDescription

    @objc public static let error = L10n.Errors.error
    @objc public static let errorQuestInviteAccept = L10n.Errors.questInviteAccept
    @objc public static let errorQuestInviteReject = L10n.Errors.questInviteReject
    @objc public static let errorReply = L10n.Errors.reply
    
    @objc public static let tutorialAddTask = L10n.Tutorials.addTask
    @objc public static let tutorialEditTask = L10n.Tutorials.editTask
    @objc public static let tutorialFilterTask = L10n.Tutorials.filterTask
    @objc public static let tutorialReorderTask = L10n.Tutorials.reorderTask
    @objc public static let tutorialInbox = L10n.Tutorials.inbox
    @objc public static let tutorialSpells = L10n.Tutorials.spells
 
    @objc static let notGettingDrops = L10n.notGettingDrops
    
    @objc static let streakAchievementTitle = L10n.streakAchievementTitle
    @objc static let streakAchievementDescription = L10n.streakAchievementDescription
    
    @objc static let earnedAchievementShare = L10n.earnedAchievementShare
    
    @objc static let nextCheckinPrize1Day = L10n.nextCheckinPrize1Day
    
    @objc static let invalidRecipientTitle = L10n.invalidRecipientTitle
    @objc static let invalidRecipientMessage = L10n.invalidRecipientMessage
    
    @objc static let noCamera = L10n.noCamera
    @objc static let qrInvalidIdTitle = L10n.qrInvalidIdTitle
    @objc static let qrInvalidIdMessage = L10n.qrInvalidIdMessage
    
    @objc
    static func reportXViolation(username: String) -> String {
        return L10n.reportXViolation(username)
    }
    
    @objc
    static func writeTo(username: String) -> String {
        return L10n.writeTo(username)
    }
    
    @objc
    static func nextCheckinPrizeX(days: Int) -> String {
        return L10n.nextCheckinPrizeXDays(days)
    }
    
    @objc
    static func errorRequest(message: String) -> String {
        return L10n.Errors.request(message)
    }
}
