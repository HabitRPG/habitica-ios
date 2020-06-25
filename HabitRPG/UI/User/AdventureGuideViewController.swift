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
                
                self.setAchievements(achievements)
            }
            }).start()
    }
    
    override func applyTheme(theme: Theme) {
        super.applyTheme(theme: theme)
        view.backgroundColor = theme.contentBackgroundColor
        gettingStartedLabel.textColor = theme.primaryTextColor
        progressView.backgroundColor = theme.offsetBackgroundColor
        progressView.tintColor = .yellow50
        progressLabel.textColor = .yellow5
        yourProgressLabel.textColor = theme.secondaryTextColor
        navigationController?.navigationBar.tintColor = theme.tintColor
        navigationController?.navigationBar.backgroundColor = theme.contentBackgroundColor
    }
    
    func setAchievements(_ achievements: [String: Bool]) {
        achievementsStackview.subviews.forEach { $0.removeFromSuperview() }
        for achievement in achievements {
            let view = AdventureGuideAchievement()
            view.setAchievement(title: AdventureGuideViewController.titles[achievement.key] ?? "", description: AdventureGuideViewController.descriptions[achievement.key] ?? "", iconName: achievement.key, isCompleted: achievement.value)
            achievementsStackview.addArrangedSubview(view)
        }
    }
    
    static let titles = [
        "createdTask": L10n.createdTaskTitle,
        "completedTask": L10n.completedTaskTitle,
        "hatchedPet": L10n.hatchedPetTitle,
        "fedPet": L10n.fedPetTitle,
        "purchasedEquipment": L10n.purchasedEquipmentTitle
    ]
    static let descriptions = [
        "createdTask": L10n.createTaskDescription,
        "completedTask": L10n.completeTaskDescription,
        "hatchedPet": L10n.hatchPetDescription,
        "fedPet": L10n.feedPetDescription,
        "purchasedEquipment": L10n.purchasedEquipmentTitle
    ]
}

class AdventureGuideAchievement: UIView, Themeable {
    
    var isCompleted = false {
        didSet {
            applyTheme(theme: ThemeService.shared.theme)
        }
    }
    
    private let iconView: UIImageView = {
        let view = UIImageView()
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
            titleLabel.textColor = theme.ternaryTextColor
            descriptionLabel.textColor = theme.ternaryTextColor
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
            attributedTitle.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedTitle.length))
            titleLabel.attributedText = attributedTitle
            iconView.setImagewith(name: "achievement-\(iconName)2x")
        } else {
            titleLabel.text = title
            iconView.setImagewith(name: "achievement-unearned2x")
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
        let textHeight = titleLabel.frame.size.height + descriptionLabel.frame.size.height
        let offset = (frame.size.height - textHeight) / 2
        titleLabel.pin.top(offset)
        descriptionLabel.pin.below(of: titleLabel)
    }
}
