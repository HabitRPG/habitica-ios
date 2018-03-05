//
//  TopHeaderCoordinator.swift
//  Habitica
//
//  Created by Phillip Thelen on 31.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class TopHeaderCoordinator: NSObject {
    
    private weak var scrollView: UIScrollView?
    private weak var topHeaderNavigationController: (UINavigationController & TopHeaderNavigationControllerProtocol)?
    @objc weak var alternativeHeader: UIView?
    @objc var hideNavBar = false
    @objc var hideHeader = false
    @objc var followScrollView = true
    @objc var navbarHiddenColor: UIColor?
    @objc var navbarVisibleColor: UIColor?
    
    @objc
    init(topHeaderNavigationController: UINavigationController & TopHeaderNavigationControllerProtocol) {
        self.topHeaderNavigationController = topHeaderNavigationController
    }
    
    @objc
    init(topHeaderNavigationController: UINavigationController & TopHeaderNavigationControllerProtocol, scrollView: UIScrollView) {
        self.topHeaderNavigationController = topHeaderNavigationController
        self.scrollView = scrollView
    }
    
    @objc
    func viewDidLoad() {
        guard let navController = topHeaderNavigationController else {
            return
        }
        var insets = UIEdgeInsets(top: navController.contentInset, left: 0, bottom: 0, right: 0)
        scrollView?.contentInset = insets
        scrollView?.scrollIndicatorInsets = insets
        if navController.state == HRPGTopHeaderStateHidden {
            scrollView?.contentOffset = CGPoint(x: 0, y: -navController.contentOffset)
        }
    }
    
    @objc
    func viewWillAppear() {
        guard let navController = topHeaderNavigationController else {
            return
        }
        navController.hideNavbar = hideNavBar
        if alternativeHeader != nil {
            navController.setAlternativeHeaderView(alternativeHeader)
        } else {
            navController.removeAlternativeHeaderView()
        }
        
        if hideHeader {
            navController.hideHeader(animated: false)
        } else {
            navController.showHeader(animated: false)
        }
        navController.shouldHideTopHeader = hideHeader

        if let navbarVisibleColor = self.navbarVisibleColor {
            navController.navbarVisibleColor = navbarVisibleColor
        } else {
            navController.navbarVisibleColor = navController.defaultNavbarVisibleColor
        }
        if let navbarHiddenColor = self.navbarHiddenColor {
            navController.navbarHiddenColor = navbarHiddenColor
        } else {
            navController.navbarHiddenColor = navController.defaultNavbarHiddenColor
        }
        
        navController.view.setNeedsLayout()
        
        let existingInsets = scrollView?.contentInset
        var insets = UIEdgeInsets(top: navController.contentInset, left: 0, bottom: 0, right: 0)
        if existingInsets?.bottom != 0 {
            insets = UIEdgeInsets(top: navController.contentInset + ((existingInsets?.top ?? 0) - navController.contentInset), left: 0, bottom: existingInsets?.bottom ?? 0, right: 0)
        }
        scrollView?.contentInset = insets
        scrollView?.scrollIndicatorInsets = insets
        if navController.state == HRPGTopHeaderStateHidden {
            scrollView?.contentOffset = CGPoint(x: 0, y: -navController.contentOffset)
        }
        if scrollView?.contentOffset.y ?? 0 < -navController.contentOffset {
            scrollView?.contentOffset = CGPoint(x: 0, y: 0)
        }
    }
    
    @objc
    func viewDidAppear() {
        guard let navController = topHeaderNavigationController else {
            return
        }
        guard let scrollView = self.scrollView else {
            return
        }
        if followScrollView {
            navController.startFollowing(scrollView: scrollView)
        }
        if navController.state == HRPGTopHeaderStateVisible && scrollView.contentOffset.y > -navController.contentOffset {
            navController.scrollView(scrollView, scrolledToPosition: scrollView.contentOffset.y)
        }
    }
    
    @objc
    func viewWillDisappear() {
        guard let navController = topHeaderNavigationController else {
            return
        }
        navController.stopFollowingScrollView()
    }
    
    @objc
    func scrollViewDidScroll() {
        guard let navController = topHeaderNavigationController else {
            return
        }
        guard let scrollView = self.scrollView else {
            return
        }
        navController.scrollView(scrollView, scrolledToPosition: scrollView.contentOffset.y)
    }
}
