//
//  PathTraceable.swift
//  Habitica
//
//  Created by Juan on 11/09/21.
//  Copyright © 2021 HabitRPG Inc. All rights reserved.
//

import Foundation

protocol PathTraceable {
    func visiblePath() -> UIBezierPath
}
