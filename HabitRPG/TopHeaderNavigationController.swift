//
//  TopHeaderNavigationController.swift
//  Habitica
//
//  Created by Phillip Thelen on 15.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

@objc
enum TopHeaderState: Int {
    case visible = 0
    case hidden = 1
    case scrolling = 2
}

@objc
protocol TopHeaderNavigationControllerProtocol: AnyObject {
    @objc var state: TopHeaderState { get set }
    @objc var defaultNavbarVisibleColor: UIColor { get }
    @objc var navbarVisibleColor: UIColor { get set }
    @objc var hideNavbar: Bool { get set }
    @objc var shouldHideTopHeader: Bool { get set }
    @objc var contentInset: CGFloat { get }
    @objc var contentOffset: CGFloat { get }
    @objc weak var currentHeaderCoordinator: TopHeaderCoordinator? { get set }

    @objc
    func setShouldHideTopHeader(_ shouldHide: Bool, animated: Bool)
    @objc
    func showHeader(animated: Bool)
    @objc
    func hideHeader(animated: Bool)
    @objc
    func startFollowing(scrollView: UIScrollView)
    @objc
    func stopFollowingScrollView()
    @objc
    func setAlternativeHeaderView(_ alternativeHeaderView: UIView?)
    @objc
    func removeAlternativeHeaderView()
    @objc
    func scrollView(_ scrollView: UIScrollView?, scrolledToPosition position: CGFloat)
    @objc
    func setNavigationBarColors()
}

class TopHeaderViewController: UINavigationController, TopHeaderNavigationControllerProtocol, Themeable {
    @objc public var state: TopHeaderState = .visible
    @objc public var defaultNavbarVisibleColor = ThemeService.shared.theme.contentBackgroundColor
    private var headerView: UIView?
    private var alternativeHeaderView: UIView?
    private let backgroundView = UIView()
    private let upperBackgroundView = UIView()
    
    private var scrollableView: UIScrollView?
    @objc weak var currentHeaderCoordinator: TopHeaderCoordinator?
    private var gestureRecognizer: UIPanGestureRecognizer?
    private var headerYPosition: CGFloat = 0
    private var headerXPosition: CGFloat?

    private var visibleTintColor = UIColor.gray50
    private var visibleTextColor = UIColor.black

    @objc public var navbarVisibleColor: UIColor = UIColor.white {
        didSet {
            let isVisibleLightColor = navbarVisibleColor.isLight()
            if ThemeService.shared.theme.isDark {
                visibleTintColor = ThemeService.shared.theme.primaryTextColor
            } else {
                visibleTintColor = isVisibleLightColor ? ThemeService.shared.theme.primaryTextColor : UIColor.white
            }
            visibleTextColor = isVisibleLightColor ? UIColor.black : UIColor.white
            setNavigationBarColors()
        }
    }
    
