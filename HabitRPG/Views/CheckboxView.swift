//
//  CheckboxView.swift
//  Habitica
//
//  Created by Phillip Thelen on 06.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import Down

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
            checkView.isHidden = !checked
        }
    }
    var size: CGFloat = 24
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
    var checkView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
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
        label.numberOfLines = 0
        addSubview(checkView)
        addSubview(dimmOverlayView)
    }
    
    func configure(task: TaskProtocol, completed: Bool) {
        checked = completed
        checkView.image = Asset.checkmarkSmall.image
        if let layer = self.layer as? CheckmarkLayer {
            layer.drawPercentage = checked ? 1 : 0
        }
        
        let theme = ThemeService.shared.theme
        boxFillColor = UIColor(white: theme.isDark ? 0.0 : 1.0, alpha: theme.isDark ? 0.25 : 0.7)
        
        if task.type == "daily" {
            boxCornerRadius = 3
            if checked {
                backgroundColor = theme.windowBackgroundColor
                checkColor = theme.dimmedTextColor
                boxFillColor = theme.offsetBackgroundColor
            } else {
                backgroundColor = theme.offsetBackgroundColor
                checkColor = theme.ternaryTextColor
                if task.dueToday() {
                    backgroundColor = UIColor.forTaskValueLight(task.value)
                    checkColor = UIColor.forTaskValue(task.value)
                } else {
                    boxFillColor = theme.windowBackgroundColor
                }
            }
        } else {
            boxCornerRadius = size/2
            if checked {
                backgroundColor = theme.windowBackgroundColor
                boxFillColor = theme.offsetBackgroundColor
                checkColor = theme.dimmedTextColor
            } else {
                backgroundColor = UIColor.forTaskValueLight(task.value)
                checkColor = UIColor.forTaskValue(task.value)
            }
        }
        
        dimmOverlayView.isHidden = !theme.isDark
        dimmOverlayView.backgroundColor = theme.taskOverlayTint
        
        checkView.tintColor = checkColor
        
        layer.setNeedsDisplay()
    }
    
    func configure(checklistItem: ChecklistItemProtocol, withTitle: Bool, checkColor: UIColor, checkboxColor: UIColor, taskType: String?) {
        size = 20
        boxCornerRadius = taskType == TaskType.daily.rawValue ? 4 : (size/2)
        padding = 10
        checked = checklistItem.completed
        checkView.image = Asset.checkChecklist.image
        if let layer = self.layer as? CheckmarkLayer {
            layer.drawPercentage = checked ? 1 : 0
        }
        if withTitle {
            label.font = UIFontMetrics.default.scaledSystemFont(ofSize: 15)
            if label.superview == nil {
                self.addSubview(label)
            }
            guard let attributedString = try? Down(markdownString: checklistItem.text?.unicodeEmoji ?? "")
                    .toHabiticaAttributedString(baseSize: 15, textColor: ThemeService.shared.theme.primaryTextColor) else {
                    return
            }
            if checked {
                let strLength = attributedString.string.utf16.count
                attributedString.addAttribute(.strikethroughStyle, value: NSNumber(value: 2), range: NSRange(location: 0, length: strLength))
                label.attributedText = attributedString
            } else {
                label.attributedText = attributedString
            }
        }
        let theme = ThemeService.shared.theme
        label.textColor = checked ? theme.dimmedTextColor : theme.primaryTextColor
        backgroundColor = UIColor.clear
        boxFillColor = checkboxColor
        boxBorderColor = nil
        self.checkColor = checkColor
        centerCheckbox = false
        borderedBox = true
        checkView.tintColor = self.checkColor
        layer.setNeedsDisplay()
    }
    
    @objc
    private func viewTapped() {
        if let action = wasTouched {
            checked = !checked
            action()
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
        label.frame = CGRect(x: leftOffset + 12, y: 0, width: frame.size.width - leftOffset, height: frame.size.height)
        dimmOverlayView.frame = frame
        let horizontalCenter = centerCheckbox ? bounds.size.width / 2 : padding + size / 2
        checkView.frame = CGRect(x: horizontalCenter - size / 2, y: bounds.size.height / 2 - size / 2, width: size, height: size)
        layer.setNeedsDisplay()
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
        /*if let layer = self.layer as? CheckmarkLayer, layer.drawPercentage > 0 {
            let checkFrame = CGRect(x: horizontalCenter - size / 2, y: bounds.size.height / 2 - size / 2, width: size, height: size)
            HabiticaIcons.drawCheckmark(frame: checkFrame, resizing: .center, checkmarkColor: checkColor, percentage: layer.drawPercentage)
        }*/
        UIGraphicsPopContext()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: size + padding * 2, height: size + padding * 2)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: self.size + padding * 2)
    }
}
