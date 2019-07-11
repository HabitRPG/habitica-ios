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
    
    private var titleView: CollapsibleTitle?
    
    private var topBorder: CALayer?
    private var bottomBorder: CALayer?
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
            let transitionOptions: UIView.AnimationOptions = [isCollapsed ? .transitionFlipFromBottom : .transitionFlipFromTop, .showHideTransitionViews]
            for subview in self.arrangedSubviews where subview != self.titleView {
                UIView.animate(withDuration: 0.3, animations: {
                    subview.isHidden = self.isCollapsed
                })
                UIView.transition(with: subview, duration: 0.6, options: transitionOptions, animations: { [unowned self] in
                    subview.alpha = self.isCollapsed ? 0 : 1
                    }, completion: nil)
            }
            
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
        if arrangedSubviews.isEmpty == false, let subView = arrangedSubviews[0] as? CollapsibleTitle {
            titleView = subView
        } else {
            let view = CollapsibleTitle()
            titleView = view
            addArrangedSubview(view)
        }
        titleView?.tapAction = {[weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.isCollapsed = !weakSelf.isCollapsed
        }
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        topBorder?.frame = CGRect(x: 0, y: 0, width: layer.frame.size.width, height: 1)
        bottomBorder?.frame = CGRect(x: 0, y: layer.frame.size.height-1, width: layer.frame.size.width, height: 1)
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
        
        let separatorColor = ThemeService.shared.theme.separatorColor
        topBorder = addTopBorderWithColor(color: separatorColor, width: 1)
        bottomBorder = addBottomBorderWithColor(color: separatorColor, width: 1)
        titleBottomBorder = addBottomBorderWithColor(color: separatorColor, width: 1)
        
        backgroundColor = ThemeService.shared.theme.contentBackgroundColor
        
        super.awakeFromNib()
    }
}
