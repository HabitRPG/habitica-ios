//
//  ChallengeDetailsSpecs.swift
//  HabiticaTests
//
//  Created by Elliot Schrock on 10/28/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Habitica

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("challenge details view model") {
            context("button cell") {
                it("allows joining") {
                    let vm = ChallengeDetailViewModel()
                    let challenge = Challenge()
                    
                    waitUntil(action: { (done) in
                        vm.buttonCellStateSignal.observeValues({ (state) in
                            expect(state).to(equal(ChallengeButtonCellState.join))
                            done()
                        })
                        vm.setChallenge(challenge)
                    })
                }
                
                it("allows leaving") {
                    let vm = ChallengeDetailViewModel()
                    let challenge = Challenge()
                    challenge.user = User()
                    
                    waitUntil(action: { (done) in
                        vm.buttonCellStateSignal.observeValues({ (state) in
                            expect(state).to(equal(ChallengeButtonCellState.leave))
                            done()
                        })
                        vm.setChallenge(challenge)
                    })
                }
                
                context("when has tasks") {
                    it("allows publishing") {
                        let vm = ChallengeDetailViewModel()
                        let challenge = Challenge()
                        challenge.dailies = [ChallengeTask()]
                        
                        waitUntil(action: { (done) in
                            vm.enabledSignal.observeValues({ (isEnabled) in
                                expect(isEnabled).to(beTrue())
                                done()
                            })
                            vm.setChallenge(challenge)
                        })
                    }
                }
                
                context("when no tasks") {
                    it("doesn't allow publishing") {
                        let vm = ChallengeDetailViewModel()
                        let challenge = Challenge()
                        
                        waitUntil(action: { (done) in
                            vm.enabledSignal.observeValues({ (isEnabled) in
                                expect(isEnabled).to(beFalse())
                                done()
                            })
                            vm.setChallenge(challenge)
                        })
                    }
                }
            }
            
            context("creator cell") {
                
            }
        }
    }
}
