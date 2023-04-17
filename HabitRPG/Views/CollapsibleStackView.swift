//
//  CollapsibleStackView.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

@IBDesignable
class CollapsibleStackView: SeparatedStackView {
    
    var titleView: CollapsibleTitle?
    
    private var titleBottomBorder: CALayer?
    
    @IBInspectable var identifier: String?
    
    private var disableAnimations = false
    
    var isCollapsed = false {
        didSet {
            titleView?.isCollapsed = isCollapsed
            collapsedPreference = isCollapsed
            if disableAnimations {
                for subview in self.arrangedSubviews where subview != self.titleView {
                    subview.isHidden = self.isCollapsed
                    subview.alpha = self.isCollapsed ? 0 : 1
                }
                return
            }
            let transitionOptions: UIView.AnimationOptions = [isCollapsed ? .transitionCrossDissolve : .transitionCrossDissolve, .showHideTransitionViews]
            for subview in self.arrangedSubviews where subview != self.titleView {
                UIView.animate(withDuration: 0.3, animations: {
                    subview.isHidden = self.isCollapsed
                })
                UIView.transition(with: subview, duration: 0.3, options: transitionOptions, animations: { [unowned self] in
                    subview.alpha = self.isCollapsed ? 0 : 1
                    }, completion: nil)
            }
        }
    }
    
    var showSeparators = true {
        didSet {
            applyTheme(theme: ThemeService.shared.theme)
        }
    }

    private var collapsedPreference: Bool {
        get {
            guard let identifier = self.identifier else {
                return false
            }
            let userDefaults = UserDefaults()
            return userDefaults.bool(forKey: identifier + "Collapsed")
        }
        set {
            guard let identifier = self.identifier else {
                return
            }
            let userDefaults = UserDefaults()
            userDefaults.set(newValue, forKey: identifier + "Collapsed")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        axis = .vertical
        cornerRadius = 6
        if arrangedSubviews.isEmpty == false, let subView = arrangedSubviews[0] as? CollapsibleTitle {
            titleView = subView
        } else {
            let view = CollapsibleTitle()
            titleView = view
            insertArrangedSubview(view, at: 0)
        }
        titleView?.tapAction = {[weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.isCollapsed = !weakSelf.isCollapsed
        }
        titleView?.font = UIFontMetrics.default.scaledSystemFont(ofSize: 16)
        applyTheme(theme: ThemeService.shared.theme)
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        titleBottomBorder?.frame = CGRect(x: 0, y: (titleView?.layer.frame.size.height ?? 0) - 1, width: layer.frame.size.width, height: 1)
    }
    
    override func awakeFromNib() {
        disableAnimations = true
        if self.identifier != nil {
            self.isCollapsed = collapsedPreference
            self.setNeedsLayout()
            self.superview?.setNeedsLayout()
        }
        disableAnimations = false
        
        applyTheme(theme: ThemeService.shared.theme)
        super.awakeFromNib()
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        let separatorColor = showSeparators ? theme.separatorColor : .clear
        if titleBottomBorder == nil {
            titleBottomBorder = addBottomBorderWithColor(color: separatorColor, width: 1)
        } else {
            titleBottomBorder?.backgroundColor = separatorColor.cgColor
        }
        
        backgroundColor = theme.windowBackgroundColor
        titleView?.textColor = theme.primaryTextColor
        titleView?.subtitleColor = theme.secondaryTextColor
    }
}
