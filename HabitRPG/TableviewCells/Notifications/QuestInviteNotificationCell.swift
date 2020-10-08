//
//  QuestInviteNotificationCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 02.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

class QuestInviteNotificationCell: BaseNotificationCell<NotificationQuestInviteProtocol> {
    
    private let goalTitleLabel: UILabel = {
        let label = UILabel()
        label.font = CustomFontMetrics.scaledBoldSystemFont(ofSize: 12)
        return label
    }()
    private let goalDetailLabel: UILabel = {
        let label = UILabel()
        label.font = CustomFontMetrics.scaledSystemFont(ofSize: 12)
        return label
    }()
    private let difficultyTitleLabel: UILabel = {
        let label = UILabel()
        label.font = CustomFontMetrics.scaledBoldSystemFont(ofSize: 12)
        label.text = "\(L10n.difficulty):"
        return label
    }()
    private let difficultyDetailView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        return view
    }()
    
    override func setupView() {
        super.setupView()
        addSubview(goalTitleLabel)
        addSubview(goalDetailLabel)
        addSubview(difficultyTitleLabel)
        addSubview(difficultyDetailView)
    }
    
    override func configureFor(notification: NotificationQuestInviteProtocol) {
        super.configureFor(notification: notification)
        showResponseButtons = true
        isClosable = false
    }
    
    func configureFor(quest: QuestProtocol) {
        attributedTitle = try? HabiticaMarkdownHelper.toHabiticaAttributedString(L10n.Notifications.questInvite(quest.text ?? ""))
        if (quest.boss?.health ?? 0) > 0 {
            goalTitleLabel.text = "\(L10n.defeat):"
            goalDetailLabel.text = quest.boss?.name
            difficultyDetailView.image = HabiticaIcons.imageOfDifficultyStars(difficulty: CGFloat(quest.boss?.strength ?? 0))
        } else {
            goalTitleLabel.text = "\(L10n.collect):"
            goalDetailLabel.text = quest.collect?.map { (questCollect) -> String in
                return "\(questCollect.count) \(questCollect.text ?? "")"
            }.joined(separator: ", ")
            difficultyDetailView.image = HabiticaIcons.imageOfDifficultyStars(difficulty: 1)
        }
        setNeedsLayout()
    }
    
    override func layout() {
        super.layout()
        
        goalTitleLabel.pin.start(20).top(to: titleLabel.edge.bottom).marginTop(12).end(20).height(16).sizeToFit(.height)
        difficultyTitleLabel.pin.start(20).top(to: goalTitleLabel.edge.bottom).marginTop(4).end(20).height(16).sizeToFit(.height)
        var startEdge = goalTitleLabel.edge.end
        if goalTitleLabel.frame.width < difficultyTitleLabel.frame.width {
            startEdge = difficultyTitleLabel.edge.end
        }
        goalDetailLabel.pin.start(to: startEdge).marginStart(8).top(to: titleLabel.edge.bottom).marginTop(12).end(20).height(16).sizeToFit(.height)
        difficultyDetailView.pin.start(to: startEdge).marginStart(8).top(to: goalTitleLabel.edge.bottom).marginTop(4).end(20).height(16).sizeToFit(.height)
        
        layoutResponseButtons(to: difficultyTitleLabel.edge.bottom)
        if declineButton.frame.totalHeight + 16 > cellHeight {
            cellHeight = declineButton.frame.totalHeight + 16
        }
    }
}
