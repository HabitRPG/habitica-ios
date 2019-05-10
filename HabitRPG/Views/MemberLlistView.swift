//
//  MemberLlistView.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models
import PinLayout

class MemberListView: UIView {

    var viewTapped: (() -> Void)?
    
    let avatarView: AvatarView = AvatarView()
    let displayNameLabel: UsernameLabel = UsernameLabel()
    let sublineLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12)
        view.textColor = ThemeService.shared.theme.ternaryTextColor
        return view
    }()
    let healthBar: ProgressBar = {
        let view = ProgressBar()
        if ThemeService.shared.theme.isDark {
            view.barColor = UIColor.red50()
        } else {
            view.barColor = UIColor.red100()
        }
        return view
    }()
    let healthLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12)
        view.textColor = ThemeService.shared.theme.ternaryTextColor
        return view
    }()
    let experienceBar: ProgressBar = {
        let view = ProgressBar()
        if ThemeService.shared.theme.isDark {
            view.barColor = UIColor.yellow10()
        } else {
            view.barColor = UIColor.yellow50()
        }
        return view
    }()
    let experienceLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12)
        view.textColor = ThemeService.shared.theme.ternaryTextColor
        return view
    }()
    let manaBar: ProgressBar = {
        let view = ProgressBar()
        if ThemeService.shared.theme.isDark {
            view.barColor = UIColor.blue50()
        } else {
            view.barColor = UIColor.blue100()
        }
        return view
    }()
    let manaLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12)
        view.textColor = ThemeService.shared.theme.ternaryTextColor
        return view
    }()
    let classIconView = UIImageView()
    let buffIconView = UIImageView(image: HabiticaIcons.imageOfBuffIcon)
    let leaderView: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12)
        view.textColor = ThemeService.shared.theme.dimmedTextColor
        view.backgroundColor = ThemeService.shared.theme.offsetBackgroundColor
        view.cornerRadius = 10
        view.textAlignment = .center
        view.text = L10n.leader
        return view
    }()

    func configure(member: MemberProtocol, isLeader: Bool) {
        avatarView.avatar = AvatarViewModel(avatar: member)
        displayNameLabel.text = member.profile?.name
        displayNameLabel.contributorLevel = member.contributor?.level ?? 0

        leaderView.isHidden = !isLeader

        if let stats = member.stats {
            healthBar.maxValue = CGFloat(stats.maxHealth)
            healthBar.value = CGFloat(stats.health)
            healthLabel.text = "\(Int(stats.health)) / \(Int(stats.maxHealth))"
            experienceBar.maxValue = CGFloat(stats.toNextLevel)
            experienceBar.value = CGFloat(stats.experience)
            experienceLabel.text = "\(Int(stats.experience)) / \(Int(stats.toNextLevel))"
            manaBar.maxValue = CGFloat(stats.maxMana)
            manaBar.value = CGFloat(stats.mana)
            manaLabel.text = "\(Int(stats.mana)) / \(Int(stats.maxMana))"

            if member.hasHabiticaClass, let habiticaClass = HabiticaClass(rawValue: stats.habitClass ?? "") {
                switch habiticaClass {
                case .warrior:
                    classIconView.image = HabiticaIcons.imageOfWarriorLightBg
                case .mage:
                    classIconView.image = HabiticaIcons.imageOfMageLightBg
                case .healer:
                    classIconView.image = HabiticaIcons.imageOfHealerLightBg
                case .rogue:
                    classIconView.image = HabiticaIcons.imageOfRogueLightBg
                }
            }
            
            if let username = member.username {
                sublineLabel.text = "@\(username) · Lvl \(stats.level)"
            } else {
                sublineLabel.text = "Lvl \(stats.level)"
            }
            
            buffIconView.isHidden = stats.buffs?.isBuffed != true
        }
        setNeedsLayout()
    }

    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        addSubview(avatarView)
        addSubview(displayNameLabel)
        addSubview(leaderView)
        addSubview(sublineLabel)
        addSubview(healthBar)
        addSubview(healthLabel)
        addSubview(experienceBar)
        addSubview(experienceLabel)
        addSubview(manaBar)
        addSubview(manaLabel)
        addSubview(classIconView)
        addSubview(buffIconView)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapView)))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }

    func layout() {
        avatarView.pin.start().width(97).height(99).vCenter()
        displayNameLabel.pin.top(14).after(of: avatarView).marginStart(16).height(21).sizeToFit(.height)
        leaderView.pin.top(to: displayNameLabel.edge.top).height(20).sizeToFit(.height)
        leaderView.pin.width(leaderView.bounds.size.width + 16).end()
        sublineLabel.pin.after(of: avatarView).marginStart(16).below(of: displayNameLabel).marginTop(4).height(18).sizeToFit(.height)

        healthLabel.pin.below(of: sublineLabel).height(16).sizeToFit(.height)
        experienceLabel.pin.below(of: healthLabel).marginTop(3).height(16).sizeToFit(.height)
        manaLabel.pin.below(of: experienceLabel).marginTop(3).height(16).sizeToFit(.height)

        let labelWidth = max(healthLabel.bounds.size.width, experienceLabel.bounds.size.width, manaLabel.bounds.size.width)

        healthLabel.pin.end().width(labelWidth)
        experienceLabel.pin.end().width(labelWidth)
        manaLabel.pin.end().width(labelWidth)

        healthBar.pin.after(of: avatarView).marginStart(16).below(of: sublineLabel).marginTop(4).height(8).before(of: healthLabel).marginEnd(12)
        experienceBar.pin.after(of: avatarView).marginStart(16).below(of: healthBar).marginTop(11).height(8).before(of: healthLabel).marginEnd(12)
        manaBar.pin.after(of: avatarView).marginStart(16).below(of: experienceBar).marginTop(11).height(8).before(of: healthLabel).marginEnd(12)

        buffIconView.pin.size(15).after(of: displayNameLabel).top(to: displayNameLabel.edge.top).marginStart(6).marginTop(4)
        classIconView.pin.size(15).top(to: displayNameLabel.edge.top).marginStart(4).marginTop(4)
        if buffIconView.isHidden {
            classIconView.pin.after(of: displayNameLabel)
        } else {
            classIconView.pin.after(of: buffIconView)
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.size.width, height: 127)
    }
    
    @objc
    private func tapView() {
        if let action = viewTapped {
            action()
        }
    }
}
