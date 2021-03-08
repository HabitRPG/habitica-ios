//
//  MaintenanceViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 20.10.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import Foundation
import PinLayout

class MaintenanceViewController: UIViewController, Themeable {
    
    private let configRepository = ConfigRepository()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 20, ofWeight: .semibold)
        label.textAlignment = .center
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    private let appstoreButton: UIButton = {
        let button = UIButton()
        button.cornerRadius = 6
        button.setTitle(L10n.openAppStore, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(appstoreButtonTapped), for: .touchUpInside)
        button.isPointerInteractionEnabled = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(appstoreButton)
        
        ThemeService.shared.addThemeable(themable: self)
    }
    
    func applyTheme(theme: Theme) {
        view.backgroundColor = theme.contentBackgroundColor
        titleLabel.textColor = theme.primaryTextColor
        descriptionLabel.textColor = theme.secondaryTextColor
        appstoreButton.backgroundColor = theme.backgroundTintColor
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if ThemeService.shared.theme.isDark {
            return .lightContent
        } else {
            return .default
        }
    }
    
    func configure(title: String, descriptionString: String, showAppstoreButton: Bool) {
        titleLabel.text = title
        descriptionLabel.text = descriptionString
        appstoreButton.isHidden = !showAppstoreButton
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        titleLabel.pin.top(100).left(32).right(32).maxWidth(400).hCenter().sizeToFit(.width)
        descriptionLabel.pin.below(of: titleLabel).marginTop(16).left(32).right(32).maxWidth(400).hCenter().sizeToFit(.width)
        
        appstoreButton.pin.left(32).right(32).bottom(50).height(44)
    }
    
    @objc
    func appstoreButtonTapped() {
        if let url = URL(string: configRepository.string(variable: .appstoreUrl) ?? "") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
