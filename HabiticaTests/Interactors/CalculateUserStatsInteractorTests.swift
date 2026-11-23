//
//  CalculateUserStatsInteractorTests.swift
//  HabiticaTests
//

import XCTest
@testable import Habitica
import Habitica_Models

private class Stats: StatsProtocol {
    var health: Float = 50
    var maxHealth: Float = 50
    var mana: Float = 0
    var maxMana: Float = 0
    var experience: Float = 0
    var toNextLevel: Float = 0
    var level: Int = 1
    var points: Int = 0
    var habitClass: String?
    var gold: Float = 0
    var buffs: BuffProtocol?
    var strength: Int = 0
    var intelligence: Int = 0
    var constitution: Int = 0
    var perception: Int = 0
    var isValid: Bool = true
    var isManaged: Bool = false
}

private class Buff: BuffProtocol {
    var shinySeed = false
    var snowball = false
    var seafoam = false
    var streaks = false
    var stealth = 0
    var spookySparkles = false
    var strength = 0
    var intelligence = 0
    var constitution = 0
    var perception = 0
    var isValid: Bool = true
    var isManaged: Bool = false
}

private class Gear: GearProtocol {
    var key: String?
    var text: String?
    var notes: String?
    var value: Float = 0
    var type: String?
    var set: String?
    var gearSet: String?
    var habitClass: String?
    var specialClass: String?
    var index: String?
    var twoHanded = false
    var strength: Int
    var intelligence: Int
    var perception: Int
    var constitution: Int
    var released = true

    init(habitClass: String? = nil, specialClass: String? = nil, strength: Int = 0, intelligence: Int = 0, perception: Int = 0, constitution: Int = 0) {
        self.habitClass = habitClass
        self.specialClass = specialClass
        self.strength = strength
        self.intelligence = intelligence
        self.perception = perception
        self.constitution = constitution
    }
}

class CalculateUserStatsInteractorTests: XCTestCase {

    private func calculate(_ stats: StatsProtocol, _ gear: [GearProtocol] = []) -> CalculatedUserStats? {
        let interactor = CalculateUserStatsInteractor()
        var result: CalculatedUserStats?
        interactor.reactive.observeResult { result = try? $0.get() }
        interactor.run(with: (stats, gear))
        return result
    }

    func testLevelBonusIsHalfLevelCappedAt50() {
        let stats = Stats()
        for (level, expected) in [(0, 0), (1, 0), (2, 1), (3, 1), (99, 49), (100, 50), (101, 50), (1000, 50)] {
            stats.level = level
            XCTAssertEqual(calculate(stats)?.levelStat, expected, "level \(level)")
        }
    }

    func testTotalsSumAllSources() throws {
        let stats = Stats()
        stats.level = 20
        stats.strength = 3
        stats.intelligence = 4
        stats.constitution = 5
        stats.perception = 6
        let buff = Buff()
        buff.strength = 1
        buff.perception = 2
        stats.buffs = buff
        let result = try XCTUnwrap(calculate(stats, [Gear(strength: 2, intelligence: 1)]))
        XCTAssertEqual(result.totalStrength, 10 + 3 + 1 + 2)
        XCTAssertEqual(result.totalIntelligence, 10 + 4 + 1)
        XCTAssertEqual(result.totalConstitution, 10 + 5)
        XCTAssertEqual(result.totalPerception, 10 + 6 + 2)
    }

    func testNegativeBuffsReduceTotals() throws {
        let stats = Stats()
        let buff = Buff()
        buff.strength = -5
        stats.buffs = buff
        let result = try XCTUnwrap(calculate(stats))
        XCTAssertEqual(result.buffStrength, -5)
        XCTAssertEqual(result.totalStrength, -5)
    }

    func testGearOfOtherClassGivesNoBonus() throws {
        let stats = Stats()
        stats.habitClass = "warrior"
        let result = try XCTUnwrap(calculate(stats, [Gear(habitClass: "wizard", intelligence: 8, perception: 4)]))
        XCTAssertEqual(result.gearIntelligence, 8)
        XCTAssertEqual(result.gearBonusIntelligence, 0)
        XCTAssertEqual(result.gearBonusPerception, 0)
        XCTAssertEqual(result.gearWithBonusIntelligence, 8)
    }

