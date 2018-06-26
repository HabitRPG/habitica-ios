//
//  JoinChallengeInteractor.swift
//  Habitica
//
//  Created by Phillip Thelen on 06/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import ReactiveSwift
import Habitica_Models

class JoinChallengeInteractor: Interactor<ChallengeProtocol, Bool> {

    private let socialRepository = SocialRepository()
    
    override func configure(signal: Signal<ChallengeProtocol, NSError>) -> Signal<Bool, NSError> {
        return signal.flatMap(.concat) {[weak self] (challenge) -> Signal<Bool, NSError> in
            let challengeID = challenge.id ?? ""
            return self?.socialRepository.joinChallenge(challengeID: challengeID)
                .map({ (_) in
                    return true
                })
                .promoteError() ?? Signal.empty
        }
    }
}