    @objc public var hideNavbar = false {
        didSet {
            setNavigationBarHidden(hideNavbar, animated: false)
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
    
    @objc var shouldHideTopHeader: Bool = false {
        willSet {
            if shouldHideTopHeader != newValue {
                if newValue {
                    hideHeader()
                } else {
                    showHeader()
                }
                view.setNeedsLayout()
                view.layoutIfNeeded()
            }
        }
    }
    
    var topHeaderHeight: CGFloat {
        if self.alternativeHeaderView != nil {
            return alternativeHeaderHeight
        } else {
            return defaultHeaderHeight
        }
    }
    
    var defaultHeaderHeight: CGFloat {
        var height: CGFloat
        if UIDevice.current.userInterfaceIdiom == .pad {
            height = 190
        } else {
            height = 152
        }
        let actualSize = UIFontMetrics.default.scaledValue(for: 11)
        return height + (actualSize - 11) * 5
    }
    
    var bgViewOffset: CGFloat {
        if hideNavbar {
            return self.statusBarHeight
        } else {
            return self.statusBarHeight + self.navigationBar.frame.size.height
        }
    }
    
    var statusBarHeight: CGFloat {
        return UIApplication.shared.findKeyWindow()?.safeAreaInsets.top ?? 0
    }
    
    @objc public var contentInset: CGFloat {
        if self.shouldHideTopHeader {
           return 0
        }
        // iphones with dynamic island need this for some reason
        if statusBarHeight == 59 || statusBarHeight == 62 {
            return topHeaderHeight + 22
        }
        return self.topHeaderHeight + 12
   }
    
     @objc public var contentOffset: CGFloat {
        if (self.backgroundView.frame.origin.y + self.backgroundView.frame.size.height) < self.bgViewOffset {
            return 0
        }
        if self.shouldHideTopHeader {
            return 0
        }
        return self.backgroundView.frame.size.height + contentInset
    }
    
    private var navbarColorBlendingAlpha: CGFloat {
        return -((self.backgroundView.frame.origin.y - self.bgViewOffset) / self.backgroundView.frame.size.height)
    }
    
    private var alternativeHeaderHeight: CGFloat {
        guard let header = alternativeHeaderView else {
            return 0
        }
        let intrinsicHeight = header.intrinsicContentSize.height
        if intrinsicHeight <= 0 {
            return header.frame.size.height
        } else {
            return intrinsicHeight
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        view.backgroundColor = .clear
        navigationBar.backgroundColor = .clear
        
        let nibViews = Bundle.main.loadNibNamed("UserTopHeader", owner: self, options: nil)
        headerView = nibViews?[0] as? UIView
        if let headerView = headerView {
            backgroundView.addSubview(headerView)
        }
        
        view.insertSubview(upperBackgroundView, belowSubview: navigationBar)
        view.insertSubview(backgroundView, belowSubview: upperBackgroundView)
        
        headerYPosition = bgViewOffset
        
        ThemeService.shared.addThemeable(themable: self, applyImmediately: true)
    }

    func applyTheme(theme: Theme) {
        if defaultNavbarVisibleColor == navbarVisibleColor {
            navbarVisibleColor = theme.contentBackgroundColor
        }
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: theme.primaryTextColor,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .semibold),
            NSAttributedString.Key.kern: 0.6
        ]
        defaultNavbarVisibleColor = theme.contentBackgroundColor
        visibleTintColor = theme.primaryTextColor

        setNavigationBarColors()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let parentFrame = view.frame
        let topHeaderHeight = self.topHeaderHeight
        let width = parentFrame.size.width + parentFrame.origin.x
        backgroundView.frame = CGRect(x: headerXPosition ?? -parentFrame.origin.x, y: headerYPosition, width: width, height: topHeaderHeight)
        upperBackgroundView.frame = CGRect(x: -parentFrame.origin.x, y: 0, width: width, height: bgViewOffset)
        let safeLeft = view.safeAreaInsets.left
        let safeRight = view.safeAreaInsets.right
        headerView?.frame = CGRect(x: safeLeft, y: 0, width: width - safeLeft - safeRight, height: defaultHeaderHeight)
        if let header = alternativeHeaderView {
            if topHeaderHeight <= 0 {
                header.frame = CGRect(x: -parentFrame.origin.x, y: 0, width: width, height: header.frame.size.height)
            } else {
                header.frame = CGRect(x: -parentFrame.origin.x, y: 0, width: width, height: topHeaderHeight)
            }
        }
        
        if let scrollView = currentHeaderCoordinator?.scrollView, currentHeaderCoordinator?.followScrollView == true {
            if scrollView.contentInset.top != contentInset {
                let modInset = currentHeaderCoordinator?.contentInsetModifier ?? .zero
                let existingInsets = scrollView.contentInset
                var insets = UIEdgeInsets(top: contentInset, left: modInset.left, bottom: modInset.bottom, right: modInset.right)
                if existingInsets.bottom != 0 {
                    insets = UIEdgeInsets(top: contentInset + (existingInsets.top - contentInset), left: 0, bottom: existingInsets.bottom, right: 0)
                }
                scrollView.contentInset = insets
                scrollView.scrollIndicatorInsets = insets
            }
        }
    }
    
    @objc
    public func setShouldHideTopHeader(_ shouldHide: Bool, animated: Bool) {
        if shouldHideTopHeader != shouldHide {
            shouldHideTopHeader = shouldHide
            if shouldHide {
                hideHeader(animated: animated)
            } else {
                showHeader(animated: animated)
                view.setNeedsLayout()
                view.layoutIfNeeded()
            }
        }
    }
    
    @objc
    public func showHeader(animated: Bool = true) {
        self.state = .visible
        var frame = backgroundView.frame
        frame.origin.y = self.bgViewOffset
        self.headerYPosition = frame.origin.y
        UIView.animate(withDuration: animated ? 0.3 : 0.0, delay: 0, options: .curveEaseInOut, animations: {
            self.setNewFrame(frame)
        }, completion: nil)
    }
    
    @objc
    public func hideHeader(animated: Bool = true) {
        self.state = .hidden
        var frame = backgroundView.frame
        frame.origin.y = -topHeaderHeight
        self.headerYPosition = frame.origin.y
        UIView.animate(withDuration: animated ? 0.3 : 0.0, delay: 0, options: .curveEaseInOut, animations: {
            self.setNewFrame(frame)
        }, completion: nil)
    }
    
    func setNewFrame(_ frame: CGRect) {
        self.backgroundView.frame = frame
    }
    
    @objc
    public func startFollowing(scrollView: UIScrollView) {
        if self.scrollableView != nil {
            self.stopFollowingScrollView()
        }
        self.scrollableView = scrollView
    }
    
    @objc
    public func stopFollowingScrollView() {
        if let recognizer = gestureRecognizer {
            self.scrollableView?.removeGestureRecognizer(recognizer)
        }
        self.gestureRecognizer = nil
        self.scrollableView = nil
    }
    
    var lastScrollPos: CGFloat = -1
    
    @objc
    public func scrollView(_ scrollView: UIScrollView?, scrolledToPosition position: CGFloat) {
        if self.scrollableView != scrollView {
            return
        }
        var frame = backgroundView.frame
        var newYPos = -position - frame.size.height
        if newYPos > bgViewOffset {
            newYPos = bgViewOffset
        }
        if currentHeaderCoordinator?.scrollMode == .slide {
            if (newYPos + frame.size.height) > bgViewOffset, state != .visible {
                state = .visible
            } else if state != .hidden {
                state = .hidden
            }
            frame.origin.y = newYPos
        } else if currentHeaderCoordinator?.scrollMode == .scale {
            backgroundView.layer.anchorPoint = CGPoint(x: -0.5, y: 0)
            let navbarHeight = navigationBar.frame.height
            let viewPos = max(newYPos, bgViewOffset-navbarHeight + 6)
            frame.origin.y = viewPos
            if viewPos != newYPos {
                let newSize = max(frame.height - abs(newYPos - viewPos), navbarHeight - 12)
                let scale = newSize / frame.height
                backgroundView.transform = CGAffineTransform(scaleX: scale, y: scale)
                headerXPosition = (frame.size.width - frame.size.width * scale)/2
            } else {
                backgroundView.transform = CGAffineTransform(scaleX: 1, y: 1)
                headerXPosition = 0
            }
        }
        headerYPosition = frame.origin.y
        backgroundView.frame = frame
        
        lastScrollPos = position
    }
    
    @objc
    public func setNavigationBarColors() {
        if navbarVisibleColor != defaultNavbarVisibleColor {
            upperBackgroundView.backgroundColor = navbarVisibleColor
            backgroundView.backgroundColor = .clear
        } else if #unavailable(iOS 26.0) {
            upperBackgroundView.backgroundColor = navbarVisibleColor
            backgroundView.backgroundColor = navbarVisibleColor
        } else {
            if topViewController is MainMenuViewController {
                // in Dark mode the special header needs to be taken into account
                upperBackgroundView.backgroundColor = navbarVisibleColor
                backgroundView.backgroundColor = navbarVisibleColor
            } else {
                backgroundView.backgroundColor = .clear
                upperBackgroundView.backgroundColor = .clear
            }
        }
        
        let tintColor = visibleTintColor
        navigationBar.tintColor = tintColor
        topViewController?.navigationItem.leftBarButtonItems?.forEach({ (button) in
            button.tintColor = tintColor
        })
        topViewController?.navigationItem.rightBarButtonItems?.forEach({ (button) in
            button.tintColor = tintColor
        })
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if upperBackgroundView.backgroundColor == .clear {
            return ThemeService.shared.theme.isDark ? .lightContent : .darkContent
        }
        let isLightColor = self.upperBackgroundView.backgroundColor?.isLight() ?? true
        if upperBackgroundView.backgroundColor == .white && ThemeService.shared.theme.isDark {
            // For some reason when forcing dark mode, the statusbar style is requested before the theme is applied
            return .lightContent
        }
        if !isLightColor {
            return .lightContent
        } else {
            return .darkContent
        }
    }
    
    @objc
    public func setAlternativeHeaderView(_ alternativeHeaderView: UIView?) {
        self.removeAlternativeHeaderView()
        self.alternativeHeaderView = alternativeHeaderView
        self.headerView?.removeFromSuperview()
        if let header = self.alternativeHeaderView {
            self.backgroundView.addSubview(header)
            header.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: alternativeHeaderHeight)
            header.alpha = 1
            header.layoutSubviews()
        }
        viewWillLayoutSubviews()
    }
    
    @objc
    public func removeAlternativeHeaderView() {
        if self.alternativeHeaderView == nil {
            return
        }
        self.alternativeHeaderView?.removeFromSuperview()
        self.alternativeHeaderView = nil
        if let header = self.headerView {
            self.backgroundView.addSubview(header)
        }
        viewWillLayoutSubviews()
    }
}
