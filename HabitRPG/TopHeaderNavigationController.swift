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
protocol TopHeaderNavigationControllerProtocol: class {
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
    @objc public var defaultNavbarHiddenColor = UIColor.purple300
    @objc public var defaultNavbarVisibleColor = ThemeService.shared.theme.contentBackgroundColor
    private var headerView: UIView?
    private var alternativeHeaderView: UIView?
    private let backgroundView = UIView()
    private let bottomBorderView = UIView()
    private let upperBackgroundView = UIView()
    
    private var scrollableView: UIScrollView?
    @objc weak var currentHeaderCoordinator: TopHeaderCoordinator?
    private var gestureRecognizer: UIPanGestureRecognizer?
    private var headerYPosition: CGFloat = 0
    
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
        if UI_USER_INTERFACE_IDIOM() == .pad {
            return 190
        } else {
            return 152
        }
    }
    
    var bgViewOffset: CGFloat {
        if hideNavbar {
            return self.statusBarHeight
        } else {
            return self.statusBarHeight + self.navigationBar.frame.size.height
        }
    }
    
    var statusBarHeight: CGFloat {
        let statusBarSize = UIApplication.shared.statusBarFrame.size
        return min(statusBarSize.width, statusBarSize.height)
    }
    
     @objc public var contentInset: CGFloat {
        if self.shouldHideTopHeader {
            return 0
        }
        return self.topHeaderHeight + self.bottomBorderView.frame.size.height
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
        backgroundView.addSubview(bottomBorderView)
        
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
        defaultNavbarHiddenColor = theme.navbarHiddenColor
        defaultNavbarVisibleColor = theme.contentBackgroundColor
        visibleTintColor = theme.primaryTextColor
        bottomBorderView.backgroundColor = theme.contentBackgroundColor
        backgroundView.backgroundColor = theme.contentBackgroundColor
        upperBackgroundView.backgroundColor = theme.contentBackgroundColor
        setNavigationBarColors()
        updateStatusbarColor()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let parentFrame = view.frame
        let topHeaderHeight = self.topHeaderHeight
        backgroundView.frame = CGRect(x: 0.0, y: headerYPosition, width: parentFrame.size.width, height: topHeaderHeight + 2)
        upperBackgroundView.frame = CGRect(x: 0, y: 0, width: parentFrame.size.width, height: bgViewOffset)
        bottomBorderView.frame = CGRect(x: 0, y: backgroundView.frame.size.height - 2, width: parentFrame.size.width, height: 2)
        bottomBorderView.frame = CGRect(x: 0, y: backgroundView.frame.size.height - 2, width: parentFrame.size.width, height: 2)
        headerView?.frame = CGRect(x: 0, y: 0, width: parentFrame.size.width, height: defaultHeaderHeight)
        if let header = alternativeHeaderView {
            if topHeaderHeight <= 0 {
                header.frame = CGRect(x: 0, y: 0, width: parentFrame.size.width, height: header.frame.size.height)
            } else {
                header.frame = CGRect(x: 0, y: 0, width: parentFrame.size.width, height: topHeaderHeight)
            }
        }
        
        if let scrollView = currentHeaderCoordinator?.scrollView {
            if scrollView.contentInset.top != contentInset {
                let existingInsets = scrollView.contentInset
                var insets = UIEdgeInsets(top: contentInset, left: 0, bottom: 0, right: 0)
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
        if (newYPos + frame.size.height) > bgViewOffset {
            state = .visible
        } else {
            if state == .hidden {
                return
            }
            state = .hidden
        }
        frame.origin.y = newYPos
        headerYPosition = frame.origin.y
        backgroundView.frame = frame
    }
    
    @objc
    public func setNavigationBarColors() {
        upperBackgroundView.backgroundColor = navbarVisibleColor
        backgroundView.backgroundColor = navbarVisibleColor
        let tintColor = visibleTintColor
        navigationBar.tintColor = tintColor
        topViewController?.navigationItem.leftBarButtonItems?.forEach({ (button) in
            button.tintColor = tintColor
        })
        topViewController?.navigationItem.rightBarButtonItems?.forEach({ (button) in
            button.tintColor = tintColor
        })
    }
    
    private func updateStatusbarColor() {
        let isLightColor = self.upperBackgroundView.backgroundColor?.isLight() ?? true
        let currentStyle = UIApplication.shared.statusBarStyle
        if currentStyle == .default && !isLightColor {
            UIApplication.shared.statusBarStyle = .lightContent
            setNeedsStatusBarAppearanceUpdate()
        } else if currentStyle == .lightContent && isLightColor {
            UIApplication.shared.statusBarStyle = .default
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    @objc
    public func setAlternativeHeaderView(_ alternativeHeaderView: UIView?) {
        self.removeAlternativeHeaderView()
        self.alternativeHeaderView = alternativeHeaderView
        self.headerView?.removeFromSuperview()
        if let header = self.alternativeHeaderView {
            self.backgroundView.addSubview(header)
            self.bottomBorderView.isHidden = true
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
            self.bottomBorderView.isHidden = false
        }
        viewWillLayoutSubviews()
    }
}
