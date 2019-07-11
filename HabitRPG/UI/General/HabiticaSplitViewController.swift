//
//  HabiticaSplitViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

class HabiticaSplitViewController: BaseUIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var leftViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var rightViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorView: UIView!
    
    private let segmentedWrapper = PaddedView()
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
        segmentedWrapper.insets = UIEdgeInsets(top: 4, left: 8, bottom: 10, right: 8)
        segmentedWrapper.containedView = segmentedControl
        let borderView = UIView(frame: CGRect(x: 0, y: segmentedWrapper.intrinsicContentSize.height+1, width: self.view.bounds.size.width, height: 1))
        borderView.backgroundColor = ThemeService.shared.theme.separatorColor
        segmentedWrapper.addSubview(borderView)
        topHeaderCoordinator.alternativeHeader = segmentedWrapper
        topHeaderCoordinator.hideHeader = canShowAsSplitView && showAsSplitView
        
        scrollView.delegate = self
        scrollView.bounces = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navController = self.hrpgTopHeaderNavigationController() {
            scrollViewTopConstraint.constant = navController.contentInset
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isInitialSetup {
            isInitialSetup = false
            setupSplitView(traitCollection)
            if !showAsSplitView {
                let userDefaults = UserDefaults()
                let lastPage = userDefaults.integer(forKey: viewID ?? "" + "lastOpenedSegment")
                segmentedControl.selectedSegmentIndex = lastPage
                scrollTo(page: lastPage, animated: false)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let userDefaults = UserDefaults()
        userDefaults.set(segmentedControl.selectedSegmentIndex, forKey: viewID ?? "" + "lastOpenedSegment")
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
        showAsSplitView = canShowAsSplitView && (collection.horizontalSizeClass == .regular && collection.verticalSizeClass == .regular)
        separatorView.isHidden = !showAsSplitView
        scrollView.isScrollEnabled = !showAsSplitView
        topHeaderCoordinator?.hideHeader = showAsSplitView
        if showAsSplitView {
            leftViewWidthConstraint = leftViewWidthConstraint.setMultiplier(multiplier: 0.333)
            rightViewWidthConstraint = rightViewWidthConstraint.setMultiplier(multiplier: 0.666)
        } else {
            leftViewWidthConstraint = leftViewWidthConstraint.setMultiplier(multiplier: 1)
            rightViewWidthConstraint = rightViewWidthConstraint.setMultiplier(multiplier: 1)
        }
        view.setNeedsLayout()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = getCurrentPage()
        segmentedControl.selectedSegmentIndex = currentPage
    }
    
    @objc
    func switchView(_ segmentedControl: UISegmentedControl) {
        scrollTo(page: segmentedControl.selectedSegmentIndex)
    }
    
    func getCurrentPage() -> Int {
        return Int(scrollView.contentOffset.x / scrollView.frame.size.width)
    }
    
    func scrollTo(page: Int, animated: Bool = true) {
        let point = CGPoint(x: scrollView.frame.size.width * CGFloat(page), y: 0)
        scrollView.setContentOffset(point, animated: animated)
    }
}
