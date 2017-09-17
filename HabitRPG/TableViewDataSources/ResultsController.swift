//
//  ResultsController.swift
//  Habitica
//
//  Created by Phillip on 17.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc enum ResultsChangeType: Int {
    case insert = 0, update, delete, move
}

@objc protocol ResultsController {
    
}
