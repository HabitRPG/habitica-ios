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
import SwiftUI
import IonicPortals
import UIKit
import Combine

private class LoadingViewModel: ObservableObject {
    @Published var showProgress = false
}

struct LoadingPage: View {
    @ObservedObject fileprivate var viewModel: LoadingViewModel
    
    var body: some View {
        ZStack(alignment: .top) {}
        .background(Color(hexadecimal: "7639ED"))
        .ignoresSafeArea()
    }
}

class LoadingViewController: UIViewController {
    
    @objc var loadingFinishedAction: (() -> Void)?
    private var userRepository: UserRepository?
    private var configRepository = ConfigRepository.shared
    private let disposable = CompositeDisposable()
    private let viewModel = LoadingViewModel()
    private var wasDismissed = false
    private var dismissCancellable: AnyCancellable?
    private var myPortal: PortalUIView?

    override func loadView() {
        super.loadView()
        self.view = PortalUIView(portal: "LoadingScreenPortal")
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if AuthenticationManager.shared.hasAuthentication() {
            userRepository = UserRepository()
            let hasUserData = userRepository?.hasUserData() ?? false
            userRepository?.retrieveUser()
                .flatMap(.latest, {[weak self] (_) in
                    return self?.userRepository?.retrieveGroupPlans() ?? Signal.empty
                })
                .flatMap(.latest, {[weak self] (_) in
                    return self?.userRepository?.retrieveInboxConversations() ?? Signal.empty
                })
                .observeCompleted { [weak self] in
                    self?.userRepository = nil
                    if !hasUserData {
                        self?.segueForLoggedInUser()
                    }
            }
            
            if let url = UserDefaults.standard.string(forKey: "initialScreenURL") {
                loadingFinishedAction = {
                    RouterHandler.shared.handle(urlString: url)
                }
            }
        }
        dismissCancellable = PortalsPubSub.shared.publisher(for: "loading")
                   .data(as: String.self)
                   .filter { $0 == "end" }
                   .receive(on: DispatchQueue.main)
                   .sink { [weak self] _ in
                       guard let self = self else { return }
                       self.dismiss(animated: true, completion: nil)
                       self.segueForLoggedInUser()
                   }
    }
    private func segueForLoggedInUser() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if UserDefaults.standard.bool(forKey: "isInSetup") {
                self.perform(segue: StoryboardSegue.Intro.setupSegue)
            } else {
                self.perform(segue: StoryboardSegue.Intro.initialSegue)
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
                viewModel.showProgress = true
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
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
        if let targetUrl = ProcessInfo.processInfo.environment["TARGET_URL"] {
            RouterHandler.shared.handle(urlString: targetUrl)
        }
        if !disposable.isDisposed {
            disposable.dispose()
        }
        if !wasDismissed {
            wasDismissed = true
        }
        super.viewDidDisappear(animated)
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.Intro.loginSegue.rawValue {
            let navigationViewController = segue.destination as? UINavigationController
            let loginViewController = navigationViewController?.topViewController as? LoginTableViewController
            loginViewController?.isRootViewController = true
        }
    }
}
