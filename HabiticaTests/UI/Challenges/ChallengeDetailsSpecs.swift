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

class ChallengeDetailsViewModelSpec: QuickSpec {
    override func spec() {
        describe("challenge details view model") {
            context("button cell") {
                it("allows joining") {
                    let challenge = Challenge()
                    let vm = ChallengeDetailViewModel(challenge: challenge)
                    
                    waitUntil(action: { (done) in
                        vm.joinLeaveStyleProvider.buttonStateSignal.observeValues({ (state) in
                            expect(state).to(equal(ChallengeButtonState.join))
                            done()
                        })
                        vm.setChallenge(challenge)
                    })
                }
                
                it("allows leaving") {
                    let challenge = Challenge()
                    challenge.user = User()
                    let vm = ChallengeDetailViewModel(challenge: challenge)
                    
                    waitUntil(action: { (done) in
                        vm.joinLeaveStyleProvider.buttonStateSignal.observeValues({ (state) in
                            expect(state).to(equal(ChallengeButtonState.leave))
                            done()
                        })
                        vm.setChallenge(challenge)
                    })
                }
                
                context("when has tasks") {
                    it("allows publishing") {
                        let challenge = Challenge()
                        challenge.dailies = [ChallengeTask()]
                        let vm = ChallengeDetailViewModel(challenge: challenge)
                        
                        waitUntil(action: { (done) in
                            vm.publishStyleProvider.enabledSignal.observeValues({ (isEnabled) in
                                expect(isEnabled).to(beTrue())
                                done()
                            })
                            vm.setChallenge(challenge)
                        })
                    }
                }
                
                context("when no tasks") {
                    it("doesn't allow publishing") {
                        let challenge = Challenge()
                        let vm = ChallengeDetailViewModel(challenge: challenge)
                        
                        waitUntil(action: { (done) in
                            vm.publishStyleProvider.enabledSignal.observeValues({ (isEnabled) in
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
