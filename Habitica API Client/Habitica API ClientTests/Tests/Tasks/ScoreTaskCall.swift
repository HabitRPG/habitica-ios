//
//  ScoreTaskCall.swift
//  Habitica API ClientTests
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Quick
import Nimble
import ReactiveSwift
import Habitica_Models
@testable import Habitica_API_Client

class ScoreTaskCallSpec: QuickSpec {
    var stubHolder: StubHolderProtocol?
    
    var task: TaskProtocol?
    
    override func spec() {
        HabiticaServerConfig.current = HabiticaServerConfig.stub
        describe("Score task test") {
            beforeEach {
                self.task = APITask()
                self.stubHolder = StubHolder(stubData: self.dataFor(fileName: "taskResponse", fileExtension: "json"))
            }
            context("Success") {
                it("Should score task up") {
                    // swiftlint:disable:next force_unwrapping
                    let call = ScoreTaskCall(task: self.task!, direction: .up, stubHolder: self.stubHolder)
                    
                    waitUntil(timeout: 0.5) { done in
                        call.objectSignal.observeValues({ (tasks) in
                            expect(tasks).toNot(beNil())
                            done()
                        })
                        call.fire()
                    }
                }
            }
            context("Success") {
                it("Should score task down") {
                    // swiftlint:disable:next force_unwrapping
                    let call = ScoreTaskCall(task: self.task!, direction: .down, stubHolder: self.stubHolder)
                    
                    waitUntil(timeout: 0.5) { done in
                        call.objectSignal.observeValues({ (response) in
                            expect(response).toNot(beNil())
                            done()
                        })
                        call.fire()
                    }
                }
            }
        }
    }
}
