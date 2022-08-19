//
//  File.swift
//  Habitica
//
//  Created by Phillip Thelen on 21.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import UIKit
import Eureka

struct LabeledFormValue<V: Equatable & Hashable>: Equatable, CustomStringConvertible, Identifiable, Hashable {
    static func == (lhs: LabeledFormValue<V>, rhs: LabeledFormValue<V>) -> Bool {
        return lhs.value == rhs.value
    }
    
    var value: V
    var label: String
    
    var description: String {
        return label
    }
    
    var id: String {
        return value as? String ?? ""
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}

typealias CombinedCell = BaseCell & CellType

class TaskRow<C: CombinedCell>: Row<C> {
    var tintColor: UIColor = UIColor.purple300
    
    func updateTintColor(_ newTint: UIColor) {
        self.tintColor = newTint
    }
}
