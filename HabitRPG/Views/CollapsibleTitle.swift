//
//  CollapsibleTitle.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

@IBDesignable
class CollapsibleTitle: UILabel, UIGestureRecognizerDelegate {
    
    private var carretIconView = UIImageView(image: #imageLiteral(resourceName: "carret_up"))
    private var infoIconView: UIImageView?
    
    var tapAction: (() -> Void)?
    
    var isCollapsed = false {
        didSet {
            if isCollapsed {
                carretIconView.image = #imageLiteral(resourceName: "carret_down")
            } else {
                carretIconView.image = #imageLiteral(resourceName: "carret_up")
            }
        }
    }
    
    var hasInfoIcon = false {
        didSet {
            if hasInfoIcon {
                let iconView = UIImageView(image: #imageLiteral(resourceName: "icon_help").withRenderingMode(.alwaysTemplate))
                iconView.tintColor = UIColor.purple400()
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
        carretIconView.contentMode = .center
                
        isUserInteractionEnabled = true
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        gestureRecognizer.delegate = self
        addGestureRecognizer(gestureRecognizer)
    }
    
    override func layoutSubviews() {
        carretIconView.frame = CGRect(x: bounds.size.width-40, y: bounds.size.height/2-12, width: 24, height: 24)
        if let iconView = infoIconView {
            iconView.frame = CGRect(x: intrinsicContentSize.width+8, y: 0, width: 18, height: bounds.size.height)
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
}
