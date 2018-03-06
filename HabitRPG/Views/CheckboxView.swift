//
//  CheckboxView.swift
//  Habitica
//
//  Created by Phillip Thelen on 06.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class CheckboxView: UIView {
    
    var checked = false
    var size: CGFloat = 26
    var boxBorderColor: UIColor?
    var boxFillColor: UIColor = UIColor.white
    var boxCornerRadius: CGFloat = 0
    var checkColor: UIColor = UIColor.white
    var centerCheckbox = true
    var padding: CGFloat = 12
    var borderedBox = false
    
    var wasTouched: (() -> Void)? {
        didSet {
            isUserInteractionEnabled = wasTouched != nil
        }
    }
    
    private let label = UILabel()
    
    override class var layerClass: AnyClass {
        return HRPGCheckmarkLayer.self
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
    }
    
    func configure(task: TaskProtocol) {
        configure(task: task, offset: 0)
    }
    
    func configure(task: TaskProtocol, offset: Int) {
        boxFillColor = UIColor(white: 1.0, alpha: 0.7)
        checked = task.completed
        if let layer = self.layer as? HRPGCheckmarkLayer {
            layer.drawPercentage = checked ? 1 : 0
        }
        if task.type == "daily" {
            boxCornerRadius = 3
            if task.completed {
                boxFillColor = UIColor.gray400()
                backgroundColor = UIColor.gray500()
                checkColor = UIColor.gray200()
            } else {
                backgroundColor = UIColor.gray600()
                checkColor = UIColor.gray200()
                if task.dueToday(withOffset: offset) {
                    backgroundColor = UIColor.forTaskValueLight(Int(task.value))
                    checkColor = UIColor.forTaskValue(Int(task.value))
                }
            }
        } else {
            boxCornerRadius = size/2
            if task.completed {
                boxFillColor = UIColor.gray400()
                backgroundColor = UIColor.gray600()
                checkColor = UIColor.gray200()
            } else {
                backgroundColor = UIColor.forTaskValueLight(Int(task.value))
                checkColor = UIColor.forTaskValue(Int(task.value))
            }
        }
        
        layer.setNeedsDisplay()
    }
    
    func configure(checklistItem: ChecklistItemProtocol, withTitle: Bool) {
        checked = checklistItem.completed
        if let layer = self.layer as? HRPGCheckmarkLayer {
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
        cornerRadius = 3
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
        let layer = self.layer as? HRPGCheckmarkLayer
        let timing = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let animation = CABasicAnimation(keyPath: "drawPercentage")
        animation.isAdditive = true
        animation.duration = 0.2
        animation.fillMode = kCAFillModeBoth
        animation.timingFunction = timing
        animation.fromValue = NSNumber(value: Float(layer?.drawPercentage ?? 0 - value))
        
        layer?.add(animation, forKey: nil)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer?.drawPercentage = value
        CATransaction.commit()
    }
    
    override func layoutSubviews() {
        let leftOffset = padding * 2 + size
        label.frame = CGRect(x: leftOffset, y: 0, width: frame.size.width - leftOffset, height: frame.size.height)
    }
    
    override func draw(_ rect: CGRect) {
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        UIGraphicsPushContext(ctx)
        
        ctx.clear(frame)
        backgroundColor?.setFill()
        ctx.fill(frame)

        let horizontalCenter = centerCheckbox ? frame.size.width / 2 : padding + size / 2
        let borderPath = UIBezierPath(roundedRect: CGRect(x: horizontalCenter - size / 2, y: frame.size.height / 2 - size / 2, width: size, height: size), cornerRadius: boxCornerRadius)
        if boxBorderColor != nil {
            boxBorderColor?.setStroke()
            borderPath.stroke()
        }
        boxFillColor.setFill()
        borderPath.fill()
        if let layer = self.layer as? HRPGCheckmarkLayer, layer.drawPercentage > 0 {
            let checkFrame = CGRect(x: padding, y: frame.size.height / 2 - size / 2, width: size, height: size)
            HabiticaIcons.drawCheckmark(frame: checkFrame, resizing: .center, checkmarkColor: checkColor, percentage: layer.drawPercentage)
        }
        UIGraphicsPopContext()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: size + padding * 2, height: size + padding * 2)
    }
}
