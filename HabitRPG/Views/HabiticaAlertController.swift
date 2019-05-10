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
class HabiticaAlertController: UIViewController, Themeable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelTopMargin: NSLayoutConstraint!
    @IBOutlet weak var titleLabelBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var titleLabelBackground: UIView!
    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var alertStackView: UIStackView!
    @IBOutlet weak var bottomOffsetConstraint: NSLayoutConstraint!
    @IBOutlet var centerConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonBackgroundView: UIView!
    @IBOutlet weak var alertBackgroundView: UIView!
    @IBOutlet weak var buttonContainerView: UIView!
    
    private var buttonHandlers = [Int: ((UIButton) -> Swift.Void)]()
    private var buttons = [UIButton]()
    private var shouldCloseOnButtonTap = [Int: Bool]()
    
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
    
    var titleBackgroundColor: UIColor = ThemeService.shared.theme.contentBackgroundColor {
        didSet {
            configureTitleView()
        }
    }
    
    var message: String? {
        didSet {
            if message == nil || self.view == nil {
                return
            }
            attributedMessage = nil
            titleBackgroundColor = ThemeService.shared.theme.contentBackgroundColor
            configureMessageView()
        }
    }
    
    var attributedMessage: NSAttributedString? {
        didSet {
            if attributedMessage == nil || self.view == nil {
                return
            }
            message = nil
            titleBackgroundColor = ThemeService.shared.theme.contentBackgroundColor
            configureMessageView()
        }
    }
    
    var closeAction: (() -> Void)? {
        didSet {
            configureCloseButton()
        }
    }
    
    var contentViewInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) {
        didSet {
            if containerView != nil {
                containerView.layoutMargins = contentViewInsets
                containerView.isLayoutMarginsRelativeArrangement = true
            }
        }
    }
    
    var containerViewSpacing: CGFloat = 24 {
        didSet {
            if containerView != nil {
                containerView.spacing = containerViewSpacing
            }
        }
    }
    
    var closeTitle: String?
    
    convenience init(title newTitle: String?, message newMessage: String? = nil) {
        self.init()
        self.title = newTitle
        self.message = newMessage
    }
    
    convenience init(title newTitle: String?, attributedMessage newMessage: NSAttributedString) {
        self.init()
        self.title = newTitle
        self.attributedMessage = newMessage
    }
    
    init() {
        super.init(nibName: "HabiticaAlertController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ThemeService.shared.addThemeable(themable: self, applyImmediately: true)
    }
    
    func applyTheme(theme: Theme) {
        view.backgroundColor = theme.dimmBackgroundColor.withAlphaComponent(0.7)
        buttonContainerView.backgroundColor = theme.contentBackgroundColor
        buttonBackgroundView.backgroundColor = theme.tintColor.withAlphaComponent(0.05)
        alertBackgroundView.backgroundColor = theme.contentBackgroundColor
        closeButton.backgroundColor = theme.contentBackgroundColor
        
        titleLabel.textColor = theme.primaryTextColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTitleView()
        configureContentView()
        configureMessageView()
        configureCloseButton()
        configureButtons()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        super.viewWillDisappear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        let height = containerView.frame.size.height
        var maximumHeight = view.frame.size.height
        if #available(iOS 11.0, *) {
            let guide = view.safeAreaLayoutGuide
            maximumHeight = guide.layoutFrame.size.height
        }
        maximumHeight -= 32 + 140
        if height > maximumHeight {
            scrollviewHeightConstraint.constant = maximumHeight
        } else {
            scrollviewHeightConstraint.constant = height
        }
        super.viewWillLayoutSubviews()
    }
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.bottomOffsetConstraint.constant = keyboardHeight + 8
            if self.centerConstraint.isActive {
                self.centerConstraint.isActive = false
            }
        }
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        self.bottomOffsetConstraint.constant = 16
        if !self.centerConstraint.isActive {
            self.centerConstraint.isActive = true
        }
        
    }
    
    @objc
    func addAction(title: String, style: UIAlertAction.Style = .default, isMainAction: Bool = false, closeOnTap: Bool = true, identifier: String? = nil, handler: ((UIButton) -> Swift.Void)? = nil) {
        let button = UIButton()
        if let identifier = identifier {
            button.accessibilityIdentifier = identifier
        }
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.setTitle(title, for: .normal)
        if style == .destructive {
            button.setTitleColor(ThemeService.shared.theme.errorColor, for: .normal)
        } else {
            button.setTitleColor(ThemeService.shared.theme.tintColor, for: .normal)
        }
        
        if isMainAction {
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: button.titleLabel?.font.pointSize ?? 1)
        }
        
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    
        button.tag = buttons.count
        if let action = handler {
            buttonHandlers[button.tag] = action
        }
        shouldCloseOnButtonTap[button.tag] = closeOnTap
        buttons.append(button)
        if buttonStackView != nil {
            buttonStackView.addArrangedSubview(button)
            if buttonStackView.arrangedSubviews.count > 2 {
                buttonStackView.axis = .vertical
            }
        }
    }
    
    @objc
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
        if titleLabelBackground != nil {
            titleLabelBackground.backgroundColor = titleBackgroundColor
        }
    }
    
    private func configureMessageView() {
        if (message == nil && attributedMessage == nil) || containerView == nil {
            return
        }
        let label = UILabel()
        label.textColor = ThemeService.shared.theme.secondaryTextColor
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 15)
        if message != nil {
            label.text = message
        } else {
            label.attributedText = attributedMessage
        }
        label.numberOfLines = 0
        label.textAlignment = .center
        containerView.insertArrangedSubview(label, at: 0)
    }
    
    private func configureContentView() {
        if containerView == nil {
            return
        }
        containerView.layoutMargins = contentViewInsets
        containerView.isLayoutMarginsRelativeArrangement = true
        if contentView == nil && message == nil {
            containerView.superview?.isHidden = true
            alertStackView.spacing = 0
        } else {
            containerView.superview?.isHidden = false
            alertStackView.spacing = containerViewSpacing
        }
        if let view = contentView {
            if let oldView = containerView.arrangedSubviews.first {
                oldView.removeFromSuperview()
            }
            self.containerView.addArrangedSubview(view)
        }
    }
    
    private func configureCloseButton() {
        if closeButton != nil {
            closeButton.isHidden = closeAction == nil
            closeButton.setTitle(closeTitle, for: .normal)
            closeButton.tintColor = ThemeService.shared.theme.tintColor
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
    
    @objc
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
    
    @objc
    func buttonTapped(_ button: UIButton) {
        if shouldCloseOnButtonTap[button.tag] != false {
        self.dismiss(animated: true, completion: {
            self.buttonHandlers[button.tag]?(button)
        })
        } else {
            self.buttonHandlers[button.tag]?(button)
        }
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        if let action = closeAction {
            action()
        }
    }
}

extension HabiticaAlertController {
    @objc
    public static func alert(title: String? = nil,
                             message: String? = nil) -> HabiticaAlertController {
        let alertController = HabiticaAlertController(
            title: title,
            message: message
        )
        return alertController
    }
    
    @objc
    public static func alert(title: String? = nil,
                             attributedMessage: NSAttributedString) -> HabiticaAlertController {
        let alertController = HabiticaAlertController(
            title: title,
            attributedMessage: attributedMessage
        )
        return alertController
    }
    
    @objc
    public static func genericError(message: String?, title: String = L10n.Errors.error) -> HabiticaAlertController {
        let alertController = HabiticaAlertController(
            title: title,
            message: message
        )
        alertController.addOkAction()
        
        return alertController
    }
    
    @objc
    func addCancelAction(handler: ((UIButton) -> Void)? = nil) {
        self.addAction(title: L10n.cancel, identifier: "Cancel", handler: handler)
    }
    
    @objc
    func addCloseAction(handler: ((UIButton) -> Void)? = nil) {
        self.addAction(title: L10n.close, identifier: "Close", handler: handler)
    }
    
    @objc
    func addShareAction(handler: ((UIButton) -> Void)? = nil) {
        self.addAction(title: L10n.share, isMainAction: true, closeOnTap: false, handler: handler)
    }
    
    @objc
    func addOkAction(handler: ((UIButton) -> Void)? = nil) {
        self.addAction(title: L10n.ok, handler: handler)
    }
}
