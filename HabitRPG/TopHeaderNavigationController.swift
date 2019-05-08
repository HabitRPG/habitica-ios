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
    @objc var defaultNavbarHiddenColor: UIColor { get }
    @objc var defaultNavbarVisibleColor: UIColor { get }
    @objc var navbarHiddenColor: UIColor { get set }
    @objc var navbarVisibleColor: UIColor { get set }
    @objc var hideNavbar: Bool { get set }
    @objc var shouldHideTopHeader: Bool { get set }
    @objc var contentInset: CGFloat { get }
    @objc var contentOffset: CGFloat { get }
    
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
    func setNavigationBarColors(_ alpha: CGFloat)
}

class TopHeaderViewController: UINavigationController, TopHeaderNavigationControllerProtocol, Themeable {
    @objc public var state: TopHeaderState = .visible
    @objc public var defaultNavbarHiddenColor = UIColor.purple300()
    @objc public var defaultNavbarVisibleColor = ThemeService.shared.theme.contentBackgroundColor
    private var headerView: UIView?
    private var alternativeHeaderView: UIView?
    private let backgroundView = UIView()
    private let bottomBorderView = UIView()
    private let upperBackgroundView = UIView()
    
    private var scrollableView: UIScrollView?
    private var gestureRecognizer: UIPanGestureRecognizer?
    private var headerYPosition: CGFloat = 0
    
    private var visibleTintColor = UIColor.purple400()
    private var hiddenTintColor = UIColor.white
    private var visibleTextColor = UIColor.black
    private var hiddenTextColor = UIColor.white
    
    @objc public var navbarHiddenColor: UIColor = UIColor.purple300() {
        didSet {
            let isHiddenLightColor = navbarHiddenColor.isLight()
            hiddenTintColor = isHiddenLightColor ? ThemeService.shared.theme.tintColor : UIColor.white
            hiddenTextColor = isHiddenLightColor ? UIColor.black : UIColor.white
            setNavigationBarColors(navbarColorBlendingAlpha)
        }
    }
    @objc public var navbarVisibleColor: UIColor = UIColor.white {
        didSet {
            let isVisibleLightColor = navbarVisibleColor.isLight()
            visibleTintColor = isVisibleLightColor ? ThemeService.shared.theme.tintColor : UIColor.white
            visibleTextColor = isVisibleLightColor ? UIColor.black : UIColor.white
            setNavigationBarColors(navbarColorBlendingAlpha)
        }
    }
    
    @objc public var hideNavbar = false {
        didSet {
            self.setNavigationBarHidden(hideNavbar, animated: false)
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.setNavigationBarColors(navbarColorBlendingAlpha)
        }
    }
    
