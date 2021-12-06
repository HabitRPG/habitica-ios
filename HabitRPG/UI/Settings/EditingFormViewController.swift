//
//  EditingFormViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.12.21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation
import UIKit
import PinLayout
import SwiftUI

enum EditingTextFieldType {
    case email
    case name
    case password
    case passwordRepeat
    
    func configure(textField: UITextField) {
        switch self {
        case .password, .passwordRepeat:
            textField.isSecureTextEntry = true
        case .email:
            textField.keyboardType = .emailAddress
        default:
            return
        }
    }
    
    func validate(textField: UITextField) -> Bool {
        switch self {
        case .password, .passwordRepeat:
            return (textField.text?.count ?? 0) >= 8
        case .email:
            return textField.text?.isValidEmail() == true
        default:
            return (textField.text?.count ?? 0) != 0
        }
    }
    
    func errorText() -> String {
        switch self {
        case .password:
            return L10n.Errors.passwordLength(8)
        case .passwordRepeat:
            return L10n.Errors.passwordLength(8)
        case .email:
            return L10n.Errors.enterValidEmail
        default:
            return ""
        }
    }
}

class EditingTextField: UIStackView, UITextFieldDelegate {
    private let titleView: UILabel = {
        let view = PaddedLabel()
        view.horizontalPadding = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 13, weight: .regular)
        view.textColor = ThemeService.shared.theme.secondaryTextColor
        return view
    }()
    
    private let textField: PaddedTextField = {
        let view = PaddedTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.autocapitalizationType = .none
        view.spellCheckingType = .no
        view.addHeightConstraint(height: 40)
        view.borderStyle = .none
        view.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor.withAlphaComponent(0.75)
        view.cornerRadius = 8
        view.borderWidth = 1
        view.borderColor = .clear
        view.textInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.textColor = ThemeService.shared.theme.secondaryTextColor
        return view
    }()
    
    private let errorView: UILabel = {
        let view = PaddedLabel()
        view.horizontalPadding = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .systemFont(ofSize: 13, weight: .regular)
        view.textColor = ThemeService.shared.theme.errorColor
        view.isHidden = true
        return view
    }()
    
    var placeholder: String? {
        get {
            textField.placeholder
        }
        set(value) {
            textField.attributedPlaceholder = NSAttributedString(string: value ?? "", attributes: [.foregroundColor: ThemeService.shared.theme.dimmedTextColor])
        }
    }
    
    var text: String? {
        get {
            textField.text
        }
        set(value) {
            textField.text = value
        }
    }
    
    var extraError: String? {
        get {
            return errorView.text
        }
        set(value) {
            errorView.text = value
            errorView.isHidden = value == nil
        }
    }
    
    var isValid: Bool {
        return type.validate(textField: textField)
    }
    
    let key: String
    private let type: EditingTextFieldType
    
    init(key: String, title: String, type: EditingTextFieldType, value: String? = nil) {
        self.key = key
        self.type = type
        super.init(frame: CGRect.zero)
        textField.delegate = self
        textField.text = value
        axis = .vertical
        spacing = 6
        addArrangedSubview(titleView)
        addArrangedSubview(textField)
        addArrangedSubview(errorView)
        titleView.text =  title
        errorView.text = type.errorText()
        type.configure(textField: textField)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        titleView.font = .systemFont(ofSize: 13, weight: .semibold)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        titleView.font = .systemFont(ofSize: 13, weight: .regular)
        updateValidation(onlyPositive: false)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateValidation(onlyPositive: true)
        return true
    }
    
    private func updateValidation(onlyPositive: Bool) {
        withAnimation {
            if isValid || (text ?? "").isEmpty {
                textField.borderColor = .clear
                errorView.isHidden = true
            } else if !onlyPositive && errorView.isHidden {
                textField.borderColor = ThemeService.shared.theme.errorColor
                errorView.isHidden = false
            }
        }
    }
    
    func showError() {
        errorView.isHidden = false
    }
}

class EditingFormViewController: UIViewController, Themeable {
    var formTitle: String?
    var saveButtonTitle: String?
    var onSave: (([String: String]) -> Void)?
    var onCrossValidation: (([String: String]) -> [String: String])?
    var asyncValidation: (([String: String], ([String: String]) -> Void) -> Void)?
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 12
        view.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        view.isLayoutMarginsRelativeArrangement = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var fields = [EditingTextField]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = formTitle
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: L10n.cancel, style: .plain, target: self, action: #selector(dismissForm))
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: saveButtonTitle ?? L10n.save, style: .plain, target: self, action: #selector(saveForm))
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        ThemeService.shared.addThemeable(themable: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = formTitle
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for field in fields {
            stackView.addArrangedSubview(field)
        }
    }
    
    func applyTheme(theme: Theme) {
        scrollView.backgroundColor = theme.contentBackgroundColor
    }
    
    @objc
    private func dismissForm() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func saveForm() {
        if let action = onSave {
            var values = [String: String]()
            for field in fields {
                if !field.isValid {
                    field.showError()
                    return
                }
                values[field.key] = field.text ?? ""
            }
            if let validate = onCrossValidation {
                let validation = validate(values)
                if !validation.isEmpty {
                    for field in fields {
                        if let error = validation[field.key] {
                            field.extraError = error
                        }
                    }
                    return
                }
            }
            action(values)
        }
        dismissForm()
    }
    
    override func viewWillLayoutSubviews() {
        scrollView.frame = view.bounds
        stackView.pin.start().end().marginHorizontal(12).top()
        for field in stackView.arrangedSubviews {
            field.pin.sizeToFit(.width)
        }
        stackView.pin.sizeToFit(.width)
        scrollView.contentSize = stackView.frame.size
        super.viewWillLayoutSubviews()
    }
}
