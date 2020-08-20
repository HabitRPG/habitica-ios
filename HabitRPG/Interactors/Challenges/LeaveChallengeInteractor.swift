//
//  LeaveChallengeInteractor.swift
//  Habitica
//
//  Created by Phillip Thelen on 06/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import ReactiveSwift
import Habitica_Models

class LeaveChallengeInteractor: Interactor<ChallengeProtocol, Bool> {
    weak var presentingController: UIViewController?

    private let socialRepository = SocialRepository()
    private let taskRepository = TaskRepository()

    init(presentingViewController: UIViewController) {
        self.presentingController = presentingViewController
    }

    override func configure(signal: Signal<ChallengeProtocol, NSError>) -> Signal<Bool, NSError> {
        return signal.flatMap(.concat) {[weak self] challenge -> Signal<(Bool, Bool, ChallengeProtocol), NSError> in
            let (signal, observer) = Signal<(Bool, Bool, ChallengeProtocol), NSError>.pipe()
            self?.createConfirmationAlert(challenge: challenge, observer: observer)
            return signal
            }.filter { (shouldLeave, _, _) in
                return shouldLeave
            }.flatMap(.concat) {[weak self] (_, keepTasks, challenge) -> Signal<Bool, NSError> in
                let challengeID = challenge.id ?? ""
                return self?.socialRepository.leaveChallenge(challengeID: challengeID, keepTasks: keepTasks)
                    .flatMap(.latest, { _ in
                        return (self?.taskRepository.retrieveTasks() ?? Signal.empty)
                    })
                    .map({ (_) in
                        return false
                    })
                    .promoteError() ?? Signal.empty
        }
    }

    private func createConfirmationAlert(challenge: ChallengeProtocol, observer: Signal<(Bool, Bool, ChallengeProtocol), NSError>.Observer) {
        let alert = HabiticaAlertController(title: L10n.leaveChallengeTitle,
                                      message: L10n.leaveChallengePrompt)
        alert.addAction(title: L10n.keepTasks, handler: { (_) in
            observer.send(value: (true, true, challenge))
        })
        alert.addAction(title: L10n.deleteTasks, style: .destructive, handler: { (_) in
            observer.send(value: (true, false, challenge))
        })
        alert.setCloseAction(title: L10n.cancel, handler: {
            observer.send(value: (false, false, challenge))
        })
        alert.show()
    }
}
