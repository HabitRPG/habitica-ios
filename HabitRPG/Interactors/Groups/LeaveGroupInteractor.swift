//
//  LeaveGroupInteractor.swift
//  Habitica
//
//  Created by Phillip Thelen on 11.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import Habitica_Models

class LeaveGroupInteractor: Interactor<String, GroupProtocol?> {
    weak var presentingController: UIViewController?
    
    private let socialRepository = SocialRepository()
    
    init(presentingViewController: UIViewController) {
        self.presentingController = presentingViewController
    }
    
    override func configure(signal: Signal<String, NSError>) -> Signal<GroupProtocol?, NSError> {
        return signal.flatMap(.concat) {[weak self] groupID -> Signal<(Bool, Bool, String), NSError> in
            let (signal, observer) = Signal<(Bool, Bool, String), NSError>.pipe()
            self?.createConfirmationAlert(groupID: groupID, observer: observer)
            return signal
            }.filter { (shouldLeave, _, _) in
                return shouldLeave
            }.flatMap(.concat) {[weak self] (_, keepChallenges, groupID) -> Signal<GroupProtocol?, NSError> in
                return self?.socialRepository.leaveGroup(groupID: groupID, leaveChallenges: !keepChallenges)
                    .promoteError() ?? Signal.empty
        }
    }
    
    private func createConfirmationAlert(groupID: String, observer: Signal<(Bool, Bool, String), NSError>.Observer) {
        let alert = HabiticaAlertController(title: L10n.Guilds.leaveGuildTitle,
                                            message: L10n.Guilds.leaveGuildDescription)
        alert.addAction(title: L10n.Guilds.keepChallenges, handler: {[weak self] (_) in
            observer.send(value: (true, true, groupID))
        })
        alert.addAction(title: L10n.Guilds.leaveChallenges, style: .destructive, handler: {[weak self] (_) in
            observer.send(value: (true, false, groupID))
        })
        alert.setCloseAction(title: L10n.cancel, handler: {
            observer.send(value: (false, false, groupID))
        })
        alert.show()
    }
}
