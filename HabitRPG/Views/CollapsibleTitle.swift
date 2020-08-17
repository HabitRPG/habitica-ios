//
//  CollapsibleTitle.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import PinLayout

@IBDesignable
class CollapsibleTitle: UIView, UIGestureRecognizerDelegate {
    
    private var iconView = UIImageView()
    private var label = UILabel()
    private var subtitleLabel = UILabel()
    private var carretIconView = UIImageView(image: #imageLiteral(resourceName: "carret_up").withRenderingMode(.alwaysTemplate))
    private var infoIconView: UIImageView?
    
    var tapAction: (() -> Void)?
    
    var icon: UIImage? {
        get {
            return iconView.image
        }
        set {
            iconView.isHidden = newValue == nil
            iconView.image = newValue
            iconView.contentMode = .scaleAspectFit
            setNeedsLayout()
        }
    }
    
    @IBInspectable var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
            setNeedsLayout()
        }
    }
    
    @IBInspectable var subtitle: String? {
        get {
            return subtitleLabel.text
        }
        set {
            subtitleLabel.isHidden = newValue == nil
            subtitleLabel.text = newValue
            setNeedsLayout()
        }
    }
    
    @IBInspectable var textColor: UIColor {
        get {
            return label.textColor
        }
        set {
            label.textColor = newValue
        }
    }
    
    @IBInspectable var subtitleColor: UIColor {
        get {
            return subtitleLabel.textColor
        }
        set {
            subtitleLabel.textColor = newValue
        }
    }
    
    var font: UIFont {
        get {
            return label.font
        }
        set {
            label.font = newValue
            setNeedsLayout()
        }
    }
    
    var subtitleFont: UIFont {
        get {
            return subtitleLabel.font
        }
        set {
            subtitleLabel.font = newValue
            setNeedsLayout()
        }
    }

    var insets = UIEdgeInsets.zero
    
    var isCollapsed = false {
        didSet {
            if isCollapsed {
                carretIconView.image = #imageLiteral(resourceName: "carret_down").withRenderingMode(.alwaysTemplate)
            } else {
                carretIconView.image = #imageLiteral(resourceName: "carret_up").withRenderingMode(.alwaysTemplate)
            }
        }
    }
    
    var hasInfoIcon = false {
        didSet {
            if hasInfoIcon {
                let iconView = UIImageView(image: #imageLiteral(resourceName: "icon_help").withRenderingMode(.alwaysTemplate))
                iconView.tintColor = ThemeService.shared.theme.tintColor
                iconView.isUserInteractionEnabled = true
                iconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(infoIconTapped)))
                iconView.contentMode = .center
                addSubview(iconView)
                infoIconView = iconView
            } else {
                infoIconView?.removeFromSuperview()
                infoIconView = nil
            }
        }
    }
    
    var showCarret = true {
        didSet {
            carretIconView.isHidden = !showCarret
        }
    }
    
    var infoIconAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    // MARK: - Private Helper Methods
    
    private func setupView() {
        addSubview(carretIconView)
        addSubview(label)
        addSubview(subtitleLabel)
        addSubview(iconView)
        iconView.isHidden = true
        subtitleLabel.isHidden = true
        carretIconView.contentMode = .center
        carretIconView.tintColor = ThemeService.shared.theme.dimmedColor
        label.textColor = ThemeService.shared.theme.primaryTextColor
                
        isUserInteractionEnabled = true
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        gestureRecognizer.delegate = self
        addGestureRecognizer(gestureRecognizer)
    }
    
    override func layoutSubviews() {
        var leftInset = insets.left
        if !iconView.isHidden {
            iconView.pin.start(leftInset + 6).size(28).vCenter()
            leftInset = iconView.frame.origin.x + iconView.frame.size.width + 16
        }
        if subtitleLabel.isHidden {
            label.pin.start(leftInset).vertically().sizeToFit(.height)
        } else {
            label.pin.start(leftInset).bottom(to: edge.vCenter).marginBottom(1).sizeToFit()
            subtitleLabel.pin.top(to: edge.vCenter).marginTop(1).start(leftInset).sizeToFit()
        }
        carretIconView.pin.end(16).size(24).vCenter()
        if let iconView = infoIconView {
            iconView.pin.start(label.frame.size.width + 8).width(18).vertically()
        }
    }
    
    @objc
    func viewTapped() {
        if let action = self.tapAction {
            action()
        }
    }
    
    @objc
    func infoIconTapped() {
        if let action = self.infoIconAction {
            action()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if self.infoIconView?.frame.contains(touch.location(in: self)) ?? false {
            return false
        }
        return true
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width, height: subtitle != nil ? 60 : 48)
    }
}
