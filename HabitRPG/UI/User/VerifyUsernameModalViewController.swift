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
import Habitica_Database

class VerifyUsernameModalViewController: UIViewController {
    
    private let userRepository = UserRepository()
    private var currentUsername: String?
    
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var displayNameIconView: UIImageView!
    @IBOutlet weak var usernameIconView: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    private var usernameProperty = MutableProperty<String?>(nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayNameIconView.image = HabiticaIcons.imageOfCheckmark(checkmarkColor: UIColor.green50(), percentage: 100)
        usernameIconView.image = HabiticaIcons.imageOfCheckmark(checkmarkColor: UIColor.green50(), percentage: 100)
        
        userRepository.getUser().take(first: 1) .on(value: { user in
            self.displayNameTextField.text = user.profile?.name
            self.usernameTextField.text = user.username
            self.currentUsername = user.username
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
                self?.confirmButton.isEnabled = response.isUsable
                self?.errorLabel.text = response.issues?.joined(separator: "\n")
            }).start()
    }
    
    @objc
    private func usernameChanged(_ textField: UITextField?) {
        usernameProperty.value = textField?.text
    }
    
    @IBAction func confirmUsernameButtonTapped(_ sender: Any) {
        guard let displayname = displayNameTextField.text else {
            return
        }
        guard let username = usernameTextField.text else {
            return
        }
        confirmButton.isEnabled = false
        userRepository.updateUser(key: "profile.name", value: displayname)
            .flatMap(.latest, { user -> SignalProducer<UserProtocol, ValidationError> in
                if user == nil {
                    return SignalProducer.init(error: ValidationError(""))
                }
                return self.userRepository.updateUsername(newUsername: username).mapError({ error -> ValidationError in
                    return ValidationError(error.localizedDescription)
                }).producer
            })
            .on(value: { user in
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    if self.presentedViewController != nil {
                        self.presentedViewController?.dismiss(animated: false, completion: nil)
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            })
            .observeCompleted {
                self.confirmButton.isEnabled = true
        }
    }
}

private struct ValidationError: Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    public var localizedDescription: String {
        return message
    }
}