    func testMatchingClassGearGivesBonusOnClassStatsOnly() throws {
        let stats = Stats()
        stats.habitClass = "rogue"
        let gear = Gear(habitClass: "rogue", strength: 2, intelligence: 3, perception: 4, constitution: 5)
        let result = try XCTUnwrap(calculate(stats, [gear]))
        XCTAssertEqual(result.gearBonusStrength, 2)
        XCTAssertEqual(result.gearBonusPerception, 4)
        XCTAssertEqual(result.gearBonusIntelligence, 0)
        XCTAssertEqual(result.gearBonusConstitution, 0)
        XCTAssertEqual(result.gearWithBonusStrength, 4)
    }

    func testEachClassBonusStats() throws {
        let gear = Gear(strength: 1, intelligence: 1, perception: 1, constitution: 1)
        let expected: [String: (str: Int, int: Int, con: Int, per: Int)] = [
            "warrior": (1, 0, 1, 0),
            "wizard": (0, 1, 0, 1),
            "healer": (0, 1, 1, 0),
            "rogue": (1, 0, 0, 1)
        ]
        for (habitClass, bonus) in expected {
            let stats = Stats()
            stats.habitClass = habitClass
            gear.habitClass = habitClass
            let result = try XCTUnwrap(calculate(stats, [gear]))
            XCTAssertEqual(result.gearBonusStrength, bonus.str, habitClass)
            XCTAssertEqual(result.gearBonusIntelligence, bonus.int, habitClass)
            XCTAssertEqual(result.gearBonusConstitution, bonus.con, habitClass)
            XCTAssertEqual(result.gearBonusPerception, bonus.per, habitClass)
        }
    }

    func testSpecialGearUsesSpecialClass() throws {
        let stats = Stats()
        stats.habitClass = "healer"
        let special = Gear(habitClass: "special", specialClass: "healer", intelligence: 2, constitution: 3)
        let result = try XCTUnwrap(calculate(stats, [special]))
        XCTAssertEqual(result.gearBonusIntelligence, 2)
        XCTAssertEqual(result.gearBonusConstitution, 3)
    }

    func testEmptyGearClassFallsBackToSpecialClass() throws {
        let stats = Stats()
        stats.habitClass = "wizard"
        let gear = Gear(habitClass: "", specialClass: "wizard", intelligence: 2, perception: 3)
        let result = try XCTUnwrap(calculate(stats, [gear]))
        XCTAssertEqual(result.gearBonusIntelligence, 2)
        XCTAssertEqual(result.gearBonusPerception, 3)
    }

    func testUserWithoutClassGetsNoBonusFromClasslessGear() throws {
        // nil == nil matches, but there is no class to give a bonus for
        let stats = Stats()
        let result = try XCTUnwrap(calculate(stats, [Gear(strength: 5)]))
        XCTAssertEqual(result.gearStrength, 5)
        XCTAssertEqual(result.gearBonusStrength, 0)
    }

    func testGearSumsAcrossItems() throws {
        let stats = Stats()
        stats.habitClass = "warrior"
        let gear = [
            Gear(habitClass: "warrior", strength: 3),
            Gear(habitClass: "wizard", strength: 4),
            Gear(habitClass: "special", specialClass: "warrior", constitution: 2)
        ]
        let result = try XCTUnwrap(calculate(stats, gear))
        XCTAssertEqual(result.gearStrength, 7)
        XCTAssertEqual(result.gearBonusStrength, 3)
        XCTAssertEqual(result.gearConstitution, 2)
        XCTAssertEqual(result.gearBonusConstitution, 2)
        XCTAssertEqual(result.totalStrength, 10)
    }

    func testRecalculateTotals() {
        var stats = CalculatedUserStats()
        stats.levelStat = 1
        stats.buffPerception = 2
        stats.allocatedPerception = 3
        stats.gearPerception = 4
        stats.gearBonusPerception = 5
        stats.recalculateTotals()
        XCTAssertEqual(stats.totalPerception, 15)
        XCTAssertEqual(stats.totalStrength, 1)
    }
}
