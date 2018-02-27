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

    var challenge = Challenge()

    override func spec() {
        HRPGManager.setupTestManager()
        describe("challenge details view model") {
            beforeEach {
                self.challenge = NSEntityDescription.insertNewObject(forEntityName: "Challenge", into: HRPGManager.shared().getManagedObjectContext()) as! Challenge
            }
            context("button cell") {
                it("allows joining") {
                    let vm = ChallengeDetailViewModel(challenge: self.challenge)
                    
                    waitUntil(action: { (done) in
                        vm.joinLeaveStyleProvider.buttonStateSignal.observeValues({ (state) in
                            expect(state).to(equal(ChallengeButtonState.join))
                            done()
                        })
                        vm.setChallenge(self.challenge)
                        vm.joinLeaveStyleProvider.triggerStyle()
                    })
                }
                
                it("allows leaving") {
                    self.challenge.user = NSEntityDescription.insertNewObject(forEntityName: "User", into: HRPGManager.shared().getManagedObjectContext()) as! User
                    let vm = ChallengeDetailViewModel(challenge: self.challenge)
                    
                    waitUntil(action: { (done) in
                        vm.joinLeaveStyleProvider.buttonStateSignal.observeValues({ (state) in
                            expect(state).to(equal(ChallengeButtonState.leave))
                            done()
                        })
                        vm.setChallenge(self.challenge)
                        vm.joinLeaveStyleProvider.triggerStyle()
                    })
                }
                //TODO: Re enable once creator mode is in
                /*
                context("when has tasks") {
                    it("allows publishing") {
                        self.challenge.dailies = [ NSEntityDescription.insertNewObject(forEntityName: "ChallengeTask", into: HRPGManager.shared().getManagedObjectContext()) as! ChallengeTask]
                        let vm = ChallengeDetailViewModel(challenge: self.challenge)
                        
                        waitUntil(action: { (done) in
                            vm.publishStyleProvider.enabledSignal.observeValues({ (isEnabled) in
                                expect(isEnabled).to(beTrue())
                                done()
                            })
                            vm.setChallenge(self.challenge)
                            vm.joinLeaveStyleProvider.triggerStyle()
                        })
                    }
                }
                
                context("when no tasks") {
                    it("doesn't allow publishing") {
                        let vm = ChallengeDetailViewModel(challenge: self.challenge)
                        
                        waitUntil(action: { (done) in
                            vm.publishStyleProvider.enabledSignal.observeValues({ (isEnabled) in
                                expect(isEnabled).to(beFalse())
                                done()
                            })
                            vm.setChallenge(self.challenge)
                            vm.joinLeaveStyleProvider.triggerStyle()
                        })
                    }
                }
                */
            }
            
            context("creator cell") {
                
            }
        }
    }
}
