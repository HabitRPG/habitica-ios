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
    
    override func viewDidAppear(_ animated: Bool) {
        if AuthenticationManager.shared.hasAuthentication() {
            userRepository = UserRepository()
            if let repository = userRepository, repository.hasUserData() == false {
                showLoadingIndicator()
                repository.retrieveUser().observeCompleted {
                    self.segueForLoggedInUser()
                }
            } else {
                userRepository?.retrieveUser().observeCompleted {}
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
        userRepository = nil
        if !wasDismissed {
            wasDismissed = true
            dismiss(animated: false, completion: nil)
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