    @objc var shouldHideTopHeader: Bool = false {
        willSet {
            if self.shouldHideTopHeader != newValue {
                if newValue {
                    self.hideHeader()
                } else {
                    self.showHeader()
                }
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    var topHeaderHeight: CGFloat {
        if let header = self.alternativeHeaderView {
            return alternativeHeaderHeight
        } else {
            return defaultHeaderHeight
        }
    }
    
    var defaultHeaderHeight: CGFloat {
        if UI_USER_INTERFACE_IDIOM() == .pad {
            return 200
        } else {
            return 162
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
        
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.view.backgroundColor = .clear
        self.navigationBar.backgroundColor = .clear
        
        let nibViews = Bundle.main.loadNibNamed("UserTopHeader", owner: self, options: nil)
        self.headerView = nibViews?[0] as? UIView
        if let headerView = self.headerView {
            self.backgroundView.addSubview(headerView)
        }
        self.backgroundView.addSubview(self.bottomBorderView)
        
        self.view.insertSubview(self.upperBackgroundView, belowSubview: self.navigationBar)
        self.view.insertSubview(self.backgroundView, belowSubview: self.upperBackgroundView)
        
        self.headerYPosition = self.bgViewOffset
        
        ThemeService.shared.addThemeable(themable: self, applyImmediately: true)
    }

    func applyTheme(theme: Theme) {
        defaultNavbarHiddenColor = theme.navbarHiddenColor
        defaultNavbarVisibleColor = theme.contentBackgroundColor
        visibleTintColor = theme.tintColor
        setNavigationBarColors(navbarColorBlendingAlpha)
        bottomBorderView.backgroundColor = theme.separatorColor
        backgroundView.backgroundColor = theme.contentBackgroundColorDimmed
        upperBackgroundView.backgroundColor = theme.contentBackgroundColor
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let parentFrame = self.view.frame
        self.backgroundView.frame = CGRect(x: 0.0, y: self.headerYPosition, width: parentFrame.size.width, height: self.topHeaderHeight + 2)
        self.upperBackgroundView.frame = CGRect(x: 0, y: 0, width: parentFrame.size.width, height: self.bgViewOffset)
        self.bottomBorderView.frame = CGRect(x: 0, y: self.backgroundView.frame.size.height - 2, width: parentFrame.size.width, height: 2)
        self.bottomBorderView.frame = CGRect(x: 0, y: self.backgroundView.frame.size.height - 2, width: parentFrame.size.width, height: 2)
        self.headerView?.frame = CGRect(x: 0, y: 0, width: parentFrame.size.width, height: self.defaultHeaderHeight)
        if let header = self.alternativeHeaderView {
            let intrinsicHeight = header.intrinsicContentSize.height
            if intrinsicHeight <= 0 {
                header.frame = CGRect(x: 0, y: 0, width: parentFrame.size.width, height: header.frame.size.height)
            } else {
                header.frame = CGRect(x: 0, y: 0, width: parentFrame.size.width, height: intrinsicHeight)
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
        var frame = self.backgroundView.frame
        frame.origin.y = self.bgViewOffset
        self.headerYPosition = frame.origin.y
        UIView.animate(withDuration: animated ? 0.3 : 0.0, delay: 0, options: .curveEaseInOut, animations: {
            self.setNewFrame(frame)
        }, completion: nil)
    }
    
    @objc
    public func hideHeader(animated: Bool = true) {
        self.state = .hidden
        var frame = self.backgroundView.frame
        frame.origin.y = -topHeaderHeight
        self.headerYPosition = frame.origin.y
        UIView.animate(withDuration: animated ? 0.3 : 0.0, delay: 0, options: .curveEaseInOut, animations: {
            self.setNewFrame(frame)
        }, completion: nil)
    }
    
    func setNewFrame(_ frame: CGRect) {
        self.backgroundView.frame = frame
        self.setNavigationBarColors(self.shouldHideTopHeader ? 1 : 0)
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
        if let recognizer = self.gestureRecognizer {
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
        var frame = self.backgroundView.frame
        var newYPos = -position - frame.size.height
        if newYPos > self.bgViewOffset {
            newYPos = self.bgViewOffset
        }
        if (newYPos + frame.size.height) > bgViewOffset {
            self.state = .visible
        } else {
            if self.state == .hidden {
                return
            }
            self.state = .hidden
        }
        frame.origin.y = newYPos
        self.headerYPosition = frame.origin.y
        self.backgroundView.frame = frame
        self.setNavigationBarColors(navbarColorBlendingAlpha)
    }
    
    @objc
    public func setNavigationBarColors(_ alpha: CGFloat) {
        self.upperBackgroundView.backgroundColor = navbarVisibleColor.blend(with: navbarHiddenColor, alpha: alpha)
        self.backgroundView.backgroundColor = navbarVisibleColor.blend(with: navbarHiddenColor, alpha: alpha)
        let tintColor = visibleTintColor.blend(with: hiddenTintColor, alpha: alpha)
        self.navigationBar.tintColor = tintColor
        self.topViewController?.navigationItem.leftBarButtonItems?.forEach({ (button) in
            button.tintColor = tintColor
        })
        self.topViewController?.navigationItem.rightBarButtonItems?.forEach({ (button) in
            button.tintColor = tintColor
        })
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: (visibleTextColor.blend(with: hiddenTextColor, alpha: alpha) ?? .white)]
        updateStatusbarColor()
    }
    
    private func updateStatusbarColor() {
        let isLightColor = self.upperBackgroundView.backgroundColor?.isLight() ?? true
        let currentStyle = UIApplication.shared.statusBarStyle
        if currentStyle == .default && !isLightColor {
            UIApplication.shared.statusBarStyle = .lightContent
            self.setNeedsStatusBarAppearanceUpdate()
        } else if currentStyle == .lightContent && isLightColor {
            UIApplication.shared.statusBarStyle = .default
            self.setNeedsStatusBarAppearanceUpdate()
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
        self.viewWillLayoutSubviews()
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
        self.viewWillLayoutSubviews()
    }
}
