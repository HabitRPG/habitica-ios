//
//  TopHeaderNavigationController.swift
//  Habitica
//
//  Created by Phillip Thelen on 15.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class TopHeaderViewController: UINavigationController {
    @objc public var state: HRPGTopHeaderState = HRPGTopHeaderStateVisible
    @objc public let defaultNavbarHiddenColor = UIColor.purple300()
    @objc public let defaultNavbarVisibleColor = UIColor.white
    private var headerView: UIView?
    private var alternativeHeaderView: UIView?
    private let backgroundView = UIView()
    private let bottomBorderView = UIView()
    private let upperBackgroundView = UIView()
    
    private var scrollableView: UIScrollView?
    private var gestureRecognizer: UIPanGestureRecognizer?
    private var headerYPosition: CGFloat = 0
    
    @objc public var navbarHiddenColor: UIColor = UIColor.purple300() {
        didSet {
            setNavigationBarColors(navbarColorBlendingAlpha)
        }
    }
    @objc public var navbarVisibleColor: UIColor = UIColor.white {
        didSet {
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
                    self.view.setNeedsLayout()
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    var topHeaderHeight: CGFloat {
        if self.shouldHideTopHeader {
            return 0
        } else if let header = self.alternativeHeaderView {
            return header.intrinsicContentSize.height
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.navigationBar.barStyle == UIBarStyle.black ? UIStatusBarStyle.lightContent : UIStatusBarStyle.default
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
        return self.backgroundView.frame.size.height + self.backgroundView.frame.origin.y
    }
    
    private var navbarColorBlendingAlpha: CGFloat {
        return -((self.backgroundView.frame.origin.y - self.bgViewOffset) / self.backgroundView.frame.size.height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
        self.view.backgroundColor = .clear
        self.navigationBar.backgroundColor = .clear
        
        let nibViews = Bundle.main.loadNibNamed("HRPGUserTopHeader", owner: self, options: nil)
        self.headerView = nibViews?[0] as? UIView
        self.backgroundView.backgroundColor = .gray700()
        self.bottomBorderView.backgroundColor = .gray600()
        self.upperBackgroundView.backgroundColor = .white
        if let headerView = self.headerView {
            self.backgroundView.addSubview(headerView)
        }
        self.backgroundView.addSubview(self.bottomBorderView)
        
        self.view.insertSubview(self.upperBackgroundView, belowSubview: self.navigationBar)
        self.view.insertSubview(self.backgroundView, belowSubview: self.upperBackgroundView)
        
        self.headerYPosition = self.bgViewOffset
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
            header.frame = CGRect(x: 0, y: 0, width: parentFrame.size.width, height: header.intrinsicContentSize.height)
        }
    }
    
    func showHeader() {
        self.state = HRPGTopHeaderStateVisible
        var frame = self.backgroundView.frame
        frame.origin.y = self.bgViewOffset
        self.headerYPosition = frame.origin.y
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.backgroundView.frame = frame
            self.setNavigationBarColors(0)
        }, completion: nil)
    }
    
    func hideHeader() {
        self.state = HRPGTopHeaderStateHidden
        var frame = self.backgroundView.frame
        frame.origin.y = -frame.size.height
        self.headerYPosition = frame.origin.y
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.backgroundView.frame = frame
            if !self.shouldHideTopHeader {
                self.setNavigationBarColors(1)
            } else {
                self.setNavigationBarColors(0)
            }
        }, completion: nil)
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
            self.state = HRPGTopHeaderStateVisible
        } else {
            if self.state == HRPGTopHeaderStateHidden {
                return
            }
            self.state = HRPGTopHeaderStateHidden
        }
        frame.origin.y = newYPos
        self.headerYPosition = frame.origin.y
        self.backgroundView.frame = frame
        self.setNavigationBarColors(navbarColorBlendingAlpha)
    }
    
    func setNavigationBarColors(_ alpha: CGFloat) {
        self.upperBackgroundView.backgroundColor = navbarVisibleColor.blend(with: navbarHiddenColor, alpha: alpha)
        self.navigationBar.tintColor = UIColor.purple400().blend(with: .white, alpha: alpha)
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black.blend(with: .white, alpha: alpha)]
        if self.navigationBar.barStyle == .default && alpha > 0.5 {
            self.navigationBar.barStyle = .black
            self.setNeedsStatusBarAppearanceUpdate()
        } else if self.navigationBar.barStyle == .black && alpha < 0.5 {
            self.navigationBar.barStyle = .default
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
            header.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: header.intrinsicContentSize.height)
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
        }
        self.viewWillLayoutSubviews()
    }
}
