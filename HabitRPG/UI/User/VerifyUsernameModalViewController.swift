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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var footerTextView: UITextView!
    
    private var usernameProperty = MutableProperty<String?>(nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        
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
        
        let descriptionString = NSMutableAttributedString(string: "\(L10n.usernamePromptBody)\n\n")
        descriptionString.append(formattedWikiString())
        descriptionTextView.attributedText = descriptionString
        footerTextView.attributedText = formattedFooterString()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    @objc func keyboardWasShown(notification: NSNotification) {
        //Need to calculate keyboard exact size due to Apple suggestions
        if let info = notification.userInfo {
            let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom:  keyboardSize!.height, right: 0)
            
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        //Once keyboard disappears, restore original positions
        if let info = notification.userInfo {
            let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            self.view.endEditing(true)
        }
    }
    
    private func formattedWikiString() -> NSAttributedString {
        let stringComponents = L10n.usernamePromptWiki.split(separator: "#")
        let finalString = NSMutableAttributedString()
        for component in stringComponents {
            if component.starts(with: "<wk>") {
                let attributedComponent = NSMutableAttributedString(string: component.replacingOccurrences(of: "<wk>", with: ""))
                attributedComponent.addAttribute(.link, value: "https://habitica.wikia.com/wiki/Player_Names", range: NSRange(location: 0, length: attributedComponent.length))
                finalString.append(attributedComponent)
            } else {
                finalString.append(NSAttributedString(string: String(component)))
            }
        }
        
        return finalString
    }
    
    private func formattedFooterString() -> NSAttributedString {
        let stringComponents = L10n.usernamePromptDisclaimer.split(separator: "#")
        let finalString = NSMutableAttributedString()
        for component in stringComponents {
            if component.starts(with: "<ts>") {
                let attributedComponent = NSMutableAttributedString(string: component.replacingOccurrences(of: "<ts>", with: ""))
                attributedComponent.addAttribute(.link, value: "https://habitica.com/static/terms", range: NSRange(location: 0, length: attributedComponent.length))
                finalString.append(attributedComponent)
            } else if component.starts(with: "<cg>") {
                let attributedComponent = NSMutableAttributedString(string: component.replacingOccurrences(of: "<cg>", with: ""))
                attributedComponent.addAttribute(.link, value: "https://habitica.com/static/community-guidelines", range: NSRange(location: 0, length: attributedComponent.length))
                finalString.append(attributedComponent)
            } else {
                finalString.append(NSAttributedString(string: String(component)))
            }
        }
        
        return finalString
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
