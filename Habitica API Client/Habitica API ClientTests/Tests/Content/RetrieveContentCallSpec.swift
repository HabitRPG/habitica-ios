//
//  RetrieveContentCall.swift
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

class RetrieveContentCallSpec: QuickSpec {
    var stubHolder: StubHolderProtocol?
    
    // swiftlint:disable:next function_body_length
    override func spec() {
        HabiticaServerConfig.current = HabiticaServerConfig.stub
        describe("Retrieve content tests") {
            beforeEach {
                self.stubHolder = StubHolder(stubData: self.dataFor(fileName: "content", fileExtension: "json"))
            }
            context("Success") {
                it("should get content") {
                    let call = RetrieveContentCall(stubHolder: self.stubHolder)
                    
                    waitUntil(timeout: 0.5) { done in
                        call.objectSignal.observeValues({ (content) in
                            expect(content).toNot(beNil())
                            expect(content?.food?.count) == 31
                            content?.food?.forEach({ food in
                                expect(food.key).toNot(beNil())
                                expect(food.text).toNot(beNil())
                            })
                            expect(content?.eggs?.count) == 54
                            content?.eggs?.forEach({ egg in
                                expect(egg.key).toNot(beNil())
                                expect(egg.text).toNot(beNil())
                            })
                            expect(content?.hatchingPotions?.count) == 23
                            content?.hatchingPotions?.forEach({ hatchingPotion in
                                expect(hatchingPotion.key).toNot(beNil())
                                expect(hatchingPotion.text).toNot(beNil())
                            })
                            expect(content?.gear?.count) == 728
                            content?.gear?.forEach({ gear in
                                expect(gear.key).toNot(beNil())
                                expect(gear.text).toNot(beNil())
                            })
                            expect(content?.skills?.count) == 32
                            content?.skills?.forEach({ skill in
                                expect(skill.key).toNot(beNil())
                                expect(skill.text).toNot(beNil())
                                expect(skill.habitClass).toNot(beEmpty())
                            })
                            expect(content?.quests?.count) == 86
                            content?.quests?.forEach({ quest in
                                expect(quest.key).toNot(beNil())
                                expect(quest.text).toNot(beNil())
                                expect(quest.boss == nil).toNot(equal(quest.collect == nil))
                            })
                            expect(content?.faq?.count) == 13
                            content?.faq?.forEach({ entry in
                                expect(entry.index).toNot(beNil())
                                expect(entry.question).toNot(beNil())
                            })
                            done()
                        })
                        call.fire()
                    }
                }
            }
        }
    }
}
