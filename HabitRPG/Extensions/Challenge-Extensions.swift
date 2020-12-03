//
//  Challenge-Extensions.swift
//  Habitica
//
//  Created by Elliot Schrock on 1/30/18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

extension ChallengeProtocol {
    
    func shouldBePublishable(_ userID: String?) -> Bool {
        if !isOwner(userID) {
            return false
        } else {
            return hasTasks()
        }
    }
    
    func shouldBeUnpublishable(_ userID: String?) -> Bool {
        if !isOwner(userID) {
            return false
        } else {
            return !hasTasks()
        }
    }
    
    func shouldEnable(_ userID: String?) -> Bool {
        if !isOwner(userID) {
            return true
        } else {
            return hasTasks()
        }
    }
    
    func isOwner(_ userID: String?) -> Bool {
        return leaderID == userID
    }
    
    func isPublished() -> Bool {
        return true
    }
    
    func isEndable(_ userID: String?) -> Bool {
        return isOwner(userID) && isPublished()
    }
    
    func hasTasks() -> Bool {
        let hasDailies = dailies.isEmpty == false
        let hasHabits = habits.isEmpty == false
        let hasTodos = todos.isEmpty == false
        let hasRewards = rewards.isEmpty == false
        
        return hasDailies || hasHabits || hasTodos || hasRewards
    }
    
}
