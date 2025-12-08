//
//  BaseAlertController.swift
//  Habitica
//
//  Created by Phillip on 23.10.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit

@objc
class HabiticaAlertController: UIViewController, Themeable {
    @IBOutlet weak var backgroundView: UIVisualEffectView!
    @IBOutlet weak var topOffsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var textStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var alertStackView: UIStackView!
    @IBOutlet weak var bottomOffsetConstraint: NSLayoutConstraint!
    @IBOutlet var centerConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollviewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonUpperSpacing: NSLayoutConstraint!
    @IBOutlet weak var buttonLowerSpacing: NSLayoutConstraint!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    private var buttonHandlers = [Int: ((UIButton) -> Swift.Void)]()
    private var buttons = [UIButton]()
    private var shouldCloseOnButtonTap = [Int: Bool]()
    
    var dismissOnBackgroundTap = true
    var maxAlertWidth: CGFloat = 340
    
    var onKeyboardChange: ((Bool) -> Void)?
    var onDismissAction: (() -> Void)?
    
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
    
    var attributedTitle: NSAttributedString? {
        didSet {
            if attributedTitle == nil || self.view == nil {
                return
            }
            attributedMessage = nil
            configureTitleView()
        }
    }
    
    var message: String? {
        didSet {
            if message == nil || self.view == nil {
                return
            }
            attributedMessage = nil
            configureMessageView()
        }
    }
    
    var attributedMessage: NSAttributedString? {
        didSet {
            if attributedMessage == nil || self.view == nil {
                return
            }
            message = nil
            configureMessageView()
        }
    }
    
    var messageFont = UIFontMetrics.default.scaledSystemFont(ofSize: 17)
    var messageColor: UIColor?
    var messageView: UILabel?
    
    var arrangeMessageLast = false
    
