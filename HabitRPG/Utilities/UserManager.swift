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

@objc
class UserManager: NSObject {
    
    @objc public static let shared = UserManager()
    
    private let userRepository = UserRepository()
    private let taskRepository = TaskRepository()
    private let disposable = ScopedDisposable(CompositeDisposable())
    
    private weak var faintViewController: FaintViewController?
    private weak var classSelectionViewController: ClassSelectionViewController?
    var yesterdailiesDialog: YesterdailiesDialogView?
    
    private var tutorialSteps = [String: Bool]()
    
    func beginListening() {
        disposable.inner.add(userRepository.getUser()
            .throttle(1, on: QueueScheduler.main)
            .on(value: { user in
                self.onUserUpdated(user: user)
            }).start())
    }
    
    private func onUserUpdated(user: UserProtocol) {
        tutorialSteps = [:]
        user.flags?.tutorials.forEach({ (tutorial) in
            if let key = tutorial.key {
                tutorialSteps[key] = tutorial.wasSeen
            }
        })
        
        faintViewController = checkFainting(user: user)
        
        if faintViewController == nil {
            checkYesterdailies(user: user)
        }
        
        checkClassSelection(user: user)
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
    
    private func checkClassSelection(user: UserProtocol) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if user.flags?.classSelected == false && user.preferences?.disableClasses == false && (user.stats?.level ?? 0) >= 10 {
                if self.classSelectionViewController == nil {
                    let classSelectionController = StoryboardScene.Settings.classSelectionNavigationController.instantiate()
                    if var topController = UIApplication.shared.keyWindow?.rootViewController {
                        while let presentedViewController = topController.presentedViewController {
                            topController = presentedViewController
                        }
                        classSelectionController.modalTransitionStyle = .crossDissolve
                        classSelectionController.modalPresentationStyle = .overCurrentContext
                        topController.present(classSelectionController, animated: true) {
                        }
                    }
                }
            }
        }
    }
    
    @objc
    func shouldDisplayTutorialStep(key: String) -> Bool {
        return !(tutorialSteps[key] ?? true)
    }
    
    @objc
    func markTutorialAsSeen(type: String, key: String) {
        disposable.inner.add(userRepository.updateUser(key: "flags.tutorial.\(type).\(key)", value: true).observeCompleted {})
    }
}
