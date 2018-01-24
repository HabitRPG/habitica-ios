//
//  CollapsibleStackView.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

@IBDesignable
class CollapsibleStackView: UIStackView {
    
    private var titleView: CollapsibleTitle?
    
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
            let transitionOptions: UIViewAnimationOptions = [isCollapsed ? .transitionFlipFromBottom : .transitionFlipFromTop, .showHideTransitionViews]
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
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        if arrangedSubviews.count > 0, let subView = arrangedSubviews[0] as? CollapsibleTitle {
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
    
    override func awakeFromNib() {
        disableAnimations = true
        if self.identifier != nil {
            self.isCollapsed = collapsedPreference
            self.setNeedsLayout()
            self.superview?.setNeedsLayout()
        }
        disableAnimations = false
        
        super.awakeFromNib()
    }
}
