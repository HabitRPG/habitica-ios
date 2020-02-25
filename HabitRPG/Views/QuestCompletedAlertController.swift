//
//  QuestCompletedAlertController.swift
//  Habitica
//
//  Created by Phillip Thelen on 01.07.19.
//  Copyright © 2019 HabitRPG Inc. All rights reserved.
//

import Foundation

class QuestCompletedAlertController: HabiticaAlertController {

    private let inventoryRepository = InventoryRepository()
    
    private let questDetailView: QuestDetailView = {
        let view = QuestDetailView(frame: CGRect.zero)
        view.questGoalView.isHidden = true
        view.questTypeLabel.isHidden = true
        view.questGoalHeight.constant = 0
        return view
    }()
    
    init(questKey: String) {
        super.init()
        title = L10n.questCompletedTitle
        addCloseAction()
        
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
                let imageView = UIImageView()
                imageView.contentMode = .center
                ImageManager.setImage(on: imageView, name: "quest_" + key)
                stackView.addArrangedSubview(imageView)
            }
            let endTextView = UITextView()
            endTextView.text = quest.completion
            endTextView.font = CustomFontMetrics.scaledSystemFont(ofSize: 14)
            endTextView.isScrollEnabled = false
            stackView.addArrangedSubview(endTextView)
        }).start()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
