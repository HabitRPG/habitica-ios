//
//  StringsTests.swift
//  HabiticaTests
//
//  Created by Phillip Thelen on 30.03.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import XCTest
import Nimble
@testable import Habitica

class StringsTests: HabiticaTests {
    
    func testNotificationStrings() {
        print("Testing in \(NSLocale.current.identifier)")
        let groupName = "Test Group"
        expect(L10n.Notifications.partyInvite(groupName)).toNot(beNil())
        expect(L10n.Notifications.privateGuildInvite(groupName)).toNot(beNil())
        expect(L10n.Notifications.publicGuildInvite(groupName)).toNot(beNil())
        expect(L10n.Notifications.questInvite(groupName)).toNot(beNil())
        expect(L10n.Notifications.unallocatedStatPoints(12)).toNot(beNil())
        expect(L10n.Notifications.unreadGuildMessage(groupName)).toNot(beNil())
        expect(L10n.Notifications.unreadPartyMessage(groupName)).toNot(beNil())
    }

    func testGroupStrings() {
        print("Testing in \(NSLocale.current.identifier)")
        let groupName = "Test Group"
        expect(L10n.Party.invitationInvitername("Username", "Group")).toNot(beNil())
        expect(L10n.Party.invitedToQuest(groupName)).toNot(beNil())
        expect(L10n.Party.questNumberResponded(4, 10)).toNot(beNil())
        expect(L10n.Party.questParticipantCount(20)).toNot(beNil())
        expect(L10n.Party.removeMemberTitle("Username")).toNot(beNil())
        expect(L10n.Party.transferOwnershipDescription("Username")).toNot(beNil())
        expect(L10n.Groups.guildInvitationNoInvitername(groupName)).toNot(beNil())
        expect(L10n.Groups.guildInvitationInvitername("Username", groupName)).toNot(beNil())
    }
    
    func testQuestStrings() {
        expect(L10n.Quests.rageAttack("Test")).toNot(beNil())
        expect(L10n.Quests.rewardGold(100)).toNot(beNil())
        expect(L10n.Quests.rewardExperience(1000)).toNot(beNil())
        expect(L10n.Quests.startedBy("Username")).toNot(beNil())
        expect(L10n.Quests.unlockIncentive(12)).toNot(beNil())
        expect(L10n.Quests.unlockIncentiveShort(12)).toNot(beNil())
        expect(L10n.Quests.unlockLevel(12)).toNot(beNil())
        expect(L10n.Quests.unlockLevelShort(12)).toNot(beNil())
        expect(L10n.Quests.unlockPrevious(12)).toNot(beNil())
        expect(L10n.Quests.unlockPreviousShort(12)).toNot(beNil())
    }
    
    func testSkillsStrings() {
        expect(L10n.Skills.unlocksAt(100)).toNot(beNil())
        expect(L10n.Skills.useSkill("Name")).toNot(beNil())
        expect(L10n.Skills.usedTransformationItem("Name")).toNot(beNil())
    }
    
    func testStatsStrings() {
        expect(L10n.Stats.pointsToAllocate(22)).toNot(beNil())
    }
    
    func testTasksStrings() {
        expect(L10n.Tasks.addX("Test")).toNot(beNil())
        expect(L10n.Tasks.dueInXDays(12)).toNot(beNil())
        expect(L10n.Tasks.everyX(4, "Days")).toNot(beNil())
        expect(L10n.Tasks.Form.create("Type")).toNot(beNil())
        expect(L10n.Tasks.Form.edit("Type")).toNot(beNil())
        expect(L10n.Tasks.Form.Accessibility.attribute("Strength")).toNot(beNil())
        expect(L10n.Tasks.Form.Accessibility.disable("Test")).toNot(beNil())
        expect(L10n.Tasks.Form.Accessibility.enable("Test")).toNot(beNil())
        expect(L10n.Tasks.Form.Accessibility.setAttribute("Test")).toNot(beNil())
        expect(L10n.Tasks.Form.Accessibility.setTaskDifficulty("Test")).toNot(beNil())
        expect(L10n.Tasks.Form.Accessibility.taskDifficulty("Test")).toNot(beNil())
        expect(L10n.Tasks.Repeats.monthlyThe("Test")).toNot(beNil())
        expect(L10n.Tasks.Repeats.repeatsEvery("Test")).toNot(beNil())
        expect(L10n.Tasks.Repeats.repeatsEveryOn("Test", "Test2")).toNot(beNil())
    }
    
    func testWorldBossStrings() {
        expect(L10n.WorldBoss.actionPrompt("Test")).toNot(beNil())
        expect(L10n.WorldBoss.rageStrikeDamaged("Test", "2", "3", "4")).toNot(beNil())
        expect(L10n.WorldBoss.rageStrikeTitle("Test")).toNot(beNil())
        expect(L10n.WorldBoss.title("Test")).toNot(beNil())
    }
    
