//
//  BaseAlertController.swift
//  Habitica
//
//  Created by Phillip on 23.10.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import PopupDialog

@objc
class HabiticaAlertController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelTopMargin: NSLayoutConstraint!
    @IBOutlet weak var titleLabelBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var titleLabelBackground: UIView!
    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var alertStackView: UIStackView!
    
    private var buttonHandlers = [Int: ((UIButton) -> Swift.Void)]()
    private var buttons = [UIButton]()
    
    var contentView: UIView? {
        didSet {
            configureContentView()
        }
    }
    
    override var title: String? {
        didSet {
            configureTitleView()
        }
    }
    
    var message: String? {
        didSet {
            if message == nil || self.view == nil {
                return
            }
            configureMessageView()
        }
    }
    
    var closeAction: (() -> Void)? {
        didSet {
            configureCloseButton()
        }
    }
    
    var closeTitle: String?
    
    convenience init(title newTitle: String?, message newMessage: String? = nil) {
        self.init()
        self.title = newTitle
        self.message = newMessage
    }
    
    init() {
        super.init(nibName: "HabiticaAlertController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTitleView()
        configureMessageView()
        configureContentView()
        configureCloseButton()
        configureButtons()
    }
    
    func addAction(title: String, style: UIAlertActionStyle = .default, isMainAction: Bool = false, handler: ((UIButton) -> Swift.Void)? = nil) {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor("#F9F7FF")
        if style == .destructive {
            button.setTitleColor(UIColor.red100(), for: .normal)
        } else {
            button.setTitleColor(UIColor.purple400(), for: .normal)
        }
        
        if isMainAction {
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: button.titleLabel?.font.pointSize ?? 1)
        }
        
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    
        button.tag = buttons.count
        if let action = handler {
            buttonHandlers[button.tag] = action
        }
        buttons.append(button)
        if buttonStackView != nil {
            buttonStackView.addArrangedSubview(button)
            if buttonStackView.arrangedSubviews.count > 2 {
                buttonStackView.axis = .vertical
            }
        }
    }
    
    func setCloseAction(title: String, handler: @escaping (() -> Void)) {
        closeAction = handler
        closeTitle = title
    }
    
    private func configureTitleView() {
        if titleLabel != nil {
            titleLabel.text = title
        }
        if title == nil && titleLabelTopMargin != nil && titleLabelBottomMargin != nil {
            titleLabelTopMargin.constant = 0
            titleLabelBottomMargin.constant = 0
        } else if titleLabelTopMargin != nil && titleLabelBottomMargin != nil {
            titleLabelTopMargin.constant = 12
            titleLabelBottomMargin.constant = 12
        }
    }
    
    private func configureMessageView() {
        if message == nil || containerView == nil {
            return
        }
        let label = UILabel()
        label.text = message
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.gray100()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        contentView = label
        titleLabelBackground.backgroundColor = .white
    }
    
    private func configureContentView() {
        if containerView == nil {
            return
        }
        if contentView == nil && message == nil {
            containerView.superview?.isHidden = true
            alertStackView.spacing = 0
        } else {
            containerView.superview?.isHidden = false
            alertStackView.spacing = 24
        }
        if let view = containerView.arrangedSubviews.first {
            view.removeFromSuperview()
        }
        if let view = contentView {
            self.containerView.addArrangedSubview(view)
        }
    }
    
    private func configureCloseButton() {
        if closeButton != nil {
            closeButton.isHidden = closeAction == nil
            closeButton.setTitle(closeTitle, for: .normal)
        }
    }
    
    private func configureButtons() {
        buttonStackView.arrangedSubviews.forEach { (view) in
            view.removeFromSuperview()
        }
        for button in buttons {
            buttonStackView.addArrangedSubview(button)
        }
        if buttons.count > 2 {
            buttonStackView.axis = .vertical
        } else {
            buttonStackView.axis = .horizontal
        }
    }
    
    func show() {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            self.modalTransitionStyle = .crossDissolve
            self.modalPresentationStyle = .overCurrentContext
            topController.present(self, animated: true) {
            }
        }
    }
    
    func buttonTapped(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
        buttonHandlers[button.tag]?(button)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        if let action = closeAction {
            action()
        }
    }
}

extension HabiticaAlertController {
    public static func alert(title: String? = nil,
                             message: String? = nil) -> HabiticaAlertController {
        let alertController = HabiticaAlertController(
            title: title,
            message: message
        )
        return alertController
    }
    
    public static func genericError(message: String?, title: String = NSLocalizedString("Error", comment: "")) -> HabiticaAlertController {
        let alertController = HabiticaAlertController(
            title: title,
            message: message
        )
        alertController.addOkAction()
        
        return alertController
    }
    
    func addCancelAction(handler: ((UIButton) -> Void)? = nil) {
        self.addAction(title: NSLocalizedString("Cancel", comment: ""), handler: handler)
    }
    
    func addOkAction(handler: ((UIButton) -> Void)? = nil) {
        self.addAction(title: NSLocalizedString("OK", comment: ""), handler: handler)
    }
}
