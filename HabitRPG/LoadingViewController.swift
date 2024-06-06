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

private class LoadingViewModel: ObservableObject {
    @Published var showProgress = false
}

struct LoadingPage: View {
    @ObservedObject fileprivate var viewModel: LoadingViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            Image(uiImage: Asset.confettiTiled.image).resizable(resizingMode: .tile).foregroundColor(Color(hexadecimal: "CC62FA")).frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack(spacing: 24) {
                Image(uiImage: Asset.launchLogo.image)
                ZStack {
                    Circle().fill().foregroundColor(Color(hexadecimal: "4F2A93").opacity(0.3))
                    ProgressView().habiticaProgressStyle().padding(12)
                }.frame(width: 56, height: 56).opacity(viewModel.showProgress ? 1.0 : 0.0)
            }.padding(.top, 208)
        }
        .background(Color(hexadecimal: "7639ED"))
        .ignoresSafeArea()
    }
}

class LoadingViewController: UIHostingController<LoadingPage> {
    
    @objc var loadingFinishedAction: (() -> Void)?
    
    @IBOutlet weak var logoView: UIImageView!
    
    private var userRepository: UserRepository?
    private var configRepository = ConfigRepository.shared
    private let disposable = CompositeDisposable()
    private let viewModel = LoadingViewModel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: LoadingPage(viewModel: viewModel))
    }
    
    private var wasDismissed = false
    
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
                .flatMap(.latest, {[weak self] (_) in
                    return self?.userRepository?.retrieveInAppRewards() ?? Signal.empty
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
    
    private func segueForLoggedInUser() {
        if UserDefaults.standard.bool(forKey: "isInSetup") {
            perform(segue: StoryboardSegue.Intro.setupSegue)
        } else {
            perform(segue: StoryboardSegue.Intro.initialSegue)
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
