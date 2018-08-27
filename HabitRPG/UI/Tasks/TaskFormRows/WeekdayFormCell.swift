//
//  WeekdayFormCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Eureka

struct WeekdaysValue: Equatable {
    static func ==(lhs: WeekdaysValue, rhs: WeekdaysValue) -> Bool {
        return false
    }
    
    var monday = true
    var tuesday = true
    var wednesday = true
    var thursday = true
    var friday = true
    var saturday = true
    var sunday = true
}

class WeekdayFormCell: Cell<WeekdaysValue>, CellType {
    @IBOutlet weak var mondayLabel: UILabel!
    @IBOutlet weak var tuesdayLabel: UILabel!
    @IBOutlet weak var wednesdayLabel: UILabel!
    @IBOutlet weak var thursdayLabel: UILabel!
    @IBOutlet weak var fridayLabel: UILabel!
    @IBOutlet weak var saturdayLabel: UILabel!
    @IBOutlet weak var sundayLabel: UILabel!
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        if row.value == nil {
            row.value = WeekdaysValue()
        }
        
        mondayLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mondayTapped)))
        tuesdayLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tuesdayTapped)))
        wednesdayLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(wednesdayTapped)))
        thursdayLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(thursdayTapped)))
        fridayLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fridayTapped)))
        saturdayLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(saturdayTapped)))
        sundayLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sundayTapped)))
    }
    
    @objc
    func mondayTapped() {
        row.value?.monday = !(row.value?.monday ?? false)
        row.updateCell()
    }
    
    @objc
    func tuesdayTapped() {
        row.value?.tuesday = !(row.value?.tuesday ?? false)
        row.updateCell()
    }
    
    @objc
    func wednesdayTapped() {
        row.value?.wednesday = !(row.value?.wednesday ?? false)
        row.updateCell()
    }
    
    @objc
    func thursdayTapped() {
        row.value?.thursday = !(row.value?.thursday ?? false)
        row.updateCell()
    }
    
    @objc
    func fridayTapped() {
        row.value?.friday = !(row.value?.friday ?? false)
        row.updateCell()
    }
    
    @objc
    func saturdayTapped() {
        row.value?.saturday = !(row.value?.saturday ?? false)
        row.updateCell()
    }
    
    @objc
    func sundayTapped() {
        row.value?.sunday = !(row.value?.sunday ?? false)
        row.updateCell()
    }
   
    public override func update() {
        if let taskRow = row as? WeekdayRow, let value = row.value {
            styleView(mondayLabel, isActive: value.monday, tintColor: taskRow.tintColor)
            styleView(tuesdayLabel, isActive: value.tuesday, tintColor: taskRow.tintColor)
            styleView(wednesdayLabel, isActive: value.wednesday, tintColor: taskRow.tintColor)
            styleView(thursdayLabel, isActive: value.thursday, tintColor: taskRow.tintColor)
            styleView(fridayLabel, isActive: value.friday, tintColor: taskRow.tintColor)
            styleView(saturdayLabel, isActive: value.saturday, tintColor: taskRow.tintColor)
            styleView(sundayLabel, isActive: value.sunday, tintColor: taskRow.tintColor)
            
            applyAccessibility()
        }
    }
    
    private func styleView(_ view: UILabel, isActive: Bool, tintColor: UIColor) {
        if isActive {
            view.backgroundColor = tintColor
            view.borderColor = nil
            view.borderWidth = 0
            view.textColor = .white
        } else {
            view.backgroundColor = .clear
            view.borderColor = UIColor.gray400()
            view.borderWidth = 1
            view.textColor = UIColor.gray400()
        }
    }
    
    private func applyAccessibility() {
        if let taskRow = row as? WeekdayRow {
            shouldGroupAccessibilityChildren = true
            isAccessibilityElement = true
            var days = [String]()
            if taskRow.value?.monday == true {
                days.append(L10n.monday)
            }
            if taskRow.value?.tuesday == true {
                days.append(L10n.tuesday)
            }
            if taskRow.value?.wednesday == true {
                days.append(L10n.wednesday)
            }
            if taskRow.value?.thursday == true {
                days.append(L10n.thursday)
            }
            if taskRow.value?.friday == true {
                days.append(L10n.friday)
            }
            if taskRow.value?.saturday == true {
                days.append(L10n.saturday)
            }
            if taskRow.value?.sunday == true {
                days.append(L10n.sunday)
            }
            
            if days.count > 0 {
                accessibilityLabel = L10n.activeOn(days.joined(separator: ", "))
            } else {
                accessibilityLabel = L10n.activeOn(L10n.noDays)
            }
            
            accessibilityCustomActions = []
            if taskRow.value?.monday == true {
                accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.disable(L10n.monday), target: self, selector: #selector(mondayTapped)))
            } else {
                accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.enable(L10n.monday), target: self, selector: #selector(mondayTapped)))
            }
            if taskRow.value?.tuesday == true {
                accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.disable(L10n.tuesday), target: self, selector: #selector(tuesdayTapped)))
            } else {
                accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.enable(L10n.tuesday), target: self, selector: #selector(tuesdayTapped)))
            }
            if taskRow.value?.wednesday == true {
                accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.disable(L10n.wednesday), target: self, selector: #selector(wednesdayTapped)))
            } else {
                accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.enable(L10n.wednesday), target: self, selector: #selector(wednesdayTapped)))
            }
            if taskRow.value?.thursday == true {
                accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.disable(L10n.thursday), target: self, selector: #selector(thursdayTapped)))
            } else {
                accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.enable(L10n.thursday), target: self, selector: #selector(thursdayTapped)))
            }
            if taskRow.value?.friday == true {
                accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.disable(L10n.friday), target: self, selector: #selector(fridayTapped)))
            } else {
                accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.enable(L10n.friday), target: self, selector: #selector(fridayTapped)))
            }
            if taskRow.value?.saturday == true {
                accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.disable(L10n.saturday), target: self, selector: #selector(saturdayTapped)))
            } else {
                accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.enable(L10n.saturday), target: self, selector: #selector(saturdayTapped)))
            }
            if taskRow.value?.sunday == true {
                accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.disable(L10n.sunday), target: self, selector: #selector(sundayTapped)))
            } else {
                accessibilityCustomActions?.append(UIAccessibilityCustomAction(name: L10n.Tasks.Form.Accessibility.enable(L10n.sunday), target: self, selector: #selector(sundayTapped)))
            }
        }
    }
}

final class WeekdayRow: TaskRow<WeekdayFormCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<WeekdayFormCell>(nibName: "WeekdayFormCell")
    }
}
