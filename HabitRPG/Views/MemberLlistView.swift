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

    let avatarView: AvatarView = {
        let view = AvatarView()
        return view
    }()
    let usernameLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.gray50()
        view.font = UIFont.systemFont(ofSize: 16)
        return view
    }()
    let levelLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12)
        view.textColor = UIColor.gray200()
        return view
    }()
    let healthBar: ProgressBar = {
        let view = ProgressBar()
        view.barColor = UIColor.red100()
        return view
    }()
    let healthLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12)
        view.textColor = UIColor.gray200()
        return view
    }()
    let experienceBar: ProgressBar = {
        let view = ProgressBar()
        view.barColor = UIColor.yellow50()
        return view
    }()
    let experienceLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12)
        view.textColor = UIColor.gray200()
        return view
    }()
    let manaBar: ProgressBar = {
        let view = ProgressBar()
        view.barColor = UIColor.blue100()
        return view
    }()
    let manaLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12)
        view.textColor = UIColor.gray200()
        return view
    }()
    let classIconView = UIImageView()
    let leaderView: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12)
        view.textColor = UIColor.gray300()
        view.backgroundColor = UIColor.gray600()
        view.cornerRadius = 10
        view.textAlignment = .center
        view.text = L10n.leader
        return view
    }()

    func configure(member: MemberProtocol, isLeader: Bool) {
        avatarView.avatar = AvatarViewModel(avatar: member)
        usernameLabel.text = member.profile?.name

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
                levelLabel.text = "Lvl \(stats.level) \(habiticaClass)"
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
            } else {
                levelLabel.text = "Lvl \(stats.level)"
            }
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
        addSubview(usernameLabel)
        addSubview(leaderView)
        addSubview(levelLabel)
        addSubview(healthBar)
        addSubview(healthLabel)
        addSubview(experienceBar)
        addSubview(experienceLabel)
        addSubview(manaBar)
        addSubview(manaLabel)
        addSubview(classIconView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }

    func layout() {
        avatarView.pin.start(14).width(97).height(99).vCenter()
        usernameLabel.pin.top(14).after(of: avatarView).marginStart(16).height(21).sizeToFit(.height)
        leaderView.pin.top(14).after(of: usernameLabel).marginStart(6).height(20).sizeToFit(.height)
        leaderView.pin.width(leaderView.bounds.size.width + 16)
        levelLabel.pin.after(of: avatarView).marginStart(16).below(of: usernameLabel).marginTop(8).height(18).sizeToFit(.height)

        healthLabel.pin.below(of: levelLabel).height(16).sizeToFit(.height)
        experienceLabel.pin.below(of: healthLabel).marginTop(3).height(16).sizeToFit(.height)
        manaLabel.pin.below(of: experienceLabel).marginTop(3).height(16).sizeToFit(.height)

        let labelWidth = max(healthLabel.bounds.size.width, experienceLabel.bounds.size.width, manaLabel.bounds.size.width)

        healthLabel.pin.end(16).width(labelWidth)
        experienceLabel.pin.end(16).width(labelWidth)
        manaLabel.pin.end(16).width(labelWidth)

        healthBar.pin.after(of: avatarView).marginStart(16).below(of: levelLabel).marginTop(5).height(8).before(of: healthLabel).marginEnd(12)
        experienceBar.pin.after(of: avatarView).marginStart(16).below(of: healthBar).marginTop(11).height(8).before(of: healthLabel).marginEnd(12)
        manaBar.pin.after(of: avatarView).marginStart(16).below(of: experienceBar).marginTop(11).height(8).before(of: healthLabel).marginEnd(12)

        classIconView.pin.size(16).end(to: healthBar.edge.end).above(of: healthBar).marginBottom(6)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.size.width, height: 127)
    }
}