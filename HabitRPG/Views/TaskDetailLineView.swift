//
//  TaskDetailLineView.swift
//  Habitica
//
//  Created by Phillip Thelen on 06/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import DateTools

@IBDesignable
class TaskDetailLineView: UIView {

    private static let spacing: CGFloat = 12
    private static let iconSize: CGFloat = 18

    @IBOutlet weak var calendarIconView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var streakIconView: UIImageView!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var challengeIconView: UIImageView!
    @IBOutlet weak var reminderIconView: UIImageView!
    @IBOutlet weak var tagIconView: UIImageView!

    @IBOutlet weak private var calendarIconViewWidth: NSLayoutConstraint!
    @IBOutlet weak private var streakIconViewWidth: NSLayoutConstraint!
    @IBOutlet weak private var challengeIconViewWidth: NSLayoutConstraint!
    @IBOutlet weak private var reminderIconViewWidth: NSLayoutConstraint!
    @IBOutlet weak private var tagIconViewWidth: NSLayoutConstraint!

    @IBOutlet weak private var calendarDetailSpacing: NSLayoutConstraint!
    @IBOutlet weak private var detailStreakSpacing: NSLayoutConstraint!
    @IBOutlet weak private var streakIconLabelSpacing: NSLayoutConstraint!
    @IBOutlet weak private var streakChallengeSpacing: NSLayoutConstraint!
    @IBOutlet weak private var challengeReminderSpacing: NSLayoutConstraint!
    @IBOutlet weak private var reminderTagSpacing: NSLayoutConstraint!

    var contentView: UIView?

    var dateFormatter: DateFormatter?

    var hasContent = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    func xibSetup() {
        if let view = loadViewFromNib() {
            self.contentView = view
            view.frame = bounds
            view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
            addSubview(view)
        }
    }

    func loadViewFromNib() -> UIView? {

        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView

        return view
    }

    public func configure(task: Task) {
        hasContent = false
        //setTag(enabled: task.tagArray.count > 0)
        //setReminder(enabled: (task.reminders?.count ?? 0) > 0)
        setChallenge(enabled: task.challengeID.characters.count > 0)
        setStreak(count: task.streak)

        if task.type == "habit" {
            setCalendarIcon(enabled: false)
            setLastCompleted(task: task)
        } else if task.type == "daily" {
            setCalendarIcon(enabled: false)
            detailLabel.isHidden = true
        } else if task.type == "todo" {
            setDueDate(task: task)
        }

        hasContent = !tagIconView.isHidden || !reminderIconView.isHidden || !challengeIconView.isHidden || !streakIconView.isHidden || !detailLabel.isHidden

        self.invalidateIntrinsicContentSize()
    }

    private func setCalendarIcon(enabled: Bool) {
        setCalendarIcon(enabled: enabled, isUrgent: false)
    }

    private func setCalendarIcon(enabled: Bool, isUrgent: Bool) {
        calendarIconView.isHidden = !enabled
        if enabled {
            calendarIconViewWidth.constant = TaskDetailLineView.iconSize
            calendarDetailSpacing.constant = 4
            if isUrgent {
                calendarIconView.tintColor = .red100()
            } else {
                calendarIconView.tintColor = .gray400()
            }
        } else {
            calendarIconViewWidth.constant = 0
            calendarDetailSpacing.constant = 0
        }
    }

    private func setDueDate(task: Task) {
        if let duedate = task.duedate {
            detailLabel.isHidden = false
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: Date())
            components.hour = 0
            guard let today = calendar.date(from: components) else {
                return
            }
            guard let formatter = dateFormatter else {
                return
            }

            if duedate.compare(today) == .orderedAscending {
                setCalendarIcon(enabled: true, isUrgent: true)
                self.detailLabel.textColor = .red10()
                self.detailLabel.text = "Due \(formatter.string(from: duedate))".localized
            } else {
                detailLabel.textColor = .gray50()
                guard let differenceInDays = calendar.dateComponents([.day], from: today, to: duedate).day else {
                    return
                }
                if differenceInDays < 7 {
                    if differenceInDays == 0 {
                        setCalendarIcon(enabled: true, isUrgent: true)
                        detailLabel.textColor = .red10()
                        detailLabel.text = "Due today".localized
                    } else if differenceInDays == 1 {
                        setCalendarIcon(enabled: true)
                        detailLabel.text = "Due tomorrow".localized
                    } else {
                        setCalendarIcon(enabled: true)
                        detailLabel.text = "Due in \(differenceInDays) days".localized
                    }
                } else {
                    if let duedate = task.duedate {
                        setCalendarIcon(enabled: true)
                        self.detailLabel.text = "Due \(formatter.string(from: duedate))".localized
                    }
                }
            }
        } else {
            detailLabel.isHidden = true
            detailLabel.text = nil
            setCalendarIcon(enabled: false)
        }
    }

    private func setStreak(count: Int) {
        if count > 0 {
            streakLabel.text = String(count)
            streakIconView.isHidden = false
            streakIconViewWidth.constant = 12
            streakIconLabelSpacing.constant = 4
            detailStreakSpacing.constant = TaskDetailLineView.spacing
        } else {
            streakLabel.text = nil
            streakIconView.isHidden = true
            streakIconViewWidth.constant = 0
            streakIconLabelSpacing.constant = 0
            detailStreakSpacing.constant = 0
        }
    }

    private func setLastCompleted(task: Task) {
        var counterString = ""
        
        let upCounter = task.counterUp
        let downCounter = task.counterDown
        if task.up && task.down && upCounter+downCounter > 0 {
            counterString = "+\(upCounter) | -\(downCounter)"
        } else if task.up && upCounter > 0 {
            counterString = "\(upCounter)"
        } else if downCounter > 0 {
            counterString = "\(downCounter)"
        }
        
        if counterString.characters.count > 0 {
            streakLabel.text = counterString
            streakIconView.isHidden = false
            streakIconViewWidth.constant = 12
            streakIconLabelSpacing.constant = 4
            detailStreakSpacing.constant = TaskDetailLineView.spacing
        }
    }

    private func setChallenge(enabled: Bool) {
        challengeIconView.isHidden = !enabled
        if enabled {
            challengeIconViewWidth.constant = TaskDetailLineView.iconSize
            streakChallengeSpacing.constant = TaskDetailLineView.spacing
        } else {
            challengeIconViewWidth.constant = 0
            streakChallengeSpacing.constant = 0
        }
    }

    private func setReminder(enabled: Bool) {
        reminderIconView.isHidden = !enabled
        if enabled {
            reminderIconViewWidth.constant = TaskDetailLineView.iconSize
            challengeReminderSpacing.constant = TaskDetailLineView.spacing
        } else {
            reminderIconViewWidth.constant = 0
            challengeReminderSpacing.constant = 0
        }
    }

    private func setTag(enabled: Bool) {
        tagIconView.isHidden = !enabled
        if enabled {
            tagIconViewWidth.constant = TaskDetailLineView.iconSize
            reminderTagSpacing.constant = TaskDetailLineView.spacing
        } else {
            tagIconViewWidth.constant = 0
            reminderTagSpacing.constant = 0
        }
    }

    override public var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize

        if hasContent {
            size.height = 18
        } else {
            size.height = 0
        }

        return size
    }

}