    func testGeneralStrings()  {
        expect(L10n.activeOn("Test")).toNot(beNil())
        expect(L10n.backerTier(4)).toNot(beNil())
        expect(L10n.blockUsername("Test")).toNot(beNil())
        expect(L10n.brokenChallengeDescription(5)).toNot(beNil())
        expect(L10n.buyForX("Test")).toNot(beNil())
        expect(L10n.buyReward("Test", "Test2")).toNot(beNil())
        expect(L10n.canHatchPet("Test", "Test2")).toNot(beNil())
        expect(L10n.checkinPrizeEarned("Test")).toNot(beNil())
        expect(L10n.copiedXToClipboard("Test")).toNot(beNil())
        expect(L10n.deleteChallengeTaskDescription(5, "Test")).toNot(beNil())
        expect(L10n.deleteXTasks(10)).toNot(beNil())
        expect(L10n.endingOn("Test")).toNot(beNil())
        expect(L10n.excessNoItemsLeft("Test", 10, "Test2")).toNot(beNil())
        expect(L10n.excessXItemsLeft(10, "Test", 10)).toNot(beNil())
        expect(L10n.gemCap(10)).toNot(beNil())
        expect(L10n.giftConfirmationBody("Test", "Test2")).toNot(beNil())
        expect(L10n.giftConfirmationBodyG1g1("Test", "Test2")).toNot(beNil())
        expect(L10n.giftSentTo("Test")).toNot(beNil())
        expect(L10n.hourglassCount(10)).toNot(beNil())
        expect(L10n.keepXTasks(10)).toNot(beNil())
        expect(L10n.lastActivity("Test")).toNot(beNil())
        expect(L10n.leaveAndDeleteXTasks(10)).toNot(beNil())
        expect(L10n.levelNumber(10)).toNot(beNil())
        expect(L10n.levelupShare(10)).toNot(beNil())
        expect(L10n.levelupTitle(10)).toNot(beNil())
        expect(L10n.nextCheckinPrizeXDays(10)).toNot(beNil())
        expect(L10n.nextPrizeInXCheckins(10)).toNot(beNil())
        expect(L10n.nextPrizeAtXCheckins(10)).toNot(beNil())
        expect(L10n.openFor("Test")).toNot(beNil())
        expect(L10n.percentComplete(20)).toNot(beNil())
        expect(L10n.petAccessibilityLabelMountOwned("Test")).toNot(beNil())
        expect(L10n.petAccessibilityLabelRaised("Test", 20)).toNot(beNil())
        expect(L10n.purchaseForGems(20)).toNot(beNil())
        expect(L10n.purchaseX(10)).toNot(beNil())
        expect(L10n.purchased("Test")).toNot(beNil())
        expect(L10n.reportXViolation("Test")).toNot(beNil())
        expect(L10n.saleEndsIn("Test")).toNot(beNil())
        expect(L10n.sell(10)).toNot(beNil())
        expect(L10n.subscriptionDuration("Test")).toNot(beNil())
        expect(L10n.subscriptionInfo3DescriptionNew("Test")).toNot(beNil())
        expect(L10n.suggestPetHatchMissingEgg("Test")).toNot(beNil())
        expect(L10n.suggestPetHatchMissingPotion("Test")).toNot(beNil())
        expect(L10n.suggestPetHatchMissingBoth("Test", "Test2")).toNot(beNil())
        expect(L10n.suggestPetHatchAgainMissingEgg("Test")).toNot(beNil())
        expect(L10n.suggestPetHatchAgainMissingPotion("Test")).toNot(beNil())
        expect(L10n.suggestPetHatchAgainMissingBoth("Test", "Test2")).toNot(beNil())
        expect(L10n.userWasBlocked("Test")).toNot(beNil())
        expect(L10n.userWasUnblocked("Test")).toNot(beNil())
        expect(L10n.usuallyXGems(10)).toNot(beNil())
        expect(L10n.writeTo("Test")).toNot(beNil())
        expect(L10n.xFilters(10)).toNot(beNil())
        expect(L10n.xItemsFound(10)).toNot(beNil())
        expect(L10n.xMonths(10)).toNot(beNil())
        expect(L10n.xToY("Test", "Test2")).toNot(beNil())
        
        expect(L10n.Login.socialLogin("Test")).toNot(beNil())
        expect(L10n.Login.socialRegister("Test")).toNot(beNil())
    }
    
    func testInventoryStrings() {
        expect(L10n.Inventory.availableFor("Test")).toNot(beNil())
        expect(L10n.Inventory.availableUntil("Test")).toNot(beNil())
        expect(L10n.Inventory.hatchedSharing("Test", "Test2")).toNot(beNil())
        expect(L10n.Inventory.numberGemsLeft(10, 20)).toNot(beNil())
        expect(L10n.Inventory.wrongClass("Test")).toNot(beNil())
    }
    
    func testErrorStrings() {
        expect(L10n.Errors.passwordLength(8)).toNot(beNil())
        expect(L10n.Errors.request("Username")).toNot(beNil())
    }
}
