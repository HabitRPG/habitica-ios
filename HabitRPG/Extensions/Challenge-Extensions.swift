//
//  Challenge-Extensions.swift
//  Habitica
//
//  Created by Elliot Schrock on 1/30/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

extension Challenge {
    
    static func shouldBePublishable(challenge: Challenge?) -> Bool {
        if !isOwner(of: challenge) {
            return false
        } else {
            return challenge?.hasTasks() ?? false
        }
    }
    
    static func shouldBeUnpublishable(challenge: Challenge?) -> Bool {
        if !isOwner(of: challenge) {
            return false
        } else {
            return !(challenge?.hasTasks() ?? false)
        }
    }
    
    static func shouldEnable(challenge: Challenge?) -> Bool {
        if !isOwner(of: challenge) {
            return true
        } else {
            return challenge?.hasTasks() ?? false
        }
    }
    
    static func isOwner(of challenge: Challenge?) -> Bool {
        return false //challenge?.leaderId == HRPGManager.shared().user.id
    }
    
    static func isPublished(_ challenge: Challenge?) -> Bool {
        return true
    }
    
    static func isEndable(_ challenge: Challenge?) -> Bool {
        return isOwner(of: challenge) && isPublished(challenge)
    }
    
    static func isJoinable(challenge: Challenge?) -> Bool {
        return challenge?.user == nil
    }
    
    func hasTasks() -> Bool {
        let hasDailies = self.dailies?.count ?? 0 > 0
        let hasHabits = self.habits?.count ?? 0 > 0
        let hasTodos = self.todos?.count ?? 0 > 0
        let hasRewards = self.rewards?.count ?? 0 > 0
        
        return hasDailies || hasHabits || hasTodos || hasRewards
    }
    
}
