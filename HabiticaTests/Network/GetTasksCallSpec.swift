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
@testable import Habitica

class GetTasksCallSpec: QuickSpec {
    override func spec() {
        describe("Get tasks test") {
            context("success") {
                it("should get tasks") {
                    let call = GetTasksCall(configuration: HRPGServerConfig.stub)
                    
                    waitUntil(timeout: 0.5) { done in
                        call.fetchTasks().startWithResult({ (result) in
                            switch result {
                            case let .success(tasks):
                                expect(tasks).toNot(beNil())
                                break
                            default:
                                expect(false).to(beTrue())
                                break
                            }
                            done()
                        })
                    }
                }
            }
        }
    }
}

