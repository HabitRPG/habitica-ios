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
    
    private var label = UILabel()
    private var carretIconView = UIImageView(image: #imageLiteral(resourceName: "carret_up").withRenderingMode(.alwaysTemplate))
    private var infoIconView: UIImageView?
    
    var tapAction: (() -> Void)?
    
    @IBInspectable var text: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
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
    
    var font: UIFont {
        get {
            return label.font
        }
        set {
            label.font = newValue
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
        carretIconView.contentMode = .center
        carretIconView.tintColor = ThemeService.shared.theme.dimmedColor
        label.textColor = ThemeService.shared.theme.primaryTextColor
                
        isUserInteractionEnabled = true
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        gestureRecognizer.delegate = self
        addGestureRecognizer(gestureRecognizer)
    }
    
    override func layoutSubviews() {
        label.pin.start(insets.left).vertically().sizeToFit(.height)
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
        return CGSize(width: super.intrinsicContentSize.width, height: 48)
    }
}
