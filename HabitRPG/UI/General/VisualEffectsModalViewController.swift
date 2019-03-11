//
//  TaskFormViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 14.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

@objc
class VisualEffectModalViewController: UIViewController, UIScrollViewDelegate, Themeable {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var titleBar: UIView!
    @IBOutlet weak var screenDimView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topHeaderOffset: NSLayoutConstraint!
    @IBOutlet weak var scrollViewTopOffset: NSLayoutConstraint!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    @objc var containedViewController: UIViewController? {
        return children.first
    }
    
    private var topHeaderSize: CGFloat = 38
    private var topHeaderSpacing: CGFloat = 140
    
    override var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    var onLeftButtonTapped : (() -> Void)?
    var onRightButtonTapped : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ThemeService.shared.addThemeable(themable: self)
    }
    
    func applyTheme(theme: Theme) {
        visualEffectView.effect = UIBlurEffect(style: theme.isDark ? .dark : .extraLight)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollView.contentInset = UIEdgeInsets(top: self.view.bounds.size.height, left: 0, bottom: 0, right: 0)
        self.view.setNeedsLayout()
        screenDimView.alpha = 0
        
        scrollView.keyboardDismissMode = .onDrag
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showView()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        setHeader(offset: (-offset)+scrollViewTopOffset.constant)
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        setHeader(offset: (-offset)+scrollViewTopOffset.constant)
    }
    
    @IBAction func leftButtonTapped(_ sender: Any) {
        if let action = onLeftButtonTapped {
            action()
        } else {
            dismiss()
        }
    }
    @IBAction func rightButtonTapped(_ sender: Any) {
        if let action = onRightButtonTapped {
            action()
        } else {
            dismiss()
        }
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        dismiss()
    }
    
    func dismiss() {
        hideView {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    private func setHeader(offset: CGFloat) {
        if offset > 0 {
            topHeaderOffset.constant = offset - topHeaderSize
        } else {
            topHeaderOffset.constant = 0
        }
    }
    
    private func showView(_ completion: (() -> Void)? = nil) {
        let insets = UIEdgeInsets(top: topHeaderSpacing, left: 0, bottom: 0, right: 0)
        self.scrollView.scrollIndicatorInsets = insets
        UIView.animate(withDuration: 0.3) {
            self.screenDimView.alpha = 1.0
        }
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 4, options: .curveEaseInOut, animations: {[weak self] in
            self?.scrollView.contentInset = insets
            self?.view.layoutIfNeeded()
        }, completion: { _ in
            if let action = completion {
                action()
            }
        })
    }
    
    private func hideView(_ completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.4, animations: {[weak self] in
            self?.screenDimView.alpha = 0
            self?.scrollViewTopOffset.constant = self?.view.bounds.size.height ?? 0
            self?.view.layoutIfNeeded()
        }, completion: { (_) in
            if let action = completion {
                action()
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.view.translatesAutoresizingMaskIntoConstraints = false
    }
}
