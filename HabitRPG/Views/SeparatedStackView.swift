//
//  SeparatedStackView.swift
//  Habitica
//
//  Created by Phillip Thelen on 08.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

class SeparatedStackView: StackView {
    
    private var itemSeparators = [CALayer]()
    
    var separatorColor = ThemeService.shared.theme.separatorColor {
        didSet {
            itemSeparators.forEach { (layer) in
                layer.backgroundColor = separatorColor.cgColor
            }
        }
    }
    var separatorInsets: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            layer.setNeedsLayout()
        }
    }
    var separatorThickness: CGFloat = 1 {
        didSet {
            layer.setNeedsLayout()
        }
    }
    var separatorBetweenItems = false {
        didSet {
            setBorders()
        }
    }
    
    private var hasTitle: Bool {
        return (arrangedSubviews.first as? CollapsibleTitle) != nil
    }
    
    private var visibleArrangedSubviews: [UIView] {
        return arrangedSubviews.filter({ (view) -> Bool in
            return !view.isHidden
        })
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        let visibleSubviews = visibleArrangedSubviews
        itemSeparators.enumerated().forEach { (index, layer) in
            let itemIndex = hasTitle ? index + 1 : index
            if itemIndex >= visibleSubviews.count {
                return
            }
            let item = visibleSubviews[itemIndex]
            if self.axis == .vertical {
                layer.frame = CGRect(x: separatorInsets.left,
                                     y: item.frame.origin.y+item.frame.size.height + (spacing/2),
                                     width: frame.size.width - (separatorInsets.left + separatorInsets.right),
                                     height: separatorThickness)
            } else {
                layer.frame = CGRect(x: item.frame.origin.x + item.frame.size.width + (spacing/2),
                                     y: separatorInsets.top,
                                     width: separatorThickness,
                                     height: frame.size.height - (separatorInsets.top + separatorInsets.bottom))
            }
        }
    }
    
    override func addArrangedSubview(_ view: UIView) {
        super.addArrangedSubview(view)
        if separatorBetweenItems {
            setBorders()
        }
    }
    
    override func removeArrangedSubview(_ view: UIView) {
        super.removeArrangedSubview(view)
        if separatorBetweenItems {
            setBorders()
        }
    }
    
    override func insertArrangedSubview(_ view: UIView, at stackIndex: Int) {
        super.insertArrangedSubview(view, at: stackIndex)
        if separatorBetweenItems {
            setBorders()
        }
    }
    
    func setBorders() {
        itemSeparators.forEach { (layer) in
            layer.removeFromSuperlayer()
        }
        itemSeparators.removeAll()
        let visibleSubviews = visibleArrangedSubviews
        if separatorBetweenItems && visibleSubviews.count > (hasTitle ? 2 : 1) {
            for _ in 0...(visibleSubviews.count-(hasTitle ? 3 : 2)) {
                let border = CALayer()
                border.backgroundColor = separatorColor.cgColor
                layer.addSublayer(border)
                itemSeparators.append(border)
            }
        }
        layer.setNeedsLayout()
    }
}
