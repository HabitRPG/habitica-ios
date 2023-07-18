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

class LeaveGroupInteractor: Interactor<GroupProtocol, GroupProtocol?> {
    weak var presentingController: UIViewController?
    
    private let socialRepository = SocialRepository()
    private let userRepository = UserRepository()
    
    init(presentingViewController: UIViewController) {
        self.presentingController = presentingViewController
    }
    
    override func configure(signal: Signal<GroupProtocol, NSError>) -> Signal<GroupProtocol?, NSError> {
        return signal
            .flatMap(.concat) {[weak self] group -> Signal<(Bool, Bool, GroupProtocol), NSError> in
            let (signal, observer) = Signal<(Bool, Bool, GroupProtocol), NSError>.pipe()
            self?.createConfirmationAlert(group: group, observer: observer)
            return signal
            }.filter { (shouldLeave, _, _) in
                return shouldLeave
            }.flatMap(.concat) {[weak self] (_, keepChallenges, group) -> Signal<GroupProtocol?, NSError> in
                return self?.socialRepository.leaveGroup(groupID: group.id ?? "", leaveChallenges: !keepChallenges, isParty: group.type == "party")
                    .promoteError() ?? Signal.empty
        }
    }
    
    private func createConfirmationAlert(group: GroupProtocol, observer: Signal<(Bool, Bool, GroupProtocol), NSError>.Observer) {
        let title = group.type == "party" ? L10n.Party.leavePartyTitle : L10n.Guilds.leaveGuildTitle
        let message = group.type == "party" ? L10n.Party.leavePartyDescription : L10n.Guilds.leaveGuildDescription
        let alert = HabiticaAlertController(title: title,
                                            message: message)
        if group.type == "party" {
            alert.addAction(title: L10n.Party.leave, isMainAction: true, handler: { (_) in
                observer.send(value: (true, true, group))
            })
        } else {
            alert.addAction(title: L10n.Guilds.keepChallenges, isMainAction: true, handler: { (_) in
                observer.send(value: (true, true, group))
            })
            alert.addAction(title: L10n.Guilds.leaveChallenges, style: .destructive, handler: { (_) in
                observer.send(value: (true, false, group))
            })
        }
        alert.setCloseAction(title: L10n.close, handler: {
            observer.send(value: (false, false, group))
        })
        alert.show()
    }
}
