//
//  HabitControlsFormRow.swift
//  Habitica
//
//  Created by Phillip Thelen on 22.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Eureka

struct HabitControlsValue: Equatable {
    static func == (lhs: HabitControlsValue, rhs: HabitControlsValue) -> Bool {
        return lhs.positive == rhs.positive && lhs.negative == rhs.negative
    }
    
    var positive = true
    var negative = true
}

class HabitControlsCell: Cell<HabitControlsValue>, CellType {
    
    @IBOutlet weak var plusControlView: UIView!
    @IBOutlet weak var plusControlIconView: UIImageView!
    @IBOutlet weak var plusControlLabel: UILabel!
    @IBOutlet weak var minusControlView: UIView!
    @IBOutlet weak var minusControlIconView: UIImageView!
    @IBOutlet weak var minusControlLabel: UILabel!
    
    override public func setup() {
        super.setup()
        plusControlView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(plusTapped)))
        minusControlView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(minusTapped)))
        
        if row.value == nil {
            row.value = HabitControlsValue()
        }
    }

    @objc
    private func plusTapped() {
        row.value?.positive = !(row.value?.positive ?? false)
        row.updateCell()
    }
    
    @objc
    private func minusTapped() {
        row.value?.negative = !(row.value?.negative ?? false)
        row.updateCell()
    }

    public override func update() {
        if let taskRow = row as? HabitControlsRow {
            plusControlIconView.image = HabiticaIcons.imageOfHabitControlPlus(taskTintColor: taskRow.tintColor, isActive: taskRow.value?.positive ?? false)
            if taskRow.value?.positive == true {
                plusControlLabel.textColor = taskRow.tintColor
            } else {
                plusControlLabel.textColor = UIColor.gray200()
            }
            minusControlIconView.image = HabiticaIcons.imageOfHabitControlMinus(taskTintColor: taskRow.tintColor, isActive: taskRow.value?.negative ?? false)
            if taskRow.value?.negative == true {
                minusControlLabel.textColor = taskRow.tintColor
            } else {
                minusControlLabel.textColor = UIColor.gray200()
            }
        }
    }
}

final class HabitControlsRow: TaskRow<HabitControlsCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<HabitControlsCell>(nibName: "HabitControlsCell")
    }
}
