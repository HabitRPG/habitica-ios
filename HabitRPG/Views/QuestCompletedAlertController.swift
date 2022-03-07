//
//  QuestCompletedAlertController.swift
//  Habitica
//
//  Created by Phillip Thelen on 01.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import UIKit

class QuestCompletedAlertController: HabiticaAlertController {

    private let inventoryRepository = InventoryRepository()
    
    private let questDetailView: QuestDetailView = {
        let view = QuestDetailView(frame: CGRect.zero)
        view.questGoalView.isHidden = true
        view.questTypeLabel.isHidden = true
        view.questGoalHeight.constant = -20
        return view
    }()
    
    init(questKey: String) {
        super.init()
        title = L10n.questCompletedTitle
        addAction(title: L10n.onwards, style: .default, isMainAction: true)
        contentViewInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        
        inventoryRepository.getQuest(key: questKey).skipNil().take(first: 1).on(value: {[weak self] quest in
            self?.message = quest.text
            self?.questDetailView.configure(quest: quest)
            let stackView = StackView()
            stackView.axis = .vertical
            self?.contentView = stackView
            if let detailView = self?.questDetailView {
                stackView.addArrangedSubview(detailView)
            }
            if let key = quest.key {
                let imageView = NetworkImageView()
                imageView.contentMode = .scaleAspectFit
                ImageManager.getImage(name: "quest_" + key) { (image, _) in
                    imageView.image = image
                    imageView.addHeightConstraint(height: image?.size.height ?? 0)
                    stackView.setNeedsLayout()
                    self?.view.setNeedsLayout()
                }
                stackView.addArrangedSubview(imageView)
            }
            let endTextView = UITextView()
            endTextView.attributedText = try? HabiticaMarkdownHelper.toHabiticaAttributedString(quest.completion ?? "")
            endTextView.font = UIFontMetrics.default.scaledSystemFont(ofSize: 14)
            endTextView.textAlignment = .center
            endTextView.textColor = ThemeService.shared.theme.primaryTextColor
            endTextView.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
            endTextView.isScrollEnabled = false
            endTextView.addHeightConstraint(height: endTextView.sizeThatFits(CGSize(width: 240, height: 1000)).height)
            stackView.addArrangedSubview(endTextView)
            stackView.setNeedsLayout()
            self?.view.setNeedsLayout()
        }).start()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonUpperSpacing.constant = 12
        buttonLowerSpacing.constant = 20
    }
}
