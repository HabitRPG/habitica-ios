//
//  CalculateUserStatsInteractor.swift
//  Habitica
//
//  Created by Phillip Thelen on 07.06.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

struct CalculatedUserStats {
    var totalStrength: Int = 0
    var totalIntelligence: Int = 0
    var totalConstitution: Int = 0
    var totalPerception: Int = 0
    
    var levelStat: Int = 0
    
    var buffStrength: Int = 0
    var buffIntelligence: Int = 0
    var buffConstitution: Int = 0
    var buffPerception: Int = 0
    
    var allocatedStrength: Int = 0
    var allocatedIntelligence: Int = 0
    var allocatedConstitution: Int = 0
    var allocatedPerception: Int = 0
    
    var gearStrength: Int = 0
    var gearIntelligence: Int = 0
    var gearConstitution: Int = 0
    var gearPerception: Int = 0

    var gearBonusStrength: Int = 0
    var gearBonusIntelligence: Int = 0
    var gearBonusConstitution: Int = 0
    var gearBonusPerception: Int = 0
    
    var gearWithBonusStrength: Int = 0
    var gearWithBonusIntelligence: Int = 0
    var gearWithBonusConstitution: Int = 0
    var gearWithBonusPerception: Int = 0
    
    mutating func recalculateTotals() {
        totalStrength = levelStat + buffStrength + allocatedStrength + gearStrength + gearBonusStrength
        totalIntelligence = levelStat + buffIntelligence + allocatedIntelligence + gearIntelligence + gearBonusIntelligence
        totalConstitution = levelStat + buffConstitution + allocatedConstitution + gearConstitution + gearBonusConstitution
        totalPerception = levelStat + buffPerception + allocatedPerception + gearPerception + gearBonusPerception
    }
}

class CalculateUserStatsInteractor: Interactor<(StatsProtocol, [GearProtocol]), CalculatedUserStats> {
    
    private let userRepository = UserRepository()

    override func configure(signal: Signal<(StatsProtocol, [GearProtocol]), NSError>) -> Signal<CalculatedUserStats, NSError> {
        return signal.map({ (userStats, gear) in
            var stats = CalculatedUserStats()
            stats.levelStat = min(userStats.level / 2, 100)
            
            stats.allocatedStrength = userStats.strength
            stats.allocatedIntelligence = userStats.intelligence
            stats.allocatedConstitution = userStats.constitution
            stats.allocatedPerception = userStats.perception
            
            if let buff = userStats.buffs {
                stats.buffStrength = buff.strength
                stats.buffIntelligence = buff.intelligence
                stats.buffConstitution = buff.constitution
                stats.buffPerception = buff.perception
            }
            
            var gearBonusStrength = 0.0
            var gearBonusIntelligence = 0.0
            var gearBonusConstitution = 0.0
            var gearBonusPerception = 0.0
            
            for row in gear {
                stats.gearStrength += row.strength
                stats.gearIntelligence += row.intelligence
                stats.gearConstitution += row.constitution
                stats.gearPerception += row.perception
                
                var itemClass = row.habitClass
                let itemSpecialClass = row.specialClass
                let classBonus = 0.5
                let userClassMatchesGearClass = itemClass == userStats.habitClass
                let userClassMatchesGearSpecialClass = itemSpecialClass == userStats.habitClass
                
                if !userClassMatchesGearClass && !userClassMatchesGearSpecialClass {
                    continue
                }
                
                if itemClass?.isEmpty ?? false || itemClass == "special" {
                    itemClass = itemSpecialClass
                }
                
                switch itemClass {
                case "rogue"?:
                    gearBonusStrength += Double(row.strength) * classBonus
                    gearBonusPerception += Double(row.perception) * classBonus
                case "healer"?:
                    gearBonusConstitution += Double(row.constitution) * classBonus
                    gearBonusIntelligence += Double(row.intelligence) * classBonus
                case "warrior"?:
                    gearBonusStrength += Double(row.strength) * classBonus
                    gearBonusConstitution += Double(row.constitution) * classBonus
                case "wizard"?:
                    gearBonusIntelligence += Double(row.intelligence) * classBonus
                    gearBonusPerception += Double(row.perception) * classBonus
                default:
                    break
                }
            }
            
            stats.gearBonusStrength = Int(gearBonusStrength)
            stats.gearBonusIntelligence = Int(gearBonusIntelligence)
            stats.gearBonusConstitution = Int(gearBonusConstitution)
            stats.gearBonusPerception = Int(gearBonusPerception)
            
            stats.gearWithBonusStrength = stats.gearStrength + stats.gearBonusStrength
            stats.gearWithBonusIntelligence = stats.gearIntelligence + stats.gearBonusIntelligence
            stats.gearWithBonusConstitution = stats.gearConstitution + stats.gearBonusConstitution
            stats.gearWithBonusPerception = stats.gearPerception + stats.gearBonusPerception
            
            stats.recalculateTotals()
            return stats
        })
    }
}