    var contentViewInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14) {
        didSet {
            if containerView != nil {
                containerView.layoutMargins = contentViewInsets
            }
        }
    }
    
    var containerViewSpacing: CGFloat = 24
    var topOffset: CGFloat = 20
        
    convenience init(attributedTitle newTitle: NSAttributedString?, message newMessage: String? = nil) {
        self.init()
        attributedTitle = newTitle
        message = newMessage
    }
    
    convenience init(attributedTitle newTitle: NSAttributedString?, attributedMessage newMessage: NSAttributedString) {
        self.init()
        attributedTitle = newTitle
        attributedMessage = newMessage
    }
    
    convenience init(title newTitle: String?, message newMessage: String? = nil) {
        self.init()
        title = newTitle
        message = newMessage
    }
    
    convenience init(title newTitle: String?, attributedMessage newMessage: NSAttributedString) {
        self.init()
        title = newTitle
        attributedMessage = newMessage
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
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped)))
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(alertTapped)))
    
        KeyboardManager.addObservingView(view)
        if #available(iOS 26.0, *) {
            let effect = UIGlassEffect(style: .clear)
            effect.tintColor = ThemeService.shared.theme.contentBackgroundColor.withAlphaComponent(0.9)
            backgroundView.effect = effect
        }
    }
    
    func applyTheme(theme: Theme) {
        view.backgroundColor = theme.dimmBackgroundColor.withAlphaComponent(0.2)
        titleLabel.textColor = theme.primaryTextColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureTitleView()
        configureContentView()
        configureMessageView()
        configureButtons()
        scrollView.alwaysBounceVertical = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        super.viewWillDisappear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        topOffsetConstraint.constant = topOffset
        var maximumSize = view.frame.size
        let guide = view.safeAreaLayoutGuide
        maximumSize = guide.layoutFrame.size
        maximumSize.width = min(maxAlertWidth, maximumSize.width - 32)
        widthConstraint.constant = maximumSize.width
        maximumSize.width -= contentViewInsets.left + contentViewInsets.right
        maximumSize.height -= contentViewInsets.top + contentViewInsets.bottom
        let maximumHeight = maximumSize.height - (32 + 140) - buttonUpperSpacing.constant - buttonLowerSpacing.constant - KeyboardManager.height - CGFloat(buttons.count * 48)
        var contentHeight = contentView?.systemLayoutSizeFitting(maximumSize).height ?? 0
        let intrinsicSize = contentView?.intrinsicContentSize.height ?? 0
        if contentHeight == 0 || (intrinsicSize > 0 && intrinsicSize < contentHeight) {
            contentHeight = contentView?.intrinsicContentSize.height ?? 0
        }
        var height = contentHeight + contentViewInsets.top + contentViewInsets.bottom
        if let messageView = messageView {
            if height > 0 {
                height += containerViewSpacing
            }
            height += messageView.sizeThatFits(maximumSize).height
        }
        scrollviewHeightConstraint.constant = min(height, maximumHeight)
        if arrangeMessageLast {
            if let contentView = contentView {
                contentView.pin.top(contentViewInsets.top).left(contentViewInsets.left).width(maximumSize.width).height(contentHeight)
                messageView?.pin.top(contentHeight + containerViewSpacing).left(contentViewInsets.left).width(maximumSize.width).sizeToFit(.width)
            } else {
                messageView?.pin.top(contentViewInsets.top).left(contentViewInsets.left).width(maximumSize.width).height(height)
            }
        } else {
            if let messageView = messageView {
                messageView.pin.top(contentViewInsets.top).left(contentViewInsets.left).width(maximumSize.width).sizeToFit(.width)
                contentView?.pin.below(of: messageView).marginTop(containerViewSpacing).left(contentViewInsets.left).width(maximumSize.width).height(contentHeight)
            } else {
                contentView?.pin.top(contentViewInsets.top).left(contentViewInsets.left).width(maximumSize.width).height(contentHeight)
            }
        }
        containerViewHeightConstraint.constant = height
        contentView?.updateConstraints()
    }
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.bottomOffsetConstraint.constant = keyboardHeight + 8
            if centerConstraint.isActive {
                centerConstraint.isActive = false
            }
        }
        if let action = onKeyboardChange {
            action(true)
        }
    }
    
    @objc
    func keyboardWillHide(notification: NSNotification) {
        self.bottomOffsetConstraint.constant = 16
        if !centerConstraint.isActive {
            centerConstraint.isActive = true
        }
        if let action = onKeyboardChange {
            action(false)
        }
    }
    
    @objc
    @discardableResult
    func addAction(title: String,
                   style: UIAlertAction.Style = .default,
                   isMainAction: Bool = false,
                   closeOnTap: Bool = true,
                   identifier: String? = nil,
                   handler: ((UIButton) -> Swift.Void)? = nil) -> UIButton {
        let button = UIButton()
        if let identifier = identifier {
            button.accessibilityIdentifier = identifier
        }
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.textAlignment = .center
        button.setTitle(title, for: .normal)
        var color = isMainAction ? ThemeService.shared.theme.fixedTintColor : ThemeService.shared.theme.tintColor
        if style == .destructive {
            color = ThemeService.shared.theme.errorColor
        }
        
        button.titleLabel?.font = UIFontMetrics.default.scaledSystemFont(ofSize: 17, ofWeight: .medium)
        if isMainAction {
            button.setTitleColor(UIColor.white, for: .normal)
            if #available(iOS 26.0, *) {
                button.cornerConfiguration = .capsule()
                button.configuration = .prominentGlass()
                button.tintColor = color
            } else {
                button.backgroundColor = color
                button.cornerRadius = 8
                button.layer.shadowColor = ThemeService.shared.theme.buttonShadowColor.cgColor
                button.layer.shadowRadius = 2
                button.layer.shadowOffset = CGSize(width: 1, height: 1)
                button.layer.shadowOpacity = 0.5
                button.layer.masksToBounds = false
            }
        } else {
            if #available(iOS 26.0, *) {
                button.cornerConfiguration = .capsule()
                button.configuration = .prominentGlass()
                button.tintColor = UIColor("787880").withAlphaComponent(0.05)
            }
            button.setTitleColor(ThemeService.shared.theme.primaryTextColor, for: .normal)
        }

        button.addHeightConstraint(height: 48, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual)
        button.addWidthConstraint(width: 150, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual)
        
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    
        button.isPointerInteractionEnabled = true
        
        button.tag = buttons.count
        if let action = handler {
            buttonHandlers[button.tag] = action
        }
        shouldCloseOnButtonTap[button.tag] = closeOnTap
        buttons.append(button)
        return button
    }
    
    private func configureTitleView() {
        if titleLabel != nil {
            if title != nil {
                titleLabel.text = title
            } else {
                titleLabel.attributedText = attributedTitle
            }
            checkTextStackHidden()
        }
    }
    
    private func configureMessageView() {
        if message == nil && attributedMessage == nil {
            subtitleLabel.isHidden = true
            return
        }
        subtitleLabel.isHidden = false
        if message != nil {
            subtitleLabel.text = message
        } else {
            subtitleLabel.attributedText = attributedMessage
        }
        checkTextStackHidden()
        subtitleLabel.textColor = messageColor ?? ThemeService.shared.theme.primaryTextColor
    }
    
    private func checkTextStackHidden() {
        if title?.isEmpty != false
            && attributedTitle?.string.isEmpty != false
            && message?.isEmpty != false
            && attributedMessage?.string.isEmpty != false {
            textStackView.isHidden = true
        } else {
            textStackView.isHidden = false
        }
    }
    
    private func configureContentView() {
        if containerView == nil {
            return
        }
        containerView.layoutMargins = contentViewInsets
        if contentView == nil && message == nil {
            containerView.superview?.isHidden = true
            alertStackView.spacing = containerViewSpacing
        } else {
            containerView.superview?.isHidden = false
            alertStackView.spacing = containerViewSpacing
        }
        if let view = contentView {
            if let oldView = containerView.subviews.first {
                oldView.removeFromSuperview()
            }
            containerView.addSubview(view)
        }
    }
    
    private func configureButtons() {
        buttonStackView.arrangedSubviews.forEach { (view) in
            view.removeFromSuperview()
        }
        for button in buttons {
            buttonStackView.addArrangedSubview(button)
        }
    }
    
    @objc
    func show() {
        if var topController = UIApplication.topViewController() {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            while let parent = topController.parent {
                topController = parent
            }
            modalTransitionStyle = .crossDissolve
            modalPresentationStyle = .overFullScreen
            topController.present(self, animated: true) {
            }
        }
    }
    
    @objc
    func enqueue() {
        HabiticaAlertController.addToQueue(alert: self)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        HabiticaAlertController.showNextInQueue(currentAlert: self)
        if let action = onDismissAction {
            action()
        }
    }
    
    @objc
    func buttonTapped(_ button: UIButton) {
        if shouldCloseOnButtonTap[button.tag] != false {
        dismiss(animated: true, completion: {[weak self] in
            self?.buttonHandlers[button.tag]?(button)
        })
        } else {
            buttonHandlers[button.tag]?(button)
        }
    }
    
    @objc
    func backgroundTapped() {
        if dismissOnBackgroundTap {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc
    func alertTapped() {
        // if the alert is tapped, it should not be dismissed
    }
    
    private static var alertQueue = [HabiticaAlertController]()
    
    private static func showNextInQueue(currentAlert: HabiticaAlertController) {
        if alertQueue.first == currentAlert {
            alertQueue.removeFirst()
        }
        if !alertQueue.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if alertQueue[0].presentingViewController == nil {
                    alertQueue[0].show()
                }
            }
        }
    }
    
    private static func addToQueue(alert: HabiticaAlertController) {
        if alertQueue.isEmpty {
            alert.show()
        }
        alertQueue.append(alert)
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
        alertController.addCloseAction(isMainAction: true)
        
        return alertController
    }
    
    @objc
    func addCancelAction(handler: ((UIButton) -> Void)? = nil) {
        addAction(title: L10n.cancel, identifier: "Cancel", handler: handler)
    }
    
    @objc
    func addCloseAction(isMainAction: Bool = false, handler: ((UIButton) -> Void)? = nil) {
        addAction(title: L10n.close, isMainAction: isMainAction, identifier: "Close", handler: handler)
    }
    
    @objc
    func addShareAction(isMainAction: Bool = false, handler: ((UIButton) -> Void)? = nil) {
        addAction(title: L10n.share, isMainAction: isMainAction, closeOnTap: false, handler: handler)
    }
    
    @objc
    func addOkAction(isMainAction: Bool = false, handler: ((UIButton) -> Void)? = nil) {
        addAction(title: L10n.ok, isMainAction: isMainAction, handler: handler)
    }
}
