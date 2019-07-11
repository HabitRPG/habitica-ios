//
//  RetrieveUserCallSpec.swift
//  Habitica API ClientTests
//
//  Created by Phillip Thelen on 12.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Quick
import Nimble
import ReactiveSwift
@testable import Habitica_API_Client

class RetrieveUserCallSpec: QuickSpec {
    var stubHolder: StubHolderProtocol?
    
    override func spec() {
        HabiticaServerConfig.current = HabiticaServerConfig.stub
        describe("Retrieve user tests") {
            beforeEach {
                self.stubHolder = StubHolder(stubData: self.dataFor(fileName: "user", fileExtension: "json"))
            }
            context("Success") {
                it("should get user") {
                    let call = RetrieveUserCall(stubHolder: self.stubHolder)
                    
                    waitUntil(timeout: 0.5) { done in
                        call.objectSignal.observeValues({ (user) in
                            expect(user).toNot(beNil())
                            expect(user?.profile).toNot(beNil())
                            expect(user?.preferences).toNot(beNil())
                            expect(user?.flags).toNot(beNil())
                            expect(user?.items).toNot(beNil())
                            expect(user?.items?.gear).toNot(beNil())
                            expect(user?.contributor).toNot(beNil())
                            expect(user?.stats).toNot(beNil())
                            expect(user?.stats?.buffs).toNot(beNil())
                            expect(user?.tasksOrder.count).toNot(0)
                            expect(user?.tags.count).toNot(0)
                            done()
                        })
                        call.fire()
                    }
                }
            }
        }
    }
}
