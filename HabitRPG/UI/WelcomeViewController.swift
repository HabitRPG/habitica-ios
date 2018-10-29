//
//  WelcomeViewController.swift
//  Habitica
//
//  Created by Phillip on 08.08.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import Habitica_Models
import Result
import Habitica_Database

class WelcomeViewController: UIViewController, TypingTextViewController {
    
    var onEnableNextButton: ((Bool) -> Void)?
    var displayName: String? {
        return displayNameTextField.text
    }
    var username: String? {
        return usernameTextField.text
    }
    
    private let userRepository = UserRepository()
    private var currentUsername: String?
    
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var displayNameIconView: UIImageView!
    @IBOutlet weak var usernameIconView: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var speechbubbleView: SpeechbubbleView!
    
    func startTyping() {
        speechbubbleView.animateTextView()
    }
    
    private var displayNameProperty = MutableProperty<String?>(nil)
    private var usernameProperty = MutableProperty<String?>(nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayNameIconView.image = HabiticaIcons.imageOfCheckmark(checkmarkColor: UIColor.green50(), percentage: 100)
        usernameIconView.image = HabiticaIcons.imageOfCheckmark(checkmarkColor: UIColor.green50(), percentage: 100)
        
        displayNameIconView.isHidden = true
        usernameIconView.isHidden = true
        
        displayNameTextField.addTarget(self, action: #selector(displayNameChanged), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(usernameChanged), for: .editingChanged)
        
        usernameProperty.producer.throttle(2, on: QueueScheduler.main)
            .skipNil()
            .flatMap(.latest) {[weak self] text -> SignalProducer<VerifyUsernameResponse?, NoError> in
                return self?.userRepository.verifyUsername(text).producer ?? SignalProducer.empty
            }
            .skipNil()
            .on(value: {[weak self] response in
                self?.usernameIconView.isHidden = !response.isUsable
                if let action = self?.onEnableNextButton {
                    action(response.isUsable)
                }
                self?.errorLabel.text = response.issues?.joined(separator: "\n")
            }).start()
        
        displayNameProperty.producer
            .skipNil()
            .map({ (displayName) -> Bool in
                return displayName.count > 0 && displayName.count <= 30
            })
            .on(value: {[weak self] isRightLength in
                self?.displayNameIconView.isHidden = !isRightLength
                if !isRightLength {
                    self?.errorLabel.text = L10n.Settings.displayNameLengthError
                } else {
                    self?.errorLabel.text = nil
                }
            }).start()
        
        userRepository.getUser().take(first: 1) .on(value: { user in
            self.displayNameTextField.text = user.profile?.name
            self.displayNameProperty.value = user.profile?.name
            self.usernameTextField.text = user.username
            self.usernameProperty.value = user.username
            self.currentUsername = user.username
        }).start()
    }
    
    @objc
    private func usernameChanged(_ textField: UITextField?) {
        usernameProperty.value = textField?.text
    }
    
    @objc
    private func displayNameChanged(_ textField: UITextField?) {
        displayNameProperty.value = textField?.text
    }
}
