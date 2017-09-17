//
//  ResultsControllerDelegate.swift
//  Habitica
//
//  Created by Phillip on 17.09.17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc protocol ResultsControllerDelegate: class {
    
    func beginUpdate(controller: ResultsController)
    func updateSection(controller: ResultsController)
    func updateItem(controller: ResultsController, indexPath: IndexPath, changeType: ResultsChangeType)
    func endUpdate(controller: ResultsController)
    
}
