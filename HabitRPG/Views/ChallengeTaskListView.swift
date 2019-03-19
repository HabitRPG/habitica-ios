//
//  ChallengeTaskListView.swift
//  Habitica
//
//  Created by Phillip Thelen on 14/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

@IBDesignable
class ChallengeTaskListView: UIView {

    static let verticalSpacing = CGFloat(integerLiteral: 12)
    static let borderColor = UIColor.gray400()

    let titleLabel = UILabel()
    let borderView = UIView()

    var taskViews = [UIView]()

    @IBInspectable var taskType: String? {
        didSet {
            updateTitle()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        self.addSubview(titleLabel)
        self.clipsToBounds = true
        self.addSubview(borderView)
        borderView.layer.borderColor = ChallengeTaskListView.borderColor.cgColor
        borderView.layer.borderWidth = 1
    }

    func configure(tasks: [TaskProtocol]?) {
        removeAllTaskViews()
        guard let tasks = tasks else {
            return
        }
        for (index, task) in tasks.enumerated() {
            let taskView = createTaskView(task: task, isFirst: index == 0)
            self.addSubview(taskView)
            taskViews.append(taskView)
        }
        updateTitle()
        self.setNeedsLayout()
        self.invalidateIntrinsicContentSize()
    }

    override func layoutSubviews() {
        let frame = self.frame
        var titleHeight = titleLabel.sizeThatFits(frame.size).height
        titleLabel.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: titleHeight)
        titleHeight += 8
        var nextTaskViewPos = titleHeight
        let labelSize = CGSize(width: frame.size.width-80, height: frame.size.height)
        for taskView in taskViews {
            if let label = taskView.viewWithTag(1) {
                let height = label.sizeThatFits(labelSize).height
                label.frame = CGRect(x: 40, y: ChallengeTaskListView.verticalSpacing, width: frame.size.width-80, height: height)
                taskView.frame = CGRect(x: 0, y: nextTaskViewPos, width: frame.size.width, height: height+ChallengeTaskListView.verticalSpacing*2)
                if let plusImageView = taskView.viewWithTag(2) {
                    plusImageView.frame = CGRect(x: 0, y: 0, width: 40, height: height+ChallengeTaskListView.verticalSpacing*2)
                }
                if let minusImageView = taskView.viewWithTag(3) {
                    minusImageView.frame = CGRect(x: frame.size.width-40, y: 0, width: 40, height: height+ChallengeTaskListView.verticalSpacing*2)
                }
                nextTaskViewPos += height+ChallengeTaskListView.verticalSpacing*2
            }
        }
        borderView.frame = CGRect(x: 0, y: titleHeight, width: frame.size.width, height: nextTaskViewPos-titleHeight)
        super.layoutSubviews()
    }

    override var intrinsicContentSize: CGSize {
        if taskViews.isEmpty {
            return CGSize.zero
        }
        var height = titleLabel.intrinsicContentSize.height + 8
        let labelSize = CGSize(width: frame.size.width-80, height: frame.size.height)
        for taskView in taskViews {
            if let label = taskView.viewWithTag(1) as? UILabel {
                height += label.sizeThatFits(labelSize).height+ChallengeTaskListView.verticalSpacing*2
            }
        }
        return CGSize(width: self.frame.size.width, height: height)
    }

    private func removeAllTaskViews() {
        for view in taskViews {
            view.removeFromSuperview()
        }
        taskViews.removeAll()
    }

    private func createTaskView(task: TaskProtocol, isFirst: Bool) -> UIView {
        let taskView = UIView()
        let titleView = UILabel()
        if !isFirst {
            let borderView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 1))
            borderView.backgroundColor = ChallengeTaskListView.borderColor
            taskView.addSubview(borderView)
        }
        titleView.tag = 1
        taskView.addSubview(titleView)
        titleView.text = task.text?.unicodeEmoji
        titleView.numberOfLines = 0
        titleView.font = UIFont.preferredFont(forTextStyle: .caption1)
        titleView.textColor = UIColor(white: 0, alpha: 0.5)
        if task.type == "habit" {
            let plusImageView = UIImageView(image: #imageLiteral(resourceName: "plus_gray"))
            plusImageView.tag = 2
            plusImageView.contentMode = .center
            taskView.addSubview(plusImageView)
            if task.up {
                plusImageView.alpha = 0.3
            }
            let minusImageView = UIImageView(image: #imageLiteral(resourceName: "minus_gray"))
            minusImageView.tag = 3
            minusImageView.contentMode = .center
            taskView.addSubview(minusImageView)
            if task.down {
                minusImageView.alpha = 0.3
            }
        }
        return taskView
    }

    private func updateTitle() {
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textColor = UIColor(white: 0, alpha: 0.5)
        if let taskType = self.taskType {
            var title: String?
            switch taskType {
            case "habit":
                title = L10n.Tasks.habits
            case "daily":
                title = L10n.Tasks.dailies
            case "todo":
                title = L10n.Tasks.todos
            case "reward":
                title = L10n.Tasks.rewards
            default:
                title = ""
            }
            if let title = title {
                self.titleLabel.text = "\(taskViews.count) \(title)"
            }
        }
    }
}
