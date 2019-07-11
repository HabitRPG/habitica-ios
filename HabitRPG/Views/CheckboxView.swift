//
//  CheckboxView.swift
//  Habitica
//
//  Created by Phillip Thelen on 06.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class CheckmarkLayer: CALayer {
    var drawPercentage: CGFloat = 0
    
    override init(layer: Any) {
        super.init(layer: layer)
        if let checklayer = layer as? CheckmarkLayer {
            drawPercentage = checklayer.drawPercentage
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "drawPercentage" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    override func action(forKey event: String) -> CAAction? {
        if event == "drawPercentage" {
            let animation = CABasicAnimation(keyPath: event)
            animation.fromValue = presentation()?.value(forKey: event)
            return animation
        }
        return super.action(forKey: event)
    }
}

class CheckboxView: UIView {
    
    var checked = false {
        didSet {
            if let layer = self.layer as? CheckmarkLayer {
                layer.drawPercentage = checked ? 1 : 0
                layer.setNeedsDisplay()
            }
        }
    }
    var size: CGFloat = 26
    var boxBorderColor: UIColor?
    var boxFillColor: UIColor = UIColor.white
    var boxCornerRadius: CGFloat = 0
    var checkColor: UIColor = UIColor.white
    var centerCheckbox = true
    var padding: CGFloat = 12
    var borderedBox = false
    var dimmOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeService.shared.theme.taskOverlayTint
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    var wasTouched: (() -> Void)? {
        didSet {
            isUserInteractionEnabled = wasTouched != nil
        }
    }
    
    private let label = UILabel()
    
    override class var layerClass: AnyClass {
        return CheckmarkLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
        isUserInteractionEnabled = true
        addSubview(dimmOverlayView)
    }
    
    func configure(task: TaskProtocol) {
        boxFillColor = UIColor(white: 1.0, alpha: 0.7)
        checked = task.completed
        if let layer = self.layer as? CheckmarkLayer {
            layer.drawPercentage = checked ? 1 : 0
        }
        
        let theme = ThemeService.shared.theme
        
        if task.type == "daily" {
            boxCornerRadius = 3
            if task.completed {
                boxFillColor = theme.dimmedTextColor
                backgroundColor = theme.dimmedColor
                checkColor = UIColor.gray200()
            } else {
                backgroundColor = theme.offsetBackgroundColor
                checkColor = UIColor.gray200()
                if task.dueToday() {
                    backgroundColor = UIColor.forTaskValueLight(Int(task.value))
                    checkColor = UIColor.forTaskValue(Int(task.value))
                }
            }
        } else {
            boxCornerRadius = size/2
            if task.completed {
                boxFillColor = theme.dimmedTextColor
                backgroundColor = theme.offsetBackgroundColor
                checkColor = UIColor.gray200()
            } else {
                backgroundColor = UIColor.forTaskValueLight(Int(task.value))
                checkColor = UIColor.forTaskValue(Int(task.value))
            }
        }
        
        dimmOverlayView.isHidden = !theme.isDark
        dimmOverlayView.backgroundColor = theme.taskOverlayTint
        
        layer.setNeedsDisplay()
    }
    
    func configure(checklistItem: ChecklistItemProtocol, withTitle: Bool) {
        checked = checklistItem.completed
        if let layer = self.layer as? CheckmarkLayer {
            layer.drawPercentage = checked ? 1 : 0
        }
        if withTitle {
            label.font = UIFont.preferredFont(forTextStyle: .subheadline)
            if label.superview == nil {
                self.addSubview(label)
            }
            if checked {
                let attributedString = NSMutableAttributedString(string: checklistItem.text ?? "")
                attributedString.addAttribute(.strikethroughStyle, value: NSNumber(value: 2), range: NSRange(location: 0, length: attributedString.length))
                label.attributedText = attributedString
            } else {
                label.text = checklistItem.text
            }
        }
        
        label.textColor = checked ? UIColor.gray400() : UIColor.gray100()
        backgroundColor = UIColor.clear
        boxFillColor = checked ? UIColor.gray400() : UIColor.clear
        boxBorderColor = checked ? nil : UIColor.gray400()
        checkColor = UIColor.gray200()
        boxCornerRadius = 3
        centerCheckbox = false
        size = 22
        borderedBox = true
        layer.setNeedsDisplay()
    }
    
    @objc
    private func viewTapped() {
        if let action = wasTouched {
            checked = !checked
            action()
            animateTo(value: checked ? 1 : 0)
        }
    }
    
    private func animateTo(value: CGFloat) {
        let layer = self.layer as? CheckmarkLayer
        let timing = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        let animation = CABasicAnimation(keyPath: "drawPercentage")
        animation.isAdditive = true
        animation.duration = 0.2
        animation.fillMode = CAMediaTimingFillMode.both
        animation.timingFunction = timing
        animation.fromValue = NSNumber(value: 0)
        animation.toValue = NSNumber(value: 1)
        
        layer?.add(animation, forKey: nil)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer?.drawPercentage = value
        CATransaction.commit()
    }
    
    override func layoutSubviews() {
        let leftOffset = padding * 2 + size
        label.frame = CGRect(x: leftOffset, y: 0, width: frame.size.width - leftOffset, height: frame.size.height)
        dimmOverlayView.frame = frame
    }
    
    override func draw(_ rect: CGRect) {
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        UIGraphicsPushContext(ctx)
        
        ctx.clear(bounds)
        backgroundColor?.setFill()
        ctx.fill(bounds)

        let horizontalCenter = centerCheckbox ? bounds.size.width / 2 : padding + size / 2
        let borderPath = UIBezierPath(roundedRect: CGRect(x: horizontalCenter - size / 2, y: bounds.size.height / 2 - size / 2, width: size, height: size), cornerRadius: boxCornerRadius)
        if boxBorderColor != nil {
            boxBorderColor?.setStroke()
            borderPath.stroke()
        }
        boxFillColor.setFill()
        borderPath.fill()
        if let layer = self.layer as? CheckmarkLayer, layer.drawPercentage > 0 {
            let checkFrame = CGRect(x: horizontalCenter - size / 2, y: bounds.size.height / 2 - size / 2, width: size, height: size)
            HabiticaIcons.drawCheckmark(frame: checkFrame, resizing: .center, checkmarkColor: checkColor, percentage: layer.drawPercentage)
        }
        UIGraphicsPopContext()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: size + padding * 2, height: size + padding * 2)
    }
}
