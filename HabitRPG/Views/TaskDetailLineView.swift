//
//  TaskDetailLineView.swift
//  Habitica
//
//  Created by Phillip Thelen on 06/02/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import DateTools
import Habitica_Models

@IBDesignable
class TaskDetailLineView: UIView {

    private let reminderFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    @IBOutlet weak var calendarIconView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var streakIconView: UIImageView!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var challengeIconView: UIImageView!
    @IBOutlet weak var reminderIconView: UIImageView!
    @IBOutlet weak var reminderLabel: UILabel!
    
    private var iconColor: UIColor {
        return ThemeService.shared.theme.ternaryTextColor
    }
    private var textColor: UIColor {
        return ThemeService.shared.theme.quadTextColor
    }
    var contentView: UIView?

    @objc var dateFormatter: DateFormatter?

    var hasContent = true
    
    var checklistIndicatorTapped: (() -> Void)?

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
            view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
            addSubview(view)
            
            let font = CustomFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: 11))
            self.detailLabel.font = font
            self.streakLabel.font = font
            self.reminderLabel.font = font
        }
    }

    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView

        return view
    }

    @objc
    public func configure(task: TaskProtocol) {
        hasContent = false
        setReminder(task: task, reminders: task.reminders)
        setChallenge(enabled: task.isChallengeTask, broken: task.challengeBroken)
        setStreak(count: task.streak)

        if task.type == "habit" {
            setCalendarIcon(enabled: false)
            detailLabel.isHidden = true
            setLastCompleted(task: task)
        } else if task.type == "daily" {
            setCalendarIcon(enabled: false)
            detailLabel.isHidden = true
        } else if task.type == "todo" {
            setDueDate(task: task)
        }

        hasContent = !reminderIconView.isHidden || !challengeIconView.isHidden || !streakIconView.isHidden || !detailLabel.isHidden

        self.invalidateIntrinsicContentSize()
    }

    private func setCalendarIcon(enabled: Bool) {
        setCalendarIcon(enabled: enabled, isUrgent: false)
    }

    private func setCalendarIcon(enabled: Bool, isUrgent: Bool) {
        calendarIconView.isHidden = !enabled
        if enabled {
            if isUrgent {
                calendarIconView.tintColor = ThemeService.shared.theme.errorColor
            } else {
                calendarIconView.tintColor = iconColor
            }
            calendarIconView.tintColor = iconColor
        }
    }

    private func setDueDate(task: TaskProtocol?) {
        if let duedate = task?.duedate {
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
                self.detailLabel.textColor = ThemeService.shared.theme.errorColor
                self.detailLabel.text = L10n.Tasks.dueX(formatter.string(from: duedate))
            } else {
                detailLabel.textColor = textColor
                guard let differenceInDays = calendar.dateComponents([.day], from: today, to: duedate).day else {
                    return
                }
                if differenceInDays < 7 {
                    if differenceInDays == 0 {
                        setCalendarIcon(enabled: true, isUrgent: true)
                        detailLabel.textColor = ThemeService.shared.theme.errorColor
                        detailLabel.text = L10n.Tasks.dueToday
                    } else if differenceInDays == 1 {
                        setCalendarIcon(enabled: true)
                        detailLabel.text = L10n.Tasks.dueTomorrow
                    } else {
                        setCalendarIcon(enabled: true)
                        detailLabel.text = L10n.Tasks.dueInXDays(differenceInDays)
                    }
                } else {
                    setCalendarIcon(enabled: true)
                    self.detailLabel.text = L10n.Tasks.dueX(formatter.string(from: duedate))
                }
            }
        } else {
            detailLabel.isHidden = true
            detailLabel.text = nil
            setCalendarIcon(enabled: false)
        }
    }

    private func setStreak(count: Int) {
        // swiftlint:disable:next empty_count
        if count > 0 {
            streakLabel.text = String(count)
            streakIconView.isHidden = false
            streakLabel.textColor = textColor
            streakIconView.tintColor = iconColor
        } else {
            streakLabel.text = nil
            streakIconView.isHidden = true
        }
    }

    private func setLastCompleted(task: TaskProtocol) {
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
        
        if counterString.isEmpty == false {
            streakLabel.text = counterString
            streakIconView.isHidden = false
            streakLabel.textColor = textColor
            streakIconView.tintColor = iconColor
        } else {
            streakLabel.text = nil
            streakIconView.isHidden = true
        }
    }

    private func setChallenge(enabled: Bool, broken: String?) {
        challengeIconView.isHidden = !enabled
        if enabled {
            if broken != nil {
                challengeIconView.image = Asset.challengeBroken.image
            } else {
                challengeIconView.image = Asset.challenge.image
            }
            challengeIconView.tintColor = iconColor
        }
    }

    private func setReminder(task: TaskProtocol, reminders: [ReminderProtocol]) {
        reminderIconView.isHidden = reminders.isEmpty
        if reminderIconView.isHidden {
            reminderLabel.text = nil
        } else {
            if task.type == "daily" {
                reminderIconView.tintColor = iconColor
                let now = Date()
                let nextReminder = reminders.first { reminder in
                    guard let time = reminder.time else {
                        return false
                    }
                    let calendar = Calendar.current
                    var components = calendar.dateComponents([.year, .month, .day], from: now)
                    let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
                    components.hour = timeComponents.hour
                    components.minute = timeComponents.minute
                    components.timeZone = TimeZone.current
                    if let newDate = calendar.date(from: components) {
                        return now < newDate
                    }
                    return false
                }
                var reminderString = ""
                if let time = nextReminder?.time {
                    reminderString += reminderFormatter.string(from: time)
                }
                if reminders.count > 1 {
                    reminderString = "\(reminderString) (+\(reminders.count-1))"
                }
                reminderLabel.text = reminderString
                reminderLabel.textColor = textColor
            }
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
