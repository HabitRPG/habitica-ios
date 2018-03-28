//
//  LoginTableViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 25/12/2016.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift

class LoginTableViewController: UIViewController, UITextFieldDelegate {

    @objc public var isRootViewController = false

    @IBOutlet weak private var usernameField: LoginEntryView!
    @IBOutlet weak private var emailField: LoginEntryView!
    @IBOutlet weak private var passwordField: LoginEntryView!
    @IBOutlet weak private var passwordRepeatField: LoginEntryView!
    @IBOutlet weak private var loginButton: UIButton!
    @IBOutlet weak private var onePasswordButton: UIButton!
    @IBOutlet weak private var googleLoginButton: UIButton!
    @IBOutlet weak private var facebookLoginButton: UIButton!
    @IBOutlet weak private var registerBeginButton: UIButton!
    @IBOutlet weak private var loginBeginButton: UIButton!
    @IBOutlet weak var backgroundScrollView: UIScrollView!
    @IBOutlet weak var formContainer: UIStackView!
    @IBOutlet weak var beginButtonContainer: UIStackView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var formBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoFormSpacing: NSLayoutConstraint!
    @IBOutlet weak var logoHeight: NSLayoutConstraint!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak private var loginActivityIndicator: UIActivityIndicatorView!

    private let viewModel = LoginViewModel()
    private var sharedManager: HRPGManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.sharedManager = HRPGManager.shared()
        self.viewModel.inputs.setSharedManager(sharedManager: self.sharedManager)
        self.viewModel.inputs.setViewController(viewController: self)

