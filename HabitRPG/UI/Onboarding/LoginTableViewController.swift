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
import SwiftUIX

struct OnboardingScreen: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        if viewModel.showUsernameView {
            UsernameScreen(viewModel: viewModel)
        } else {
            LoginScreen(viewModel: viewModel)
        }
    }
}

class LoginTableViewController: UIViewController, UITextFieldDelegate {
    @objc public var isRootViewController = false

    required init?(coder: NSCoder) {
        hostingView = UIHostingView(rootView: OnboardingScreen(viewModel: viewModel))
        super.init(coder: coder)
    }
    private var hostingView: UIHostingView<OnboardingScreen>
    @IBOutlet weak var backgroundScrollView: UIScrollView!
    @IBOutlet weak var gradientView: GradientView!
    
    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak private var loginActivityIndicator: UIActivityIndicatorView!

    private let viewModel = LoginViewModel()
    private let userRepository = UserRepository()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        
        viewModel.viewController = self
        initialUISetup()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        hostingView.pin.all()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    private func initialUISetup() {
            gradientView.middleLocation = 0.7
            
            backgroundScrollView.layoutIfNeeded()
            let contentOffset = CGPoint(x: 0, y: backgroundScrollView.contentSize.height-view.frame.size.height)
            backgroundScrollView.contentOffset = contentOffset
            
            generateStars()
            view.addSubview(hostingView)
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
        
        imageView.frame.origin = CGPoint(x: Int.random(in: 0...(Int(backgroundScrollView.contentSize.width)) + 1),
                                         y: Int.random(in: 0...(Int(backgroundScrollView.contentSize.height)) + 1))
        imageView.frame.size = image.size
        backgroundScrollView.insertSubview(imageView, aboveSubview: gradientView)
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
    func showError(_ message: String) {
        let alertController = HabiticaAlertController.genericError(message: message)
        alertController.show()
    }
    
    func showNextViewController(segueName: String) {
        if isRootViewController || segueName == "SetupSegue" {
            performSegue(withIdentifier: segueName, sender: self)
        } else {
            dismiss(animated: true, completion: nil)
        }
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
            
            viewModel.email = username
            viewModel.password = password
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
