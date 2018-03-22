//
//  File.swift
//  Habitica
//
//  Created by Phillip Thelen on 21.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Eureka

typealias CombinedCell = BaseCell & CellType

class TaskRow<C: CombinedCell>: Row<C> {
    var tintColor: UIColor = UIColor.purple300()
}
