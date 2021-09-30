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
    private var configRepository = ConfigRepository.shared
    private let disposable = CompositeDisposable()
    
    private var wasDismissed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if AuthenticationManager.shared.hasAuthentication() {
            userRepository = UserRepository()
            let hasUserData = userRepository?.hasUserData() ?? false
            userRepository?.retrieveUser()
                .flatMap(.latest, {[weak self] (_) in
                    return self?.userRepository?.retrieveInboxConversations() ?? Signal.empty
                })
                .observeCompleted { [weak self] in
                    self?.userRepository = nil
                    if !hasUserData {
                        self?.segueForLoggedInUser()
                    }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let delegate = UIApplication.shared.delegate as? HabiticaAppDelegate {
            if delegate.handleMaintenanceScreen() {
                return
            }
        }
        if AuthenticationManager.shared.hasAuthentication() {
            if let repository = userRepository, repository.hasUserData() == false {
                showLoadingIndicator()
            } else {
                segueForLoggedInUser()
            }
        } else {
            if ConfigRepository.hasFetched {
                completeInitialLaunch()
            } else {
                ConfigRepository.onFetchCompleted = {
                    self.completeInitialLaunch()
                }
            }
            
        }
        super.viewDidAppear(animated)
    }
    
    private func completeInitialLaunch() {
        DispatchQueue.main.async {
            if self.configRepository.bool(variable: .disableIntroSlides) {
                self.perform(segue: StoryboardSegue.Intro.loginSegue)
            } else {
                self.perform(segue: StoryboardSegue.Intro.introSegue)
            }
        }
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
