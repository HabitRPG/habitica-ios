//
//  AssignedDetailsProtocol.swift
//  Habitica Models
//
//  Created by Phillip Thelen on 28.10.22.
//  Copyright © 2022 HabitRPG Inc. All rights reserved.
//

import Foundation

@objc
public protocol AssignedDetailsProtocol: BaseModelProtocol {
    var assignedUserID: String? { get set }
    var assignedDate: Date? { get set }
    var assignedUsername: String? { get set }
    var assigningUsername: String? { get set }
    var completed: Bool { get set }
}
