//
//  LoadingViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 13.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import ReactiveSwift

class LoadingViewController: UIViewController {
    
    @objc var loadingFinishedAction: (() -> Void)?
    
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var userRepository: UserRepository?
    private let disposable = CompositeDisposable()
    
    private var wasDismissed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if AuthenticationManager.shared.hasAuthentication() {
            userRepository = UserRepository()
            let hasUserData = userRepository?.hasUserData() ?? false
            userRepository?.retrieveUser()
                .flatMap(.latest, {[weak self] (_) in
                    return self?.userRepository?.retrieveInboxMessages() ?? Signal.empty
                })
                .on(value: {[weak self] _ in
                    self?.userRepository = nil
                    if !hasUserData {
                        self?.segueForLoggedInUser()
                    }
            }).observeCompleted {}
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if AuthenticationManager.shared.hasAuthentication() {
            if let repository = userRepository, repository.hasUserData() == false {
                showLoadingIndicator()
            } else {
                segueForLoggedInUser()
            }
        } else {
            perform(segue: StoryboardSegue.Intro.introSegue)
        }
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let action = loadingFinishedAction {
            action()
        }
        if !disposable.isDisposed {
            disposable.dispose()
        }
        if !wasDismissed {
            wasDismissed = true
            //dismiss(animated: false, completion: nil)
        }
        super.viewDidDisappear(animated)
    }
    
    private func segueForLoggedInUser() {
        if UserDefaults.standard.bool(forKey: "isInSetup") {
            perform(segue: StoryboardSegue.Intro.setupSegue)
        } else {
            perform(segue: StoryboardSegue.Intro.initialSegue)
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.3) {
            self.activityIndicator.alpha = 1.0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Intro.loginSegue.rawValue {
            let navigationViewController = segue.destination as? UINavigationController
            let loginViewController = navigationViewController?.topViewController as? LoginTableViewController
            loginViewController?.isRootViewController = true
        }
    }
}
