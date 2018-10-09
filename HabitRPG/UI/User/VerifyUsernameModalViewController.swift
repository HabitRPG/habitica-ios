//
//  VerifyUsernameModalView.swift
//  Habitica
//
//  Created by Phillip Thelen on 05.10.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Habitica_Models
import Result

class VerifyUsernameModalViewController: UIViewController {
    
    private let userRepository = UserRepository()
    private var currentUsername: String?
    
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var displayNameIconView: UIImageView!
    @IBOutlet weak var usernameIconView: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    
    private var usernameProperty = MutableProperty<String?>(nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayNameIconView.image = HabiticaIcons.imageOfCheckmark(checkmarkColor: UIColor.green50(), percentage: 100)
        usernameIconView.image = HabiticaIcons.imageOfCheckmark(checkmarkColor: UIColor.green50(), percentage: 100)
        
        userRepository.getUser().take(first: 1) .on(value: { user in
            self.displayNameTextField.text = user.profile?.name
            self.usernameTextField.text = user.authentication?.local?.username
            self.currentUsername = user.authentication?.local?.username
        }).start()
        
        displayNameIconView.isHidden = true
        usernameIconView.isHidden = true
        
        usernameTextField.addTarget(self, action: #selector(usernameChanged), for: .editingChanged)
        
        usernameProperty.producer.throttle(2, on: QueueScheduler.main)
            .skipNil()
            .filter({[weak self] username -> Bool in self?.currentUsername != username })
            .flatMap(.latest) {[weak self] text -> SignalProducer<VerifyUsernameResponse?, NoError> in
                return self?.userRepository.verifyUsername(text).producer ?? SignalProducer.empty
            }
            .skipNil()
            .on(value: {[weak self] response in
                self?.usernameIconView.isHidden = !response.isUsable
                self?.errorLabel.text = response.issues?.joined(separator: "\n")
            }).start()
    }
    
    @objc
    private func usernameChanged(_ textField: UITextField?) {
        usernameProperty.value = textField?.text
    }
    
    @IBAction func confirmUsernameButtonTapped(_ sender: Any) {
        userRepository.updateUser(["profile.name": displayNameTextField.text ?? ""])
            .flatMap(.latest) { _ in
                return self.userRepository.updateUsername(newUsername: self.usernameProperty.value ?? "")
            }.observeCompleted {
                self.dismiss(animated: true, completion: nil)
        }
    }
}
