//
//  AdventureGuideViewController.swift
//  Habitica
//
//  Created by Phillip Thelen on 23.06.20.
//  Copyright © 2020 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models

class AdventureGuideViewController: BaseUIViewController {
    
    private let userRepository = UserRepository()
    
    @IBOutlet weak var gettingStartedLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var yourProgressLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var achievementsStackview: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        let transform = CGAffineTransform(scaleX: 1, y: 2)
        progressView.transform = transform
        progressView.cornerRadius = 2
        
        userRepository.getUser().on(value: { user in
            if let achievements = user.achievements?.onboardingAchievements {
                let earned = achievements.filter { $0.value }.count
                let percentCompleted = Float(earned) / Float(achievements.count)
                self.progressView.setProgress(percentCompleted, animated: false)
                self.progressLabel.text = L10n.percentComplete(Int(percentCompleted * 100.0))
                
                self.setAchievements(keys: user.achievements?.onboardingAchievementKeys ?? [], achievements: achievements)
            }
            }).start()
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        view.backgroundColor = theme.contentBackgroundColor
        var textColor = UIColor.gray50
        if (theme.isDark) {
            textColor = theme.primaryTextColor
        }
        gettingStartedLabel.textColor = textColor
        let attrString = NSMutableAttributedString(string: L10n.adventureGuideDescription)
        attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: NSRange(location: 0, length: attrString.length))
        attrString.addAttributesToSubstring(string: L10n.fiveAchievements, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold)
        ])
        attrString.addAttributesToSubstring(string: L10n.hundredGold, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.yellow5
        ])
        descriptionLabel.attributedText = attrString
        progressView.trackTintColor = theme.offsetBackgroundColor
        progressView.tintColor = .yellow50
        progressLabel.textColor = .yellow5
        yourProgressLabel.textColor = theme.secondaryTextColor
        navigationController?.navigationBar.tintColor = theme.tintColor
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = theme.contentBackgroundColor
        navigationController?.navigationBar.backgroundColor = theme.contentBackgroundColor
    }
    
    func setAchievements(keys: [String], achievements: [String: Bool]) {
        achievementsStackview.subviews.forEach { $0.removeFromSuperview() }
        for key in keys {
            let achievement = achievements[key]
            let view = AdventureGuideAchievement()
            view.setAchievement(title: AdventureGuideViewController.titles[key] ?? "",
                                description: AdventureGuideViewController.descriptions[key] ?? "",
                                iconName: key,
                                isCompleted: achievement ?? false)
            achievementsStackview.addArrangedSubview(view)
        }
    }
    
    static let titles = [
        "createdTask": L10n.createTaskTitle,
        "completedTask": L10n.completeTaskTitle,
        "hatchedPet": L10n.hatchPetTitle,
        "fedPet": L10n.feedPetTitle,
        "purchasedEquipment": L10n.purchaseEquipmentTitle
    ]
    static let descriptions = [
        "createdTask": L10n.createTaskDescription,
        "completedTask": L10n.completeTaskDescription,
        "hatchedPet": L10n.hatchPetDescription,
        "fedPet": L10n.feedPetDescription,
        "purchasedEquipment": L10n.purchaseEquipmentDescription
    ]
}

class AdventureGuideAchievement: UIView, Themeable {
    
    var isCompleted = false {
        didSet {
            applyTheme(theme: ThemeService.shared.theme)
        }
    }
    
    private let iconView: NetworkImageView = {
        let view = NetworkImageView()
        view.contentMode = .center
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 0
        return label
    }()
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        ThemeService.shared.addThemeable(themable: self)
    }
    
    func applyTheme(theme: Theme) {
        if isCompleted {
            if theme.isDark {
                titleLabel.textColor = .gray300
                descriptionLabel.textColor = .gray300
            } else {
                titleLabel.textColor = theme.ternaryTextColor
                descriptionLabel.textColor = theme.ternaryTextColor
            }
        } else {
            titleLabel.textColor = theme.primaryTextColor
            descriptionLabel.textColor = theme.primaryTextColor
        }
    }
    
    func setAchievement(title: String, description: String, iconName: String, isCompleted: Bool) {
        self.isCompleted = isCompleted
        descriptionLabel.text = description
        if isCompleted {
            let attributedTitle: NSMutableAttributedString =  NSMutableAttributedString(string: title)
            attributedTitle.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSRange(location: 0, length: attributedTitle.length))
            titleLabel.attributedText = attributedTitle
            iconView.setImagewith(name: "achievement-\(iconName)2x")
            iconView.alpha = 1
        } else {
            titleLabel.text = title
            iconView.setImagewith(name: "achievement-unearned2x")
            iconView.alpha = 0.5
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 100, height: 80)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        iconView.pin.start().top().bottom().width(48)
        titleLabel.pin.after(of: iconView).marginStart(26).sizeToFit()
        descriptionLabel.pin.after(of: iconView).marginStart(26).right().sizeToFit(.width)
        let textHeight = titleLabel.frame.size.height + descriptionLabel.frame.size.height + 4
        let offset = (frame.size.height - textHeight) / 2
        titleLabel.pin.top(offset)
        descriptionLabel.pin.below(of: titleLabel).marginTop(4)
    }
}
