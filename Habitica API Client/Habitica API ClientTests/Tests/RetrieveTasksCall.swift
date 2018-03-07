//
//  GetTasksCallSpec.swift
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
@testable import Habitica_API_Client

class GetTasksCallSpec: QuickSpec {
    override func spec() {
        describe("Get tasks test") {
            context("success") {
                it("should get tasks") {
                    let call = RetrieveTasksCall(configuration: HRPGServerConfig.stub)
                    
                    waitUntil(timeout: 0.5) { done in
                        call.arraySignal.observeValues({ (tasks) in
                            expect(tasks).toNot(beNil())
                            done()
                        })
                        call.fire()
                    }
                }
            }
        }
    }
}
