//
//  JoinChallengeInteractor.swift
//  Habitica
//
//  Created by Phillip Thelen on 06/03/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit
import ReactiveSwift

class JoinChallengeInteractor: Interactor<Challenge, Bool> {
    let sharedManager: HRPGManager

    init(_ sharedManager: HRPGManager) {
        self.sharedManager = sharedManager
    }

    override func configure(signal: Signal<Challenge, NSError>) -> Signal<Bool, NSError> {
        return signal.flatMap(.concat) {[weak self] (challenge) -> Signal<Bool, NSError> in
            let (signal, observer) = Signal<Bool, NSError>.pipe()
            self?.sharedManager.join(challenge, onSuccess: {
                observer.send(value: true)
            }, onError: {
                observer.send(error: NSError())
            })
            return signal
        }
    }
}
