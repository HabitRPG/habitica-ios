//
//  ClassSelectionOptionView.swift
//  Habitica
//
//  Created by Phillip Thelen on 26.04.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class ClassSelectionOptionView: UIView {
    private let avatarView: AvatarView = {
        let avatarView = AvatarView()
        avatarView.showBackground = false
        avatarView.showPet = false
        avatarView.showMount = false
        avatarView.ignoreSleeping = true
        avatarView.size = .compact
        return avatarView
    }()
    private let labelWrapper: UIView = {
        let labelWrapper = UIView()
        labelWrapper.backgroundColor = UIColor.gray700
        if #available(iOS 26.0, *) {
            labelWrapper.cornerConfiguration = .capsule()
        } else {
            labelWrapper.layer.cornerRadius = UIConstants.mediumCornerRadius

        }
        return labelWrapper
    }()
    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private var selectedBackgroundColor: UIColor = .tintColor
    
    private var onSelected: (() -> Void)?
    
    var isSelected = false {
        didSet {
            let newWidth = self.isSelected ? 4 : 0
            let widthAnimation = CABasicAnimation(keyPath: "borderWidth")
            widthAnimation.fromValue = self.labelWrapper.layer.borderWidth
            widthAnimation.toValue = newWidth
            widthAnimation.duration = 0.2
            self.labelWrapper.layer.borderWidth = CGFloat(newWidth)
            self.labelWrapper.layer.add(widthAnimation, forKey: "border width")
            UIView.animate(withDuration: 0.2) {
                self.label.textColor = self.isSelected ? .white : ThemeService.shared.theme.primaryTextColor
                self.labelWrapper.backgroundColor = self.isSelected ? self.selectedBackgroundColor : ThemeService.shared.theme.windowBackgroundColor
            }
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            labelWrapper.layer.borderColor = tintColor.cgColor
        }
    }
    
    var userStyle: UserStyleProtocol? {
        didSet {
            if let userStyle = self.userStyle {
                avatarView.avatar = AvatarViewModel(avatar: userStyle)
            }
        }
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
        addSubview(avatarView)
        addSubview(labelWrapper)
        labelWrapper.addSubview(label)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapped)))
        isUserInteractionEnabled = true
        backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarView.pin.width(114).height(90).top((bounds.size.height-133)/2).hCenter()
        labelWrapper.pin.width(140).height(46).hCenter().below(of: avatarView).marginTop(10)
        label.pin.all()
    }
    
    func configure(habiticaClass: HabiticaClass, onSelected: @escaping (() -> Void)) {
        self.onSelected = onSelected
        switch habiticaClass {
        case .warrior:
            label.text = L10n.Classes.warrior
            tintColor = UIColor.red10
            selectedBackgroundColor = .red1
        case .mage:
            label.text = L10n.Classes.mage
            tintColor = UIColor.blue10
            selectedBackgroundColor = .blue1
        case .healer:
            label.text = L10n.Classes.healer
            tintColor = UIColor.yellow5
            selectedBackgroundColor = .yellow1
        case .rogue:
            label.text = L10n.Classes.rogue
            tintColor = UIColor.purple400
            selectedBackgroundColor = .purple100
        }
    }
    
    @objc
    private func onTapped() {
        if let action = onSelected {
            action()
        }
    }
}
