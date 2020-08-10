//
//  HabitButton.swift
//  Habitica
//
//  Created by Phillip Thelen on 06.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class HabitButton: UIView {
    
    private let label = UIImageView()
    private let roundedView = UIView()
    private let interactionOverlay = UIView()
    private let tapArea = UIView()
    private var buttonSize: CGFloat = 24
    private var isActive = false
    var dimmOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeService.shared.theme.taskOverlayTint
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    var action: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        addSubview(roundedView)
        roundedView.layer.cornerRadius = buttonSize / 2
        label.contentMode = .scaleAspectFit
        isUserInteractionEnabled = true
        roundedView.layer.borderWidth = 2
        addSubview(dimmOverlayView)
        addSubview(label)
        interactionOverlay.backgroundColor = .init(white: 1.0, alpha: 0.4)
        interactionOverlay.isUserInteractionEnabled = false
        interactionOverlay.alpha = 0
        addSubview(interactionOverlay)
        addSubview(tapArea)
        tapArea.isUserInteractionEnabled = true
        tapArea.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    func configure(task: TaskProtocol, isNegative: Bool) {
        isActive = isNegative ? task.down : task.up
        let theme = ThemeService.shared.theme
        if isNegative {
            label.image = Asset.minus.image.withRenderingMode(.alwaysTemplate)
        } else {
            label.image = Asset.plus.image.withRenderingMode(.alwaysTemplate)
        }
        if isActive {
            backgroundColor = UIColor.forTaskValueLight(Int(task.value))
            
            if task.value >= -1 && task.value < 1 {
                if ThemeService.shared.theme.isDark {
                    roundedView.backgroundColor = UIColor.yellow5
                } else {
                    roundedView.backgroundColor = UIColor.yellow10
                }
            } else {
                roundedView.backgroundColor = UIColor.forTaskValue(Int(task.value))
            }
            roundedView.layer.borderColor = UIColor.clear.cgColor
            label.tintColor = .white
        } else {
            backgroundColor = theme.windowBackgroundColor
            roundedView.layer.borderColor = theme.separatorColor.cgColor
            roundedView.backgroundColor = theme.windowBackgroundColor
            label.tintColor = theme.separatorColor
        }
                
        dimmOverlayView.isHidden = !theme.isDark
        dimmOverlayView.backgroundColor = theme.taskOverlayTint
    }
    
    override func layoutSubviews() {
        let verticalCenter = frame.size.height / 2
        let horizontalCenter = frame.size.width / 2
        
        roundedView.frame = CGRect(x: horizontalCenter - buttonSize/2, y: verticalCenter - buttonSize/2, width: buttonSize, height: buttonSize)
        label.frame = CGRect(x: horizontalCenter - 6, y: verticalCenter - 6, width: 12, height: 12)
        dimmOverlayView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        interactionOverlay.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        tapArea.frame = CGRect(x: -20, y: -4, width: frame.size.width + 40, height: frame.size.height + 8)
        super.layoutSubviews()
    }
    
    @objc
    private func handleTap() {
        if isActive {
            if let action = action {
                action()
            }
            UIView.animate(withDuration: 0.2, animations: {[weak self] in
                self?.interactionOverlay.alpha = 1
            }, completion: {[weak self] (_) in
            UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseInOut, animations: {
                self?.interactionOverlay.alpha = 0
            }, completion: nil)
            })
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.insetBy(dx: -20, dy: -4).contains(point)
    }
}
