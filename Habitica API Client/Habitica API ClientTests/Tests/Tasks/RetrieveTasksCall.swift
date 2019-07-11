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
import ReactiveSwift
@testable import Habitica_API_Client

class RetrieveTasksCallSpec: QuickSpec {
    var stubHolder: StubHolderProtocol?
    
    override func spec() {
        HabiticaServerConfig.current = HabiticaServerConfig.stub
        describe("Retrieve tasks test") {
            beforeEach {
                self.stubHolder = StubHolder(stubData: self.dataFor(fileName: "tasks", fileExtension: "json"))
            }
            context("Success") {
                it("Should get tasks") {
                    let call = RetrieveTasksCall(stubHolder: self.stubHolder)
                    
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
