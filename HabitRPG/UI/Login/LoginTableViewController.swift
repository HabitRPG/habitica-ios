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
import AuthenticationServices

class LoginTableViewController: UIViewController, UITextFieldDelegate {

    @objc public var isRootViewController = false

    @IBOutlet weak private var usernameField: LoginEntryView!
    @IBOutlet weak private var emailField: LoginEntryView!
    @IBOutlet weak private var passwordField: LoginEntryView!
    @IBOutlet weak private var passwordRepeatField: LoginEntryView!
    @IBOutlet weak private var loginButton: UIButton!
    @IBOutlet weak private var googleLoginButton: UIButton!
    @IBOutlet weak private var appleLoginButton: UIButton!
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
    @IBOutlet weak var privacyPolicyLabel: UITextView!
    
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak private var loginActivityIndicator: UIActivityIndicatorView!

    private let viewModel = LoginViewModel()
    private let userRepository = UserRepository()

    override func viewDidLoad() {
        super.viewDidLoad()

        populateText()
        
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
        appleLoginButton.addTarget(self, action: #selector(appleLoginButtonPressed), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonPressed), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)

        self.viewModel.setAuthType(authType: LoginViewAuthType.none)
        bindViewModel()
        
        initialUISetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        viewModel.inputs.usernameChanged(username: nil)
        viewModel.inputs.passwordChanged(password: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // viewModel.performExistingAccountSetupFlows()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func populateText() {
        registerBeginButton.setTitle(L10n.Login.register, for: .normal)
        loginBeginButton.setTitle(L10n.Login.login, for: .normal)
        backButton.setTitle(L10n.back, for: .normal)
        usernameField.placeholderText = L10n.username
        emailField.placeholderText = L10n.email
        passwordField.placeholderText = L10n.password
        passwordRepeatField.placeholderText = L10n.repeatPassword
        
        forgotPasswordButton.setTitle(L10n.Login.forgotPassword, for: .normal)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let privacyAttributedText = NSMutableAttributedString(string: "By signing up, you are indicating that you have read and agree to the Terms of Service and Privacy Policy.")
        privacyAttributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 0.84, green: 0.78, blue: 1.00, alpha: 1.0),
                                           range: NSRange(location: 0, length: privacyAttributedText.length))
        privacyAttributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: privacyAttributedText.length))
        let termsRange = privacyAttributedText.mutableString.range(of: "Terms of Service")
        privacyAttributedText.addAttributes([NSAttributedString.Key.link: "https://habitica.com/static/terms"], range: termsRange)
        privacyAttributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: termsRange)
        let privacyRange = privacyAttributedText.mutableString.range(of: "Privacy Policy")
        privacyAttributedText.addAttributes([NSAttributedString.Key.link: "https://habitica.com/static/privacy",
                                             NSAttributedString.Key.foregroundColor: UIColor.white], range: privacyRange)
        privacyPolicyLabel.attributedText = privacyAttributedText
        privacyPolicyLabel.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    private func initialUISetup() {
        gradientView.middleLocation = 0.7
        let buttonBackground = Asset.loginButton.image.resizableImage(withCapInsets: UIEdgeInsets(top: 21, left: 16, bottom: 21, right: 16))
        loginButton.setBackgroundImage(buttonBackground, for: .normal)
        
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
    
    override var prefersHomeIndicatorAutoHidden: Bool {
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
            weakSelf.viewModel.inputs.usernameChanged(username: nil)
            weakSelf.viewModel.inputs.passwordChanged(password: nil)
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
        self.viewModel.outputs.isFormValid.observeValues { (isValid) in
            self.loginButton.isEnabled = isValid
            if isValid {
                self.loginButton.tintColor = .white
            } else {
                self.loginButton.tintColor = .purple100
            }
        }
        
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
                weakSelf.privacyPolicyLabel.isHidden = false
                weakSelf.forgotPasswordButton.isHidden = true
            } else {
                weakSelf.passwordRepeatField.isHidden = true
                weakSelf.passwordRepeatField.entryView.isEnabled = false
                weakSelf.privacyPolicyLabel.isHidden = true
                weakSelf.forgotPasswordButton.isHidden = false
            }
        }
    }
    
    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
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
        
        self.viewModel.outputs.arePasswordsSame.observeValues { areSame in
            self.passwordRepeatField.hasError = !areSame
        }
    }
    
    func setupTextTypes(isLogin: Bool) {
        usernameField.entryView.textContentType = .username
        emailField.entryView.textContentType = .emailAddress
        passwordField.entryView.textContentType = isLogin ? .password : .newPassword
        passwordRepeatField.entryView.textContentType = .newPassword
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
    func appleLoginButtonPressed() {
        self.viewModel.inputs.appleLoginButtonPressed()
    }

    @objc
    func forgotPasswordButtonPressed() {
        let alertController = HabiticaAlertController(title: L10n.Login.emailPasswordLink)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        let textView = UITextView()
        textView.text = L10n.Login.enterEmail
        textView.font = UIFont.preferredFont(forTextStyle: .subheadline)
        textView.textColor = UIColor.gray100
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = false
        stackView.addArrangedSubview(textView)
        let textField = UITextField()
        textField.placeholder = L10n.email
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        stackView.addArrangedSubview(textField)
        alertController.contentView = stackView
        
        alertController.addAction(title: L10n.send, isMainAction: true) { _ in
            self.userRepository.sendPasswordResetEmail(email: textField.text ?? "").observeCompleted {
                ToastManager.show(text: L10n.Login.resetPasswordResponse, color: .green, duration: 4.0)
            }
        }
        alertController.addCancelAction()
        alertController.show()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            guard let parentView = textField.superview?.superview else {
                return false
            }
            guard var index = formContainer.arrangedSubviews.firstIndex(of: parentView) else {
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

        guard let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            var rawAnimationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uint32Value else {
            return
        }
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        rawAnimationCurve = rawAnimationCurve << 16
        let animationCurve = UIView.AnimationOptions.init(rawValue: UInt(rawAnimationCurve))
        formBottomConstraint.constant = view.bounds.maxY - convertedKeyboardEndFrame.minY
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, animationCurve], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension LoginTableViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            let fullName = appleIDCredential.fullName
            
            var name = ""
            if let givenName = fullName?.givenName {
                name += givenName
            }
            if let familyName = fullName?.familyName {
                if !name.isEmpty {
                    name += " "
                }
                name += familyName
            }
            
            viewModel.performAppleLogin(identityToken: String(data: appleIDCredential.identityToken ?? Data(), encoding: .utf8) ?? "", name: name)
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            viewModel.usernameChanged(username: username)
            viewModel.passwordChanged(password: password)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
    }
}

extension LoginTableViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window ?? UIWindow()
    }
}
