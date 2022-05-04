//
//  HabiticaNotificationType.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 23.04.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

// swiftlint:disable inclusive_language
public enum HabiticaNotificationType: String, EquatableStringEnumProtocol {
    case generic = ""
    case newStuff = "NEW_STUFF"
    case newChatMessage = "NEW_CHAT_MESSAGE"
    case newMysteryItem = "NEW_MYSTERY_ITEMS"
    case unallocatedStatsPoints = "UNALLOCATED_STATS_POINTS"
    case questInvite = "QUEST_INVITE"
    case groupInvite = "GROUP_INVITE"
    
    // Achievements
    case achievementPartyUp = "ACHIEVEMENT_PARTY_UP"
    case achievementPartyOn = "ACHIEVEMENT_PARTY_ON"
    case achievementBeastMaster = "ACHIEVEMENT_BEAST_MASTER"
    case achievementMountMaster = "ACHIEVEMENT_MOUNT_MASTER"
    case achievementTriadBingo = "ACHIEVEMENT_TRIAD_BINGO"
    case achievementGuildJoined = "GUILD_JOINED_ACHIEVEMENT"
    case achievementChallengeJoined = "CHALLENGE_JOINED_ACHIEVEMENT"
    case achievementInvitedFriend = "INVITED_FRIEND_ACHIEVEMENT"
    case achievementGeneric = "ACHIEVEMENT"
    case achievementOnboardingComplete = "ONBOARDING_COMPLETE"
    
    case achievementAllYourBase = "ACHIEVEMENT_ALL_YOUR_BASE"
    case achievementBackToBasics = "ACHIEVEMENT_BACK_TO_BASICS"
    case achievementJustAddWater = "ACHIEVEMENT_JUST_ADD_WATER"
    case achievementLostMasterclasser = "ACHIEVEMENT_LOST_MASTERCLASSER"
    case achievementMindOverMatter = "ACHIEVEMENT_MIND_OVER_MATTER"
    case achievementDustDevil = "ACHIEVEMENT_DUST_DEVIL"
    case achievementAridAuthority = "ACHIEVEMENT_ARID_AUTHORITY"
    case achievementMonsterMagus = "ACHIEVEMENT_MONSTER_MAGUS"
    case achievementUndeadUndertaker = "ACHIEVEMENT_UNDEAD_UNDERTAKER"
    case achievementPrimedForPainting = "ACHIEVEMENT_PRIMED_FOR_PAINTING"
    case achievementPearlyPro = "ACHIEVEMENT_PEARLY_PRO"
    case achievementTickledPink = "ACHIEVEMENT_TICKLED_PINK"
    case achievementRosyOutlook = "ACHIEVEMENT_ROSY_OUTLOOK"
    case achievementBugBonanza = "ACHIEVEMENT_BUG_BONANZA"
    case achievementBareNecessities = "ACHIEVEMENT_BARE_NECESSITIES"
    case achievementFreshwaterFriends = "ACHIEVEMENT_FRESHWATER_FRIENDS"
    case achievementGoodAsGold = "ACHIEVEMENT_GOOD_AS_GOLD"
    case achievementAllThatGlitters = "ACHIEVEMENT_ALL_THAT_GLITTERS"
    case achievementBoneCollector = "ACHIEVEMENT_BONE_COLLECTOR"
    case achievementSkeletonCrew = "ACHIEVEMENT_SKELETON_CREW"
    
    case loginIncentive = "LOGIN_INCENTIVE"

    case firstDrop = "FIRST_DROPS"

    public var priority: Int {
        switch self {
        case .newStuff:
            return 1
        case .groupInvite:
            return 2
        case .questInvite:
            return 3
        case .unallocatedStatsPoints:
            return 4
        case .newMysteryItem:
            return 5
        case .newChatMessage:
            return 6
        default:
            return 100
        }
    }
}
// swiftlint:enable inclusive_language
