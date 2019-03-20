//
//  UserProtocolTests.swift
//  Habitica ModelsTests
//
//  Created by Phillip Thelen on 28.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Habitica_Models

class UserProtocolSpec: QuickSpec {
    
    override func spec() {
        describe("Computed variables for UserProtocol") {
            context("gemCount") {
                it("should return no gems") {
                    let user = TestUser()
                    user.balance = 0
                    expect(user.gemCount).to(be(0))
                }
                it("should return 4 gems") {
                    let user = TestUser()
                    user.balance = 1
                    expect(user.gemCount).to(be(4))
                }
                it("should return 1 gems") {
                    let user = TestUser()
                    user.balance = 0.25
                    expect(user.gemCount).to(be(1))
                }
            }
            context("canUseSkills") {
                it("should return false for disabled classes") {
                    let user = TestUser()
                    user.preferences = TestPreferences()
                    user.preferences?.disableClasses = true
                    expect(user.canUseSkills).to(beFalse())
                }
                it("should return false for under level 10") {
                    let user = TestUser()
                    user.stats = TestStats()
                    user.stats?.level = 9
                    expect(user.canUseSkills).to(beFalse())
                }
                it("should return false for unselected class") {
                    let user = TestUser()
                    user.flags = TestFlags()
                    user.flags?.classSelected = false
                    expect(user.canUseSkills).to(beFalse())
                }
                it("should return true") {
                    let user = TestUser()
                    user.preferences = TestPreferences()
                    user.preferences?.disableClasses = false
                    user.flags = TestFlags()
                    user.flags?.classSelected = true
                    user.stats = TestStats()
                    user.stats?.level = 11
                    expect(user.canUseSkills).to(beTrue())
                }
            }
        }
    }
}
