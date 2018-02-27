//
//  GetUserCallSpec.swift
//  HabiticaTests
//
//  Created by Elliot Schrock on 9/30/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import Quick
import Nimble
import FunkyNetwork
import Result
import ReactiveSwift
@testable import Habitica

class GetUserCallSpec: QuickSpec {
    override func spec() {
        describe("Get user test") {
            context("success") {
                it("should get user") {
                    let call = GetUserCall(configuration: HRPGServerConfig.stub)
                    
                    waitUntil(timeout: 0.5) { done in
                        call.userSignal.observeValues({ user in
                            expect(user).toNot(beNil())
                            done()
                        })
                        call.fire()
                    }
                }
            }
        }
    }
}