        loginBeginButton.addTarget(self, action: #selector(loginBeginButtonPressed), for: .touchUpInside)
        registerBeginButton.addTarget(self, action: #selector(registerBeginButtonPressed), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        usernameField.entryView.addTarget(self, action: #selector(usernameTextFieldChanged(textField:)), for: .editingChanged)
        usernameField.delegate = self
        emailField.entryView.addTarget(self, action: #selector(emailTextFieldChanged(textField:)), for: .editingChanged)
        emailField.delegate = self
        passwordField.entryView.addTarget(self, action: #selector(passwordTextFieldChanged(textField:)), for: .editingChanged)
        passwordField.delegate = self
        passwordRepeatField.entryView.addTarget(self, action: #selector(passwordRepeatTextFieldChanged(textField:)), for: .editingChanged)
        passwordRepeatField.delegate = self

        loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        googleLoginButton.addTarget(self, action: #selector(googleLoginButtonPressed), for: .touchUpInside)
        facebookLoginButton.addTarget(self, action: #selector(facebookLoginButtonPressed), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonPressed), for: .touchUpInside)

        onePasswordButton.addTarget(self, action: #selector(onePasswordButtonPressed), for: .touchUpInside)
        
        self.viewModel.setAuthType(authType: LoginViewAuthType.none)
        bindViewModel()
        self.viewModel.inputs.onePassword(
            isAvailable: OnePasswordExtension.shared().isAppExtensionAvailable()
        )
        
        initialUISetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    private func initialUISetup() {
        let buttonBackground = #imageLiteral(resourceName: "LoginButton").resizableImage(withCapInsets: UIEdgeInsets(top: 21, left: 21, bottom: 21, right: 21))
        loginButton.setBackgroundImage(buttonBackground, for: .normal)
        facebookLoginButton.setBackgroundImage(buttonBackground, for: .normal)
        googleLoginButton.setBackgroundImage(buttonBackground, for: .normal)
        
        backgroundScrollView.layoutIfNeeded()
        let contentOffset = CGPoint(x: 0, y: backgroundScrollView.contentSize.height-view.frame.size.height)
        backgroundScrollView.contentOffset = contentOffset
        formContainer.arrangedSubviews.forEach({ (view) in
            view.alpha = 0
        })
        backButton.alpha = 0
        
        generateStars()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    private func generateStars() {
        generateStars(largeCount: 1, mediumCount: 12, smallCount: 25)
    }
    
    private func generateStars(largeCount: Int, mediumCount: Int, smallCount: Int) {
        for _ in 1...largeCount {
            generateStar(HabiticaIcons.imageOfStarLarge)
        }
        for _ in 1...mediumCount {
            generateStar(HabiticaIcons.imageOfStarMedium)
        }
        for _ in 1...smallCount {
            generateStar(HabiticaIcons.imageOfStarSmall)
        }
    }
    
    private func generateStar(_ image: UIImage) {
        let imageView = UIImageView()
        imageView.image = image
        
        imageView.frame.origin = CGPoint(x: Int(arc4random_uniform(UInt32(backgroundScrollView.contentSize.width)) + 1),
                                         y: Int(arc4random_uniform(UInt32(backgroundScrollView.contentSize.height)) + 1))
        imageView.frame.size = image.size
        backgroundScrollView.insertSubview(imageView, aboveSubview: gradientView)
    }

    func bindViewModel() {
        setupButtons()
        setupFieldVisibility()
        setupDecorations()
        setupReturnTypes()
        setupTextInput()
        setupOnePassword()

        self.viewModel.outputs.usernameFieldTitle.observeValues {[weak self] value in
            self?.usernameField.placeholderText = value
        }

        self.viewModel.outputs.showError
            .observe(on: QueueScheduler.main)
            .observeValues { message in
                let alertController = HabiticaAlertController.genericError(message: message)
                alertController.show()
        }

        self.viewModel.outputs.showNextViewController
        .observeValues {[weak self] segueName in
            guard let weakSelf = self else {
                return
            }
            if weakSelf.isRootViewController || segueName == "SetupSegue" {
                weakSelf.performSegue(withIdentifier: segueName, sender: self)
            } else {
                weakSelf.dismiss(animated: true, completion: nil)
            }
        }
        self.viewModel.outputs.loadingIndicatorVisibility
        .observeValues {[weak self] isVisible in
            if isVisible {
                self?.loginActivityIndicator.startAnimating()
                self?.loginActivityIndicator.isHidden = false
            } else {
                self?.loginActivityIndicator.isHidden = true
                self?.loginActivityIndicator.stopAnimating()
            }
        }
    }

    func setupButtons() {
        self.loginButton.reactive.title <~ self.viewModel.outputs.loginButtonTitle
        self.loginButton.reactive.isEnabled <~ self.viewModel.outputs.isFormValid
    }

    func setupFieldVisibility() {
        self.viewModel.outputs.emailFieldVisibility.observeValues {[weak self] value in
            guard let weakSelf = self else {
                return
            }
            if value {
                weakSelf.emailField.isHidden = false
                weakSelf.emailField.entryView.isEnabled = true
            } else {
                weakSelf.emailField.isHidden = true
                weakSelf.emailField.entryView.isEnabled = false
            }
        }
        self.viewModel.outputs.passwordRepeatFieldVisibility.observeValues {[weak self] value in
            guard let weakSelf = self else {
                return
            }
            if value {
                weakSelf.passwordRepeatField.isHidden = false
                weakSelf.passwordRepeatField.entryView.isEnabled = true
            } else {
                weakSelf.passwordRepeatField.isHidden = true
                weakSelf.passwordRepeatField.entryView.isEnabled = false
            }
        }
    }
    
    //swiftlint:disable function_body_length
    //swiftlint:disable cyclomatic_complexity
    func setupDecorations() {
        self.viewModel.outputs.formVisibility.observeValues {[weak self] (value) in
            guard let weakSelf = self else {
                return
            }
            if value {
                weakSelf.logoHeight.constant = 80
                weakSelf.logoFormSpacing.constant = 40
                weakSelf.formContainer.isHidden = false
                for (position, view) in weakSelf.formContainer.arrangedSubviews.enumerated() {
                    UIView.animate(withDuration: 0.4, delay: 1+0.1*Double(position), options: [], animations: {
                        view.alpha = 1
                    })
                }
                UIView.animate(withDuration: 0.6, animations: {
                    weakSelf.view.layoutIfNeeded()
                })
            } else {
                weakSelf.logoHeight.constant = 112
                weakSelf.logoFormSpacing.constant = 8
                UIView.animate(withDuration: 0.4, animations: {
                    weakSelf.formContainer.arrangedSubviews.forEach({ (view) in
                        view.alpha = 0
                    })
                }, completion: { (_) in
                    weakSelf.formContainer.isHidden = true
                })
                UIView.animate(withDuration: 0.4, delay: 0.4, options: [], animations: {
                    weakSelf.view.layoutIfNeeded()
                })
            }
            
        }
        self.viewModel.outputs.beginButtonsVisibility.observeValues {[weak self] (value) in
            guard let weakSelf = self else {
                return
            }
            if value {
                weakSelf.beginButtonContainer.isHidden = false
            }
            if weakSelf.viewModel.currentAuthType == .login {
                UIView.animate(withDuration: 0.4, delay: 0.6, options: [], animations: {
                    weakSelf.beginButtonContainer.arrangedSubviews[1].alpha = 0
                }, completion: { (_) in
                    weakSelf.beginButtonContainer.isHidden = !value
                })
                UIView.animate(withDuration: 0.4, animations: {
                    weakSelf.beginButtonContainer.arrangedSubviews[0].alpha = 0
                })
            } else if weakSelf.viewModel.currentAuthType == .register {
                UIView.animate(withDuration: 0.4, delay: 0.6, options: [], animations: {
                    weakSelf.beginButtonContainer.arrangedSubviews[0].alpha = 0
                }, completion: { (_) in
                    weakSelf.beginButtonContainer.isHidden = !value
                })
                UIView.animate(withDuration: 0.4, animations: {
                    weakSelf.beginButtonContainer.arrangedSubviews[1].alpha = 0
                })
            } else {
                UIView.animate(withDuration: 0.4, delay: 0.8, options: [], animations: {
                    weakSelf.beginButtonContainer.arrangedSubviews[0].alpha = 1
                    weakSelf.beginButtonContainer.arrangedSubviews[1].alpha = 1
                })
            }
            
        }
        self.viewModel.outputs.backButtonVisibility.observeValues {[weak self] (value) in
            guard let weakSelf = self else {
                return
            }
            UIView.animate(withDuration: 0.8, delay: value ? 1 : 0, options: [], animations: {
                weakSelf.backButton.alpha = value ? 1 : 0
            }, completion: nil)
        }
        self.viewModel.outputs.backgroundScrolledToTop.observeValues {[weak self] (value) in
            guard let weakSelf = self else {
                return
            }
            var contentOffset: CGPoint?
            if value {
                contentOffset = CGPoint(x: 0, y: 0)
            } else {
                contentOffset = CGPoint(x: 0, y: weakSelf.backgroundScrollView.contentSize.height-weakSelf.view.frame.size.height)
            }
            if let offset = contentOffset {
                UIView.animate(withDuration: 1, animations: {
                    weakSelf.backgroundScrollView.contentOffset = offset
                })
            }
        }
    }

    func setupReturnTypes() {
        self.viewModel.outputs.passwordFieldReturnButtonIsDone.observeValues {[weak self] value in
            if value {
                self?.passwordField.entryView.returnKeyType = .done
            } else {
                self?.passwordField.entryView.returnKeyType = .next
            }
        }

        self.viewModel.outputs.passwordRepeatFieldReturnButtonIsDone.observeValues {[weak self] value in
            if value {
                self?.passwordRepeatField.entryView.returnKeyType = .done
            } else {
                self?.passwordRepeatField.entryView.returnKeyType = .next
            }
        }
    }

    func setupTextInput() {
        self.usernameField.entryView.reactive.text <~ self.viewModel.outputs.usernameText
        self.emailField.entryView.reactive.text <~ self.viewModel.outputs.emailText
        self.passwordField.entryView.reactive.text <~ self.viewModel.outputs.passwordText
        self.passwordRepeatField.entryView.reactive.text <~ self.viewModel.outputs.passwordRepeatText
    }

    func setupOnePassword() {
        self.onePasswordButton.reactive.isHidden <~ self.viewModel.outputs.onePasswordButtonHidden
        self.viewModel.outputs.onePasswordFindLogin.observeValues {[weak self] _ in
            OnePasswordExtension.shared().findLogin(forURLString: "https://habitica.com", for: self!, sender: self?.onePasswordButton, completion: { (data, _) in
                guard let loginData = data else {
                    return
                }
                let username = loginData[AppExtensionUsernameKey] as? String ?? ""
                let password = loginData[AppExtensionPasswordKey] as? String ?? ""

                self?.viewModel.onePasswordFoundLogin(username: username, password: password)
            })

        }
    }

    @objc
    func loginBeginButtonPressed() {
        self.viewModel.inputs.setAuthType(authType: .login)
    }
    @objc
    func registerBeginButtonPressed() {
        self.viewModel.inputs.setAuthType(authType: .register)
    }
    @objc
    func backButtonPressed() {
        self.viewModel.inputs.setAuthType(authType: .none)
        self.view.endEditing(false)
    }

    @objc
    func usernameTextFieldChanged(textField: UITextField) {
        self.viewModel.inputs.usernameChanged(username: textField.text)
    }

    @objc
    func emailTextFieldChanged(textField: UITextField) {
        self.viewModel.inputs.emailChanged(email: textField.text)
    }

    @objc
    func passwordTextFieldChanged(textField: UITextField) {
        self.viewModel.inputs.passwordChanged(password: textField.text)
    }

    @objc
    func passwordRepeatTextFieldChanged(textField: UITextField) {
        self.viewModel.inputs.passwordRepeatChanged(passwordRepeat: textField.text)
    }

    @objc
    func loginButtonPressed() {
        self.viewModel.inputs.loginButtonPressed()
        self.view.endEditing(true)
    }

    @objc
    func googleLoginButtonPressed() {
        self.viewModel.inputs.googleLoginButtonPressed()
    }

    @objc
    func onePasswordButtonPressed() {
        self.viewModel.inputs.onePasswordTapped()
    }

    @objc
    func facebookLoginButtonPressed() {
        self.viewModel.inputs.facebookLoginButtonPressed()
    }
    
    @objc
    func forgotPasswordButtonPressed() {
        let alertController = HabiticaAlertController(title: NSLocalizedString("Email a Password Reset Link", comment: ""))
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        let textView = UITextView()
        textView.text = NSLocalizedString("Enter the email address you used to register your Habitica account.", comment: "")
        textView.font = UIFont.preferredFont(forTextStyle: .subheadline)
        textView.textColor = UIColor.gray100()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = false
        stackView.addArrangedSubview(textView)
        let textField = UITextField()
        textField.placeholder = NSLocalizedString("Email", comment: "")
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        stackView.addArrangedSubview(textField)
        alertController.contentView = stackView
        
        alertController.addCancelAction()
        alertController.addAction(title: NSLocalizedString("Send", comment: ""), isMainAction: true) { _ in
            HRPGManager.shared().sendPasswordResetEmail(textField.text, onSuccess: {
                ToastManager.show(text: NSLocalizedString("If we have your email on file, instructions for setting a new password have been sent to your email.", comment: ""), color: .green)
            }, onError: nil)
        }
        alertController.show()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            guard let parentView = textField.superview?.superview else {
                return false
            }
            guard var index = formContainer.arrangedSubviews.index(of: parentView) else {
                return false
            }
            while true {
                index += 1
                guard let next = formContainer.arrangedSubviews[index] as? LoginEntryView else {
                    return false
                }
                if !next.isHidden {
                    next.entryView.becomeFirstResponder()
                    return true
                }
            }

        } else if textField.returnKeyType == .done {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @objc
    func keyboardWillShowNotification(notification: NSNotification) {
        updateBottomLayoutConstraint(notification: notification)
    }
    
    @objc
    func keyboardWillHideNotification(notification: NSNotification) {
        updateBottomLayoutConstraint(notification: notification)
    }
    
    func updateBottomLayoutConstraint(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
            return
        }

        guard let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            var rawAnimationCurve = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uint32Value else {
            return
        }
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        rawAnimationCurve = rawAnimationCurve << 16
        let animationCurve = UIViewAnimationOptions.init(rawValue: UInt(rawAnimationCurve))
        formBottomConstraint.constant = view.bounds.maxY - convertedKeyboardEndFrame.minY
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, animationCurve], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
