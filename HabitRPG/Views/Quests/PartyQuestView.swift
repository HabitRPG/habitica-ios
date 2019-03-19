//
//  PartyQuestView.swift
//  Habitica
//
//  Created by Phillip Thelen on 07.05.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class PartyQuestView: UIView {
    
    let questImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    
    let backgroundView: UIView = {
        let view = UIImageView()
        view.isHidden = true
        view.image = HabiticaIcons.imageOfQuestBackground(bossColorDark: UIColor.gray700(),
                                                          bossColorMedium: UIColor.gray400(),
                                                          bossColorLight: UIColor.gray500())
            .resizableImage(withCapInsets: UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10),
                            resizingMode: UIImage.ResizingMode.stretch)
        return view
    }()
    var progressBarViews = [QuestProgressBarView]()
    var isBossQuest = true
    
    init() {
        super.init(frame: CGRect.zero)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        addSubview(questImageView)
        addSubview(backgroundView)
    }
    
    func configure(state: QuestStateProtocol, quest: QuestProtocol) {
        ImageManager.getImage(name: "quest_\(quest.key ?? "")") { (image, _) in
            self.questImageView.image = image
            self.setNeedsLayout()
            self.invalidateIntrinsicContentSize()
        }
        if let boss = quest.boss {
            isBossQuest = true
            let bossView = progressBarViews.first ?? QuestProgressBarView()
            if progressBarViews.isEmpty {
                addSubview(bossView)
                progressBarViews.append(bossView)
            }
            bossView.titleTextColor = UIColor.black.withAlphaComponent(0.8)
            bossView.valueTextColor = UIColor.gray200()
            bossView.barBackgroundColor = UIColor.gray500()
            bossView.title = boss.name
            bossView.maxValue = Float(boss.health)
            bossView.barColor = UIColor.red100()
            bossView.currentValue = state.progress?.health ?? 0
            
            if progressBarViews.count > 1 {
                progressBarViews.forEach { (view) in
                    if view != bossView {
                        view.removeFromSuperview()
                    }
                }
                progressBarViews = [bossView]
            }
        } else {
            progressBarViews.forEach { (view) in
                view.removeFromSuperview()
            }
            progressBarViews.removeAll()
            isBossQuest = false
            quest.collect?.forEach { (questCollect) in
                let collectView = QuestProgressBarView()
                collectView.titleTextColor = UIColor.black.withAlphaComponent(0.8)
                collectView.valueTextColor = UIColor.gray200()
                collectView.barBackgroundColor = UIColor.gray500()
                collectView.title = questCollect.text
                collectView.maxValue = Float(questCollect.count)
                let value = state.progress?.collect.first(where: { (collect) -> Bool in
                    return collect.key == questCollect.key
                })?.count
                collectView.currentValue = Float(value ?? 0)
                collectView.barColor = UIColor.green100()
                ImageManager.getImage(name: "quest_\(quest.key ?? "")_\(questCollect.key ?? "")", completion: { (image, _) in
                    collectView.bigIcon = image
                })
                addSubview(collectView)
                progressBarViews.append(collectView)
            }
        }
        backgroundView.isHidden = false
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }
    
    func setPendingDamage(_ pending: Float) {
        if isBossQuest {
            progressBarViews.first?.pendingBarColor = UIColor.yellow50()
            progressBarViews.first?.pendingTitle = L10n.pendingDamage
            progressBarViews.first?.pendingValue = pending
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    func layout() {
        questImageView.pin.top(12).hCenter().height(questImageView.image?.size.height ?? 0)
        backgroundView.pin.top(to: questImageView.edge.bottom).marginTop(12)
        var edge = backgroundView.edge.top
        for progressView in progressBarViews {
            progressView.pin.top(to: edge).marginTop(10).start(16).end(16).height(progressView.intrinsicContentSize.height)
            edge = progressView.edge.bottom
        }
        backgroundView.pin.top(to: questImageView.edge.bottom).marginTop(12).bottom(to: edge).marginBottom(-10).start().end()
    }
    
    override var intrinsicContentSize: CGSize {
        layout()
        return CGSize(width: bounds.size.width, height: backgroundView.frame.origin.y + backgroundView.frame.size.height + 12)
    }
}
