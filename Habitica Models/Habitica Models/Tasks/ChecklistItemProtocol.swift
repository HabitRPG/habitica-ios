//
//  ChecklistItemProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 06.03.18.
//  Copyright © 2018 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol ChecklistItemProtocol: BaseModelProtocol {
    var id: String? { get set }
    var text: String? { get set }
    var completed: Bool { get set }
    
    func detached() -> ChecklistItemProtocol
}
