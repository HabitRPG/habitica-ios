//
//  UserManager.swift
//  Habitica
//
//  Created by Phillip Thelen on 26.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift
import Result

class UserManager {
    
    public static let shared = UserManager()
    
    private let userRepository = UserRepository()
    private let taskRepository = TaskRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    private weak var faintViewController: FaintViewController?
    var yesterdailiesDialog: YesterdailiesDialogView?
    
    func beginListening() {
        disposable.inner.add(userRepository.getUser()
            .throttle(1, on: QueueScheduler.main)
            .on(value: { user in
                self.onUserUpdated(user: user)
            }).start())
    }
    
    private func onUserUpdated(user: UserProtocol) {
        faintViewController = checkFainting(user: user)
        
        if faintViewController == nil {
            checkYesterdailies(user: user)
        }
    }
    
    private func checkFainting(user: UserProtocol) -> FaintViewController? {
        if (user.stats?.health ?? 0) <= 0.0 && faintViewController == nil {
            let faintView = FaintViewController()
            faintView.show()
            return faintView
        }
        return faintViewController
    }
    
    private func checkYesterdailies(user: UserProtocol) {
        if user.needsCron && yesterdailiesDialog == nil {
            yesterdailiesDialog = YesterdailiesDialogView.showDialog()
        }
    }
}
