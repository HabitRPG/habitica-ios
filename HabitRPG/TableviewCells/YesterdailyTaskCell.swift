//
//  File.swift
//  Habitica
//
//  Created by Phillip on 08.06.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import Habitica_Models
import PinLayout
import Down

class YesterdailyTaskCell: UITableViewCell {

    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var checkbox: CheckboxView!
    @IBOutlet weak var titleTextView: UILabel!
    
    var onChecklistItemChecked: ((ChecklistItemProtocol) -> Void)?
    var checklistItems: [(UIView, ChecklistItemProtocol)] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.wrapperView.layer.borderWidth = 1
        
        let theme = ThemeService.shared.theme
        self.wrapperView.layer.borderColor = theme.separatorColor.cgColor
        wrapperView.backgroundColor = theme.contentBackgroundColor
    }

    func configure(task: TaskProtocol) {
        backgroundColor = ThemeService.shared.theme.windowBackgroundColor
        checkbox.configure(task: task)
        titleTextView.attributedText = try? Down(markdownString: task.text?.unicodeEmoji ?? "").toHabiticaAttributedString()

        checklistItems.forEach({ (view, _) in
            view.removeFromSuperview()
        })
        checklistItems = []

        for checklistItem in task.checklist {
            if let view = UIView.fromNib(nibName: "YesterdailyChecklistItem") {
                view.isUserInteractionEnabled = true
                view.backgroundColor = ThemeService.shared.theme.contentBackgroundColor
                let label = view.viewWithTag(2) as? UILabel
                label?.attributedText = try? Down(markdownString: checklistItem.text?.unicodeEmoji ?? "").toHabiticaAttributedString()
                let checkbox = view.viewWithTag(1) as? CheckboxView
                checkbox?.configure(checklistItem: checklistItem, withTitle: false)
                checkbox?.backgroundColor = ThemeService.shared.theme.windowBackgroundColor
                checkbox?.wasTouched = {
                    if let checked = self.onChecklistItemChecked {
                        checked(checklistItem)
                    }
                }
                wrapperView.addSubview(view)
                checklistItems.append((view, checklistItem))
                let recognizer = UITapGestureRecognizer(target: self, action: #selector(YesterdailyTaskCell.handleChecklistTap(recognizer:)))
                recognizer.cancelsTouchesInView = true
                view.addGestureRecognizer(recognizer)
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.pin.width(size.width)
        layout()
        return CGSize(width: contentView.frame.width, height: wrapperView.frame.height + 8)
    }
    
    private func layout() {
        wrapperView.pin.horizontally()
        checkbox.pin.width(55).start().top()
        titleTextView.pin.after(of: checkbox).marginStart(10).end(8).top().sizeToFit(.width)
        let textHeight = max(titleTextView.frame.size.height + 8, 48)
        checkbox.pin.height(textHeight)
        titleTextView.pin.height(textHeight)
        var checklistHeight = CGFloat(0)
        var topEdge = titleTextView.edge.bottom
        for (view, _) in checklistItems {
            guard let label = view.viewWithTag(2) as? UILabel else {
                continue
            }
            guard let itemCheckbox = view.viewWithTag(1) as? CheckboxView else {
                continue
            }
            view.pin.top(to: topEdge).horizontally()
            itemCheckbox.pin.width(55).start().top()
            label.pin.after(of: itemCheckbox).marginStart(10).end(8).top().sizeToFit(.width)
            let itemHeight = max(label.frame.size.height + 8, 40)
            label.pin.height(itemHeight)
            itemCheckbox.pin.height(itemHeight)
            view.pin.height(itemHeight)
            topEdge = view.edge.bottom
            checklistHeight += view.frame.size.height
        }
        let height = textHeight + checklistHeight + 1
        wrapperView.pin.height(height).top(4)
    }

    @objc
    func handleChecklistTap(recognizer: UITapGestureRecognizer) {
        if let (_, checklistItem) = checklistItems.first(where: { (view, _) -> Bool in
            return view == recognizer.view
        }) {
            if let checked = self.onChecklistItemChecked {
                checked(checklistItem)
            }
            return
        }
    }
}
