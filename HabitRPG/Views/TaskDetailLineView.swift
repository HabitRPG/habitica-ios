//
//  TaskDetailLineView.swift
//  Habitica
//
//  Created by Phillip Thelen on 06/02/2017.
//  Copyright © 2017 Phillip Thelen. All rights reserved.
//

import UIKit
import DateTools

@IBDesignable
class TaskDetailLineView: UIView {
    
    private let SPACING: CGFloat = 12
    private let ICON_SIZE: CGFloat = 18
    
    @IBOutlet weak var calendarIconView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var streakIconView: UIImageView!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var challengeIconView: UIImageView!
    @IBOutlet weak var reminderIconView: UIImageView!
    @IBOutlet weak var tagIconView: UIImageView!
    
    @IBOutlet weak var calendarIconViewWidth: NSLayoutConstraint!
    @IBOutlet weak var streakIconViewWidth: NSLayoutConstraint!
    @IBOutlet weak var challengeIconViewWidth: NSLayoutConstraint!
    @IBOutlet weak var reminderIconViewWidth: NSLayoutConstraint!
    @IBOutlet weak var tagIconViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var calendarDetailSpacing: NSLayoutConstraint!
    @IBOutlet weak var detailStreakSpacing: NSLayoutConstraint!
    @IBOutlet weak var streakIconLabelSpacing: NSLayoutConstraint!
    @IBOutlet weak var streakChallengeSpacing: NSLayoutConstraint!
    @IBOutlet weak var challengeReminderSpacing: NSLayoutConstraint!
    @IBOutlet weak var reminderTagSpacing: NSLayoutConstraint!
    
    var contentView : UIView?
    
    var dateFormatter : DateFormatter?
    
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
        contentView = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        contentView!.frame = bounds
        
        // Make the view stretch with containing view
        contentView!.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(contentView!)
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    public func configure(task: Task) {
        hasContent = false
        setTag(enabled: task.tagArray.count > 0)
        setReminder(enabled: (task.reminders?.count ?? 0) > 0)
        setChallenge(enabled: task.challengeID != nil)
        setStreak(count: task.streak?.intValue ?? 0)
        
        if task.type == "habit" {
            setCalendarIcon(enabled: false)
            setLastCompleted(task: task);
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
            calendarIconViewWidth.constant = ICON_SIZE
            calendarDetailSpacing.constant = 4
            if isUrgent {
                calendarIconView.image = #imageLiteral(resourceName: "calendar_red")
            } else {
                calendarIconView.image = #imageLiteral(resourceName: "calendar")
            }
        } else {
            calendarIconViewWidth.constant = 0
            calendarDetailSpacing.constant = 0
        }
    }
    
    private func setDueDate(task: Task) {
        if task.duedate != nil {
            detailLabel.isHidden = false
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: Date())
            components.hour = 0
            let today = calendar.date(from: components)
            
            guard let formatter = dateFormatter else {
                return;
            }

            if task.duedate?.compare(today!) == .orderedAscending {
                setCalendarIcon(enabled: true, isUrgent: true)
                self.detailLabel.textColor = .red10()
                self.detailLabel.text = "Due \(formatter.string(from: task.duedate!))".localized
            } else {
                detailLabel.textColor = .gray50();
                let differenceValue = calendar.dateComponents([.day], from: today!, to: task.duedate!)
                if differenceValue.day! < 7 {
                    if differenceValue.day! == 0{
                        setCalendarIcon(enabled: true, isUrgent: true)
                        detailLabel.textColor = .red10();
                        detailLabel.text = "Due today".localized;
                    } else if differenceValue.day! == 1 {
                        setCalendarIcon(enabled: true)
                        detailLabel.text = "Due tomorrow".localized;
                    } else {
                        setCalendarIcon(enabled: true)
                        detailLabel.text = "Due in \(differenceValue.day) days".localized
                    }
                } else {
                    setCalendarIcon(enabled: true)
                    self.detailLabel.text = "Due \(formatter.string(from: task.duedate!))".localized
                }
            }
        } else {
            detailLabel.isHidden = true
            detailLabel.text = nil;
            setCalendarIcon(enabled: false)
        }
    }
    
    private func setStreak(count: Int) {
        if count > 0 {
            streakLabel.text = String(count)
            streakIconView.isHidden = false
            streakIconViewWidth.constant = 12
            streakIconLabelSpacing.constant = 4
            detailStreakSpacing.constant = SPACING
        } else {
            streakLabel.text = nil
            streakIconView.isHidden = true
            streakIconViewWidth.constant = 0
            streakIconLabelSpacing.constant = 0
            detailStreakSpacing.constant = 0
        }
    }

    private func setLastCompleted(task: Task) {
        //Removed because storing task history was causing sync issues
    }
    
    private func setChallenge(enabled: Bool) {
        challengeIconView.isHidden = !enabled
        if enabled {
            challengeIconViewWidth.constant = ICON_SIZE
            streakChallengeSpacing.constant = SPACING
        } else {
            challengeIconViewWidth.constant = 0
            streakChallengeSpacing.constant = 0
        }
    }
    
    private func setReminder(enabled: Bool) {
        reminderIconView.isHidden = !enabled
        if enabled {
            reminderIconViewWidth.constant = ICON_SIZE
            challengeReminderSpacing.constant = SPACING
        } else {
            reminderIconViewWidth.constant = 0
            challengeReminderSpacing.constant = 0
        }
    }
    
    private func setTag(enabled: Bool) {
        tagIconView.isHidden = !enabled
        if enabled {
            tagIconViewWidth.constant = ICON_SIZE
            reminderTagSpacing.constant = SPACING
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
