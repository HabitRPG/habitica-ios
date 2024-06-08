//
//  AboutOFViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 09.10.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Realm
import Habitica_Models
import MessageUI
import IonicPortals
import UIKit
import Combine

class AboutOFViewController: UIViewController {
    
    private var dismissCancellable: AnyCancellable?

    override func loadView() {
        super.loadView()
        self.view = PortalUIView(portal: "LoadingAboutScreenPortal")
    
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissCancellable = PortalsPubSub.shared.publisher(for: "navigate")
                   .data(as: String.self)
                   .filter { $0 == "back" }
                   .receive(on: DispatchQueue.main)
                   .sink { [weak self] _ in
                       guard let self = self else { return }
                       self.dismiss(animated: true, completion: nil)
                       self.perform(segue: StoryboardSegue.Intro.aboutSegue)
                   }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = .clear
    }
}
