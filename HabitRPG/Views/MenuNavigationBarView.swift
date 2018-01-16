//
//  MenuNavigationBarView.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.01.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit

class MenuNavigationBarView: UIView {
    
    @objc public var messagesAction: (() -> Void)?
    @objc public var settingsAction: (() -> Void)?
    
    @IBOutlet weak var avatarView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var messagesButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
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
        if let view = viewFromNibForClass() {
            translatesAutoresizingMaskIntoConstraints = true
            
            view.frame = bounds
            view.autoresizingMask = [
                UIViewAutoresizing.flexibleWidth,
                UIViewAutoresizing.flexibleHeight
            ]
            addSubview(view)

            setNeedsUpdateConstraints()
            updateConstraints()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    @objc
    public func configure(user: User) {
        usernameLabel.text = user.username
        user.setAvatarSubview(avatarView, showsBackground: true, showsMount: false, showsPet: false)
    }
    
    @IBAction func messageButtonTapped(_ sender: Any) {
        if let action = messagesAction {
            action()
        }
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        if let action = settingsAction {
            action()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: 72)
    }
}
