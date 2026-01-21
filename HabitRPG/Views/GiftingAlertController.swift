//
//  GiftingAlertController.swift
//  Habitica
//
//  Created by Phillip Thelen on 15.01.26.
//  Copyright © 2026 HabitRPG Inc. All rights reserved.
//
import UIKit

class GiftingAlertController: HabiticaAlertController {
    let usernameTextField = PaddedTextField()
    
    private let socialRepository = SocialRepository()
    init(title: String, message: String, onFound: @escaping (String) -> Void) {
        super.init()
        self.title = title
        self.message = message
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        usernameTextField.attributedPlaceholder = NSAttributedString(string: L10n.username, attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        usernameTextField.autocapitalizationType = .none
        usernameTextField.spellCheckingType = .no
        usernameTextField.borderStyle = .none
        usernameTextField.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
        usernameTextField.cornerRadius = UIConstants.largeCornerRadius
        usernameTextField.textInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        usernameTextField.textColor = ThemeService.shared.theme.secondaryTextColor
        stackView.addArrangedSubview(usernameTextField)
        contentView = stackView
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.isHidden = true
        stackView.addArrangedSubview(activityIndicator)
        
        let errorView = UILabel()
        errorView.isHidden = true
        errorView.textColor = ThemeService.shared.theme.errorTextColor
        errorView.text = L10n.Errors.userNotFound
        errorView.textAlignment = .center
        errorView.font = UIFontMetrics.default.scaledSystemFont(ofSize: 12)
        stackView.addArrangedSubview(errorView)

        var foundUser = false
        addAction(title: L10n.continue, isMainAction: true, closeOnTap: false) {[weak self] _ in
            activityIndicator.isHidden = false
            errorView.isHidden = true
            activityIndicator.startAnimating()
            if let username = self?.usernameTextField.text {
                self?.socialRepository.retrieveMember(userID: username, handleErrors: false).on(
                    value: { _ in
                        foundUser = true
                        self?.dismiss()
                        onFound(username)
                }
                ).observeCompleted {
                    activityIndicator.isHidden = true
                    if !foundUser {
                        errorView.isHidden = false
                    }
                }
            }
        }
        addCancelAction()
    }
    
    override func show() {
        super.show()
        usernameTextField.becomeFirstResponder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
