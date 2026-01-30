//
//  HabiticaSplitViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class HabiticaSplitViewController: BaseUIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftViewWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var rightViewWidthConstraint: NSLayoutConstraint?
    @IBOutlet weak var separatorView: UIView!
    
    private let segmentedWrapper = UIVisualEffectView()
    internal let segmentedControl = UISegmentedControl(items: ["", ""])
    private var isInitialSetup = true
    var showAsSplitView = false
    var canShowAsSplitView = true
    
    internal var viewID: String?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        showAsSplitView = traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(HabiticaSplitViewController.switchView(_:)), for: .valueChanged)
        segmentedControl.isHidden = false
        segmentedWrapper.contentView.addSubview(segmentedControl)
        
        if #available(iOS 26.0, *) {
            let glassEffect = UIGlassEffect()
            segmentedWrapper.effect = glassEffect
            segmentedWrapper.cornerConfiguration = .capsule()
        }
        
        topHeaderCoordinator?.alternativeHeader = segmentedWrapper
        topHeaderCoordinator?.hideHeader = canShowAsSplitView && showAsSplitView
        topHeaderCoordinator?.followScrollView = false
        layoutHeader()
        
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        
        ThemeService.shared.addThemeable(themable: self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutHeader()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        layoutHeader()
    }
    
    func layoutHeader() {
        let size = segmentedControl.intrinsicContentSize
        segmentedWrapper.frame = CGRect(x: 8, y: 0, width: view.frame.width - 16, height: size.height + 4)
        segmentedControl.pin.horizontally(4).vertically(2)
        scrollView.subviews.forEach { subview in
            var subviews: [UIView] = subview.subviews
            while !subviews.isEmpty && !(subviews.first is UIScrollView) {
                subviews = subviews.first?.subviews ?? []
            }
            if let scroll = subviews.first as? UIScrollView {
                if scroll.transform != .identity {
                    return
                }
                let oldTopInset = scroll.contentInset.top
                let newTopInset = view.safeAreaInsets.top + size.height + 8
                scroll.contentInset = UIEdgeInsets(top: newTopInset, left: 0, bottom: view.safeAreaInsets.bottom, right: 0)
                scroll.scrollIndicatorInsets = UIEdgeInsets(top: size.height + 4, left: 0, bottom: 0, right: 0)
                if oldTopInset != newTopInset && scroll.contentOffset.y > -newTopInset && scroll.contentOffset.y <= -oldTopInset + 10 {
                    scroll.contentOffset.y = -newTopInset
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isBeingDismissed {
            return
        }

        if isViewLoaded && isInitialSetup && viewID != nil {
            isInitialSetup = false
            
            if canShowAsSplitView {
                setupSplitView(traitCollection)
            } else {
                topHeaderCoordinator?.hideHeader = false
            }
            if !showAsSplitView {
                let userDefaults = UserDefaults()
                let lastPage = userDefaults.integer(forKey: (viewID ?? "") + "lastOpenedSegment")
                segmentedControl.selectedSegmentIndex = lastPage
                scrollTo(page: lastPage, animated: false)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        let userDefaults = UserDefaults()
        userDefaults.set(segmentedControl.selectedSegmentIndex, forKey: (viewID ?? "") + "lastOpenedSegment")
        userDefaults.synchronize()
        super.viewWillDisappear(animated)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: {[weak self] (_) in
            self?.setupSplitView(newCollection)
            self?.scrollTo(page: self?.segmentedControl.selectedSegmentIndex ?? 0)
            }, completion: nil)
    }
    
    private func setupSplitView(_ collection: UITraitCollection) {
        if !canShowAsSplitView {
            return
        }
        showAsSplitView = canShowAsSplitView && (collection.horizontalSizeClass == .regular && collection.verticalSizeClass == .regular)
        separatorView.isHidden = !showAsSplitView
        scrollView.isScrollEnabled = !showAsSplitView
        topHeaderCoordinator?.hideHeader = showAsSplitView
        if showAsSplitView {
            let leftMultiplier = max(0.333, 375 / scrollView.frame.width)
            if leftViewWidthConstraint?.multiplier != leftMultiplier {
                leftViewWidthConstraint = leftViewWidthConstraint?.setMultiplier(multiplier: leftMultiplier)
                rightViewWidthConstraint = rightViewWidthConstraint?.setMultiplier(multiplier: 1-leftMultiplier)
            }
        } else if leftViewWidthConstraint?.multiplier != 1 {
            leftViewWidthConstraint = leftViewWidthConstraint?.setMultiplier(multiplier: 1)
            rightViewWidthConstraint = rightViewWidthConstraint?.setMultiplier(multiplier: 1)
        }
        view.layoutIfNeeded()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = getCurrentPage()
        segmentedControl.selectedSegmentIndex = currentPage
        view.endEditing(true)
    }
    
    @objc
    func switchView(_ segmentedControl: UISegmentedControl) {
        scrollTo(page: segmentedControl.selectedSegmentIndex)
        view.endEditing(true)
    }
    
    func getCurrentPage() -> Int {
        return Int(scrollView.contentOffset.x / scrollView.frame.size.width)
    }
    
    func scrollTo(page: Int, animated: Bool = true) {
        let point = CGPoint(x: scrollView.frame.size.width * CGFloat(page), y: 0)
        scrollView.setContentOffset(point, animated: animated)
    }
}
