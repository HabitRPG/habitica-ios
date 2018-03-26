//
//  File.swift
//  Habitica
//
//  Created by Phillip Thelen on 21.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Eureka

struct SegmentedFormValue<V: Equatable>: Equatable, CustomStringConvertible {
    static func ==(lhs: SegmentedFormValue<V>, rhs: SegmentedFormValue<V>) -> Bool {
        return lhs.value == rhs.value
    }
    
    var value: V
    var label: String
    
    var description: String {
        return label
    }
}

typealias CombinedCell = BaseCell & CellType

class TaskRow<C: CombinedCell>: Row<C> {
    var tintColor: UIColor = UIColor.purple300()
}
