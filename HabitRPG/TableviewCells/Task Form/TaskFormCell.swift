//
//  BaseTaskFormCell.swift
//  Habitica
//
//  Created by Phillip Thelen on 16.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation
import Habitica_Models

protocol TaskFormCell {
    
    func configureFor(task: TaskProtocol)
    func setTaskTintColor(color: UIColor)
}
