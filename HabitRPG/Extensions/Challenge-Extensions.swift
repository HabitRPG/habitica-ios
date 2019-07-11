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
    
    func shouldBePublishable() -> Bool {
        if !isOwner() {
            return false
        } else {
            return hasTasks()
        }
    }
    
    func shouldBeUnpublishable() -> Bool {
        if !isOwner() {
            return false
        } else {
            return !hasTasks()
        }
    }
    
    func shouldEnable() -> Bool {
        if !isOwner() {
            return true
        } else {
            return hasTasks()
        }
    }
    
    func isOwner() -> Bool {
        return false
    }
    
    func isPublished() -> Bool {
        return true
    }
    
    func isEndable() -> Bool {
        return isOwner() && isPublished()
    }
    
    func hasTasks() -> Bool {
        let hasDailies = dailies.isEmpty == false
        let hasHabits = habits.isEmpty == false
        let hasTodos = todos.isEmpty == false
        let hasRewards = rewards.isEmpty == false
        
        return hasDailies || hasHabits || hasTodos || hasRewards
    }
    
}
