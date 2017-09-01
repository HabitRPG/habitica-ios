//
//  LeaveChallengeInteractor.swift
//  Habitica
//
//  Created by Phillip Thelen on 06/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import ReactiveSwift

class LeaveChallengeInteractor: Interactor<Challenge, Bool> {
    weak var presentingController: UIViewController?

    init(presentingViewController: UIViewController) {
        self.presentingController = presentingViewController
    }

    override func configure(signal: Signal<Challenge, NSError>) -> Signal<Bool, NSError> {
        return signal.flatMap(.concat) {[weak self] challenge -> Signal<(Bool, Bool, Challenge), NSError> in
            let (signal, observer) = Signal<(Bool, Bool, Challenge), NSError>.pipe()
            self?.createConfirmationAlert(challenge: challenge, observer: observer)
            return signal
            }.filter { (shouldLeave, _, _) in
                return shouldLeave
            }.flatMap(.concat) {[weak self] (_, keepTasks, challenge) -> Signal<Bool, NSError> in
                let (signal, observer) = Signal<Bool, NSError>.pipe()
                HRPGManager.shared().leave(challenge, keepTasks:keepTasks, onSuccess: {
                    observer.send(value: false)
                }, onError: {
                    observer.send(error: NSError())
                })
                return signal
        }
    }

    private func createConfirmationAlert(challenge: Challenge, observer: Observer<(Bool, Bool, Challenge), NSError>) {
        let alert = UIAlertController(title: NSLocalizedString("Leave Challenge?", comment: ""),
                                      message: NSLocalizedString("Do you want to leave the challenge and keep or delete the tasks?", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Keep tasks", comment: ""), style: .default, handler: { (_) in
            observer.send(value: (true, true, challenge))
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete tasks", comment: ""), style: .default, handler: { (_) in
            observer.send(value: (true, false, challenge))
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (_) in
            observer.send(value: (false, false, challenge))
        }))
        if var presentingController = self.presentingController {
            if let viewController = presentingController.presentedViewController {
                presentingController = viewController
            }
            presentingController.present(alert, animated: true, completion: nil)
        }
    }
}
